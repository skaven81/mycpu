"""
Variable management for C compiler
Handles storage location and code generation for variable access
"""

class Variable:
    """Represents a variable with its storage location and type"""

    # C99 §6.7.2 - Type specifiers
    TYPE_SPECIFIERS = {
        'void', 'char', 'short', 'int', 'long', 
        'float', 'double', 'signed', 'unsigned',
        '_Bool', '_Complex', '_Imaginary'
    }
    
    # const: compiler may throw error if variable is written to.
    #   Compiler may insert the value directly in assembly code
    #   instead of reading from the stack.
    # restrict: for pointers, indicates that this is the only legal
    #   way to access the pointed-to memory.
    # volatile: the data in this memory location might change outside
    #   of normal program flow (e.g. memory-mapped I/O)
    TYPE_QUALIFIERS = {'const', 'restrict', 'volatile'}

    # typedef: type alias, compiler-internal only
    # extern: the variable is defined elsewhere, don't allocate memory for
    #   it. The linker will figure it out. Can also mean "hand-written assembly
    #   defines this."
    # static: for local variables, means the memory should be allocated from
    #   global space. Value persists over function calls.  For global vars,
    #   means the variable is global to the file, not to the entire program.
    # auto: lives on the stack (this is the default)
    # register: compiler hint that the variable may live in a register, does
    #   not need to be mapped to a memory location. Dereferencing a register
    #   var (e.g. &varname) is illegal.
    STORAGE_CLASS = {'typedef', 'extern', 'static', 'auto', 'register'}

    # Built-in typedefs
    BUILT_IN_TYPEDEFS = {
        'uint8_t':  ['unsigned', 'char'],
        'int8_t':   ['signed', 'char'],
        'uint16_t': ['unsigned', 'short'],
        'int16_t':  ['signed', 'short'],
        'size_t':   ['unsigned', 'short'],
        'byte':     ['signed', 'char'],
        'word':     ['signed', 'short'],
    }
     
    def __init__(self, name, type_names, scope, offset=None, static_type='inline', is_pointer=False):
        """
        Parse type from IdentifierType.names list.

        Args:
            name: Variable name as used in C code
            type_names: IdentifierType.names list
            scope: 'global', 'local', or 'param'
            offset: stack frame offset where variable is stored relative to D frame pointer (for local/param vars)
            static_type: 'inline' or 'asm_var'
        """
        self.name = name
        self.scope = scope
        self.offset = offset
        self.static_type = static_type
        self.is_pointer = is_pointer
        self.orig_type_names = type_names

        # Filter out qualifiers and storage class
        self.qualifiers = set()
        self.storage_class = None
        specs = []
        
        for t in type_names:
            if t in self.TYPE_QUALIFIERS:
                self.qualifiers.add(t)
            elif t in self.STORAGE_CLASS:
                self.storage_class = t
            elif t in self.TYPE_SPECIFIERS:
                specs.append(t)
            elif t in self.BUILT_IN_TYPEDEFS:
                specs = self.BUILT_IN_TYPEDEFS[t]
            else:
                # Unknown type
                raise ValueError(f"Unknown type name: {name}")
 
        # Validate scope
        if self.scope in ('local', 'param') and self.offset is None:
            raise ValueError(f"{scope} variable requires offset")
        if self.scope == 'global' and self.offset is not None:
            raise ValueError(f"global variable should not have offset")

        # Determine signedness
        self.signed = True
        if 'unsigned' in specs:
            self.signed = False
            specs.remove('unsigned')
        if 'signed' in specs:
            self.signed = True
            specs.remove('signed')

        # Parse base type
        joined_specs = " ".join(specs)
        if self.is_pointer:
            self.type = 'ptr'
            self.size = 2
        elif not specs:
            # Plain 'signed' or 'unsigned' means 'int'
            self.type = 'int'
            self.size = 2
        elif specs == ['void']:
            self.type = joined_specs
            self.size = 0
        elif specs == ['char']:
            self.type = joined_specs
            self.size = 1
        elif specs == ['short'] or specs == ['short', 'int']:
            self.type = joined_specs
            self.size = 2
        elif specs == ['int']:
            self.type = joined_specs
            self.size = 2
        elif specs == ['long'] or specs == ['long', 'int']:
            self.type = joined_specs
            self.size = 4
        elif specs == ['_Bool']:
            self.type = 'bool'
            self.size = 1
            self.signed = False
        else:
            raise ValueError(f"Invalid type specifier combination: {specs}")         

        # For static vars, define assembly name used
        self.asm_name = None
        if self.is_static:
            if self.static_type == 'inline':
                self.asm_name = f".{self.name}_{id(self)}"
            elif self.static_type == 'asm_var':
                self.asm_name = f"${self.name}_{id(self)}"
            else:
                raise ValueError("static_type must be inline or asm_var")
 
    def __repr__(self):
        ret = f"Variable('{self.name}', {self.orig_type_names}, '{self.scope}'"
        if not self.is_static:
            ret += f", offset={self.offset}"
        if self.static_type != 'inline':
            ret += f", static_type='{self.static_type}'"
        if self.is_pointer:
            ret += f", is_pointer='{self.is_pointer}'"
        ret += ")"
        return ret

    def __str__(self):
        if self.is_static:
            return f"Cvar[{self.name}] {self.orig_type_names} size={self.size} scope={self.scope} label={self.asm_name}"
        else:
            return f"Cvar[{self.name}] {self.orig_type_names} size={self.size} scope={self.scope} frame_offset={self.offset}"
    
    @property
    def is_static(self):
        """Check if variable has static storage duration"""
        return self.storage_class == 'static' or self.scope == 'global'

    @property
    def is_volatile(self):
        """Check if variable is volatile (no optimization allowed)"""
        return 'volatile' in self.qualifiers

    @property
    def is_const(self):
        """Check if variable is const (read-only)"""
        return 'const' in self.qualifiers

    def emit_static_declaration(self, emitter):
        """Generate assembly that defines the static var"""
        if not self.is_static:
            return
        if self.static_type == 'inline':
            emitter(f'{self.asm_name} "' + "\\0"*self.size + '"')
        elif self.static_type == 'asm_var':
            if self.size == 1:
                emitter(f'VAR global byte {self.asm_name}')
            elif self.size == 2:
                emitter(f'VAR global word {self.asm_name}')
            else:
                emitter(f'VAR global {self.size} {self.asm_name}')

    def _emit_extend(self, to_size, emitter):
        """Emit code to extend value in A to larger size"""
        if self.size == 1 and to_size == 2:
            if self.signed:
                # Sign-extend AL into AH
                emitter("LDI_BL 0x80", "Sign-extend AL to 16-bit")
                emitter("ALUOP_FLAGS %A&B%+%AL%+%BL%")
                label = f".sext_{id(self)}"
                emitter("LDI_AH 0x00")
                emitter(f"JZ {label}")
                emitter("LDI_AH 0xff")
                emitter(f"{label}")
            else:
                # Zero-extend
                emitter("LDI_AH 0x00", "Zero-extend AL to 16-bit")
        elif self.size == 2 and to_size == 4:
            # Future: 16-bit to 32-bit extension
            raise NotImplementedError("32-bit types not yet supported")
     
    def emit_load(self, emitter):
        """
        Generate assembly to load this variable into A register.
        
        Args:
            emitter: Function that takes assembly code strings
        """
        if self.is_static:
            if self.size == 2:
                emitter(f"LD16_A {self.asm_name}")
            elif self.size == 1:
                emitter(f"LD_AL {self.asm_name}")
                self._emit_extend(2, emitter)
            else:
                raise NotImplementedError(f"Cannot load {self.size}-byte global")
        elif self.scope in ('local', 'param'):
            emitter(f"LDI_BL {self.offset}")
            if self.size == 2:
                emitter("CALL :frame_load_BL_A")
            elif self.size == 1:
                emitter("CALL :frame_load_BL_AL")
                self._emit_extend(2, emitter)
            else:
                raise NotImplementedError(f"Cannot load {self.size}-byte type")
        else:
            raise ValueError(f"Unknown scope: {self.scope}")
    
    def emit_store(self, emitter):
        """
        Generate assembly to store A register to this variable.
        
        Args:
            emitter: Function that takes assembly code strings
        """
        if self.is_static:
            if self.size == 2:
                emitter(f"ST_AH {self.asm_name}")
                emitter(f"ST_AL {self.asm_name}+1")
            elif self.size == 1:
                emitter(f"ST_AL {self.asm_name}")
            else:
                raise NotImplementedError(f"Cannot store {self.size}-byte global")
        elif self.scope in ('local', 'param'):
            emitter(f"LDI_BL {self.offset}")
            if self.size == 2:
                emitter("CALL :frame_store_BL_A")
            elif self.size == 1:
                emitter("CALL :frame_store_BL_AL")
            else:
                raise NotImplementedError(f"Cannot store {self.size}-byte type")
        else:
            raise ValueError(f"Unknown scope: {self.scope}")
    
    def emit_address(self, emitter):
        """
        Generate assembly to load the address of this variable into A register.
        Used for pointer operations like &variable.
        
        Args:
            emitter: Function that takes assembly code strings
        """
        if self.scope == 'global':
            emitter(f"LDI_A {self.asm_name}")
        elif self.scope in ('local', 'param'):
            # Address = D (frame pointer) + offset
            emitter(f"# Load address of {self.scope} variable {self.name}")
            emitter("ALUOP_AH %A%+%DH%")
            emitter("ALUOP_AL %A%+%DL%")
            emitter(f"LDI_B {self.offset}")
            emitter("CALL :add16_to_a")  # Add offset to D
        else:
            raise ValueError(f"Unknown scope: {self.scope}")

    @staticmethod
    def promote(var1, var2):
        """
        C integer promotion rules: return the type that two operands
        should be promoted to for binary operations.
        """
        # Both pointer: use first one
        if var1.is_pointer or var2.is_pointer:
            return var1 if var1.is_pointer else var2
        
        # Larger size wins
        if var1.size != var2.size:
            return var1 if var1.size > var2.size else var2
        
        # Same size: unsigned wins
        if var1.signed != var2.signed:
            return var1 if not var1.signed else var2
        
        # Same everything: return first
        return var1

class VariableTable:
    """Manages variable scopes and lookups"""
    
    def __init__(self):
        self.globals = {}      # name -> Variable
        self.scopes = []       # Stack of dicts: name -> Variable
    
    def push_scope(self):
        """Enter a new scope (e.g., function body)"""
        self.scopes.append({})
    
    def pop_scope(self):
        """Exit current scope"""
        if not self.scopes:
            raise RuntimeError("Cannot pop global scope")
        self.scopes.pop()
    
    def add_global(self, variable):
        """Add a global variable"""
        if variable.name in self.globals:
            raise ValueError(f"Global variable already defined: {variable.name}")
        if variable.scope != 'global':
            raise ValueError(f"Variable marked as {variable.scope} but added as global")
        self.globals[variable.name] = variable
    
    def add_local(self, variable):
        """Add a variable to current scope"""
        if not self.scopes:
            raise RuntimeError("No active scope for local variable")
        if variable.scope not in ('local', 'param'):
            raise ValueError(f"Variable marked as {variable.scope} but added as local")
        scope = self.scopes[-1]
        if variable.name in scope:
            raise ValueError(f"Variable already defined in scope: {variable.name}")
        scope[variable.name] = variable
    
    def lookup(self, name):
        """
        Look up a variable by name, searching from innermost to outermost scope.
        
        Returns:
            Variable object, or None if not found
        """
        # Search local scopes from innermost to outermost
        for scope in reversed(self.scopes):
            if name in scope:
                return scope[name]
        
        # Search globals
        if name in self.globals:
            return self.globals[name]
        
        return None
    
    def get_all_globals(self):
        """Get all global variables"""
        return list(self.globals.values())
    
    def get_current_scope_vars(self):
        """Get variables in current scope"""
        if not self.scopes:
            return []
        return list(self.scopes[-1].values())
