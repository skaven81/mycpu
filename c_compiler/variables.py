"""
Variable management for C compiler
Handles storage location and code generation for variable access
Enhanced with typedef, struct, and array support
"""

import math

# Global context for registries - set this once at the start of compilation
_global_typedef_registry = None
_global_struct_registry = None

def set_type_context(typedef_registry, struct_registry):
    """
    Set the global type registries for the compilation context.
    Call this once at the start of compilation.
    """
    global _global_typedef_registry, _global_struct_registry
    _global_typedef_registry = typedef_registry
    _global_struct_registry = struct_registry

def get_typedef_registry():
    """Get the current typedef registry"""
    return _global_typedef_registry

def get_struct_registry():
    """Get the current struct registry"""
    return _global_struct_registry


class TypedefRegistry:
    """Manages user-defined type aliases"""
    
    def __init__(self):
        # Built-in typedefs
        self.typedefs = {
            'uint8_t':  ['unsigned', 'char'],
            'int8_t':   ['signed', 'char'],
            'uint16_t': ['unsigned', 'short'],
            'int16_t':  ['signed', 'short'],
            'size_t':   ['unsigned', 'short'],
            'byte':     ['signed', 'char'],
            'word':     ['signed', 'short'],
        }
    
    def add_typedef(self, alias, type_spec):
        """
        Register a new typedef.
        
        Args:
            alias: The new type name
            type_spec: TypeSpec object or list of type names
        """
        if alias in self.typedefs:
            raise ValueError(f"Typedef already exists: {alias}")
        self.typedefs[alias] = type_spec
    
    def resolve(self, type_name):
        """
        Resolve a typedef to its underlying type specification.
        Returns None if not a typedef.
        """
        return self.typedefs.get(type_name)
    
    def is_typedef(self, type_name):
        """Check if a name is a registered typedef"""
        return type_name in self.typedefs


class StructDefinition:
    """Represents a struct type definition"""
    
    def __init__(self, name, members=None):
        """
        Args:
            name: Struct tag name (None for anonymous structs)
            members: List of (member_name, type_spec_or_names) tuples
                    where type_spec_or_names is either:
                    - A TypeSpec object, or
                    - A string or list of type names to be resolved
        """
        self.name = name
        self.members = []  # [(name, TypeSpec), ...]
        self.offsets = {}  # member_name -> offset
        self.size = 0
        
        # Process members and resolve types
        if members:
            for member_name, type_info in members:
                if isinstance(type_info, TypeSpec):
                    type_spec = type_info
                else:
                    # Resolve type names to TypeSpec
                    type_spec = TypeSpec(type_info)
                self.members.append((member_name, type_spec))
        
        self._calculate_layout()
    
    def _calculate_layout(self):
        """Calculate member offsets and total size"""
        offset = 0
        for member_name, type_spec in self.members:
            self.offsets[member_name] = offset
            offset += type_spec.size
        self.size = offset
    
    def get_member_offset(self, member_name):
        """Get the byte offset of a member within the struct"""
        if member_name not in self.offsets:
            raise ValueError(f"Struct has no member: {member_name}")
        return self.offsets[member_name]
    
    def get_member_type(self, member_name):
        """Get the TypeSpec for a member"""
        for name, type_spec in self.members:
            if name == member_name:
                return type_spec
        raise ValueError(f"Struct has no member: {member_name}")
    
    def __repr__(self):
        name_str = self.name if self.name else "anonymous"
        return f"StructDefinition({name_str}, size={self.size}, members={len(self.members)})"


class StructRegistry:
    """Manages struct definitions"""
    
    def __init__(self):
        self.structs = {}  # tag_name -> StructDefinition
    
    def add_struct(self, struct_def):
        """Register a struct definition"""
        if struct_def.name is None:
            raise ValueError("Cannot register anonymous struct")
        if struct_def.name in self.structs:
            raise ValueError(f"Struct already defined: {struct_def.name}")
        self.structs[struct_def.name] = struct_def
    
    def get_struct(self, name):
        """Look up a struct definition by tag name"""
        if name not in self.structs:
            raise ValueError(f"Unknown struct: {name}")
        return self.structs[name]
    
    def has_struct(self, name):
        """Check if struct is defined"""
        return name in self.structs


class TypeSpec:
    """
    Represents a complete type specification including base type,
    qualifiers, pointers, arrays, and struct types.
    """
    
    TYPE_SPECIFIERS = {
        'void', 'char', 'short', 'int', 'long', 
        'float', 'double', 'signed', 'unsigned',
        '_Bool', '_Complex', '_Imaginary'
    }
    
    TYPE_QUALIFIERS = {'const', 'restrict', 'volatile'}
    
    def __init__(self, type_names, qualifiers=None, pointer_level=0, array_dims=None):
        """
        Create a TypeSpec from type names (resolving typedefs automatically).
        Uses global registries set via set_type_context().
        
        Args:
            type_names: String or list of type specifier strings
                       (e.g., 'uint8_t', ['unsigned', 'char'], ['struct', 'Point'])
            qualifiers: Additional qualifiers to add (optional)
            pointer_level: Number of pointer indirections
            array_dims: List of array dimensions
        """
        # Handle string input (convert to list)
        if isinstance(type_names, str):
            type_names = [type_names]
        
        self.pointer_level = pointer_level
        self.array_dims = array_dims or []
        self.qualifiers = set(qualifiers) if qualifiers else set()
        self.struct_def = None
        
        # Resolve the type using global registries
        self._resolve_type(type_names)
        
        # Calculate size
        self._calculate_size()
    
    def _resolve_type(self, type_names):
        """Resolve type names to base type, handling typedefs and structs"""
        typedef_registry = get_typedef_registry()
        struct_registry = get_struct_registry()
        
        specs = []
        struct_name = None
        
        # First pass: extract qualifiers and resolve typedefs
        resolved_names = []
        for t in type_names:
            if t in self.TYPE_QUALIFIERS:
                self.qualifiers.add(t)
            elif typedef_registry and typedef_registry.is_typedef(t):
                # Resolve typedef
                resolved = typedef_registry.resolve(t)
                if isinstance(resolved, TypeSpec):
                    # Already a TypeSpec - copy its properties and apply modifiers
                    self.base_type = resolved.base_type
                    self.qualifiers |= resolved.qualifiers
                    self.pointer_level += resolved.pointer_level
                    if resolved.array_dims:
                        self.array_dims = resolved.array_dims + self.array_dims
                    self.struct_def = resolved.struct_def
                    self.signed = resolved.signed
                    return
                elif isinstance(resolved, list):
                    # Typedef maps to type name list - expand it
                    resolved_names.extend(resolved)
                else:
                    resolved_names.append(t)
            else:
                resolved_names.append(t)
        
        # Use resolved names if we expanded any typedefs
        if resolved_names:
            type_names = resolved_names
        
        # Check for struct type
        if 'struct' in type_names:
            idx = type_names.index('struct')
            if idx + 1 < len(type_names):
                struct_name = type_names[idx + 1]
            
            if struct_name and struct_registry:
                self.struct_def = struct_registry.get_struct(struct_name)
                self.base_type = 'struct'
                self.signed = False  # Not applicable
                return
            else:
                raise ValueError(f"Undefined struct: {struct_name}")
        
        # Separate type specifiers
        for t in type_names:
            if t in self.TYPE_QUALIFIERS:
                continue  # Already collected
            elif t in self.TYPE_SPECIFIERS:
                specs.append(t)
        
        # Determine signedness
        self.signed = True
        if 'unsigned' in specs:
            self.signed = False
            specs.remove('unsigned')
        if 'signed' in specs:
            self.signed = True
            specs.remove('signed')
        
        # Parse base type
        if not specs:
            self.base_type = 'int'
        elif specs == ['void']:
            self.base_type = 'void'
        elif specs == ['char']:
            self.base_type = 'unsigned char' if not self.signed else 'signed char'
        elif specs == ['short'] or specs == ['short', 'int']:
            self.base_type = 'unsigned short' if not self.signed else 'signed short'
        elif specs == ['int']:
            self.base_type = 'unsigned int' if not self.signed else 'signed int'
        elif specs == ['long'] or specs == ['long', 'int']:
            self.base_type = 'unsigned long' if not self.signed else 'signed long'
        elif specs == ['_Bool']:
            self.base_type = '_Bool'
            self.signed = False
        else:
            raise ValueError(f"Invalid type specifier combination: {specs}")
    
    def _calculate_size(self):
        """Calculate the size of this type in bytes"""
        # Pointers are always 2 bytes
        if self.pointer_level > 0:
            self.size = 2
            return
        
        # Arrays multiply base size by dimensions
        if self.array_dims:
            base_size = self._get_base_size()
            self.size = base_size
            for dim in self.array_dims:
                self.size *= dim
            return
        
        # Otherwise, use base type size
        self.size = self._get_base_size()
    
    def _get_base_size(self):
        """Get size of base type (not considering arrays/pointers)"""
        if self.base_type == 'struct':
            if self.struct_def is None:
                raise ValueError("Struct type without definition")
            return self.struct_def.size
        
        size_map = {
            'void': 0,
            'char': 1, 'signed char': 1, 'unsigned char': 1,
            'short': 2, 'signed short': 2, 'unsigned short': 2,
            'int': 2, 'signed int': 2, 'unsigned int': 2,
            'long': 4, 'signed long': 4, 'unsigned long': 4,
            '_Bool': 1,
        }
        
        if self.base_type not in size_map:
            raise ValueError(f"Unknown base type: {self.base_type}")
        
        return size_map[self.base_type]
    
    @property
    def is_pointer(self):
        """Check if this is a pointer type"""
        return self.pointer_level > 0
    
    @property
    def is_array(self):
        """Check if this is an array type"""
        return len(self.array_dims) > 0
    
    @property
    def is_struct(self):
        """Check if this is a struct type"""
        return self.base_type == 'struct'
    
    @property
    def element_type(self):
        """Get the type of array elements or pointer target"""
        if not (self.is_array or self.is_pointer):
            raise ValueError("Not an array or pointer type")
        
        if self.is_pointer:
            # Return same type with one less pointer level
            return TypeSpec(
                [self.base_type] if self.base_type != 'struct' else ['struct', self.struct_def.name],
                qualifiers=self.qualifiers,
                pointer_level=self.pointer_level - 1,
                array_dims=self.array_dims.copy()
            )
        else:  # array
            dims = self.array_dims[1:] if len(self.array_dims) > 1 else []
            return TypeSpec(
                [self.base_type] if self.base_type != 'struct' else ['struct', self.struct_def.name],
                qualifiers=self.qualifiers,
                pointer_level=self.pointer_level,
                array_dims=dims
            )
    
    def __repr__(self):
        ptr = '*' * self.pointer_level
        arr = ''.join(f'[{d}]' for d in self.array_dims)
        return f"TypeSpec({self.base_type}{ptr}{arr}, size={self.size})"


class Variable:
    """Represents a variable with its storage location and type"""

    STORAGE_CLASS = {'typedef', 'extern', 'static', 'auto', 'register'}
     
    def __init__(self, name, type_spec, scope, offset=None, static_type='inline', storage_class=None):
        """
        Args:
            name: Variable name as used in C code
            type_spec: TypeSpec object describing the type
            scope: 'global', 'local', or 'param'
            offset: stack frame offset (for local/param vars)
            static_type: 'inline' or 'asm_var'
            storage_class: Storage class specifier ('static', 'extern', etc.)
        """
        self.name = name
        self.type_spec = type_spec
        self.scope = scope
        self.offset = offset
        self.static_type = static_type
        self.storage_class = storage_class
        
        # Validate scope
        if self.scope in ('local', 'param') and self.offset is None:
            raise ValueError(f"{scope} variable requires offset")
        if self.scope == 'global' and self.offset is not None:
            raise ValueError(f"global variable should not have offset")

        # For static vars, define assembly name
        self.asm_name = None
        if self.is_static:
            if self.static_type == 'inline':
                self.asm_name = f".{self.name}_{id(self)}"
            elif self.static_type == 'asm_var':
                self.asm_name = f"${self.name}_{id(self)}"
            else:
                raise ValueError("static_type must be inline or asm_var")
 
    @property
    def size(self):
        """Get size in bytes"""
        return self.type_spec.size
    
    @property
    def is_pointer(self):
        """Check if variable is a pointer"""
        return self.type_spec.is_pointer
    
    @property
    def is_array(self):
        """Check if variable is an array"""
        return self.type_spec.is_array
    
    @property
    def is_struct(self):
        """Check if variable is a struct"""
        return self.type_spec.is_struct
    
    @property
    def signed(self):
        """Check if type is signed"""
        return self.type_spec.signed
    
    def __repr__(self):
        ret = f"Variable('{self.name}', {self.type_spec}, '{self.scope}'"
        if not self.is_static:
            ret += f", offset={self.offset}"
        if self.static_type != 'inline':
            ret += f", static_type='{self.static_type}'"
        ret += ")"
        return ret

    def __str__(self):
        if self.is_static:
            return f"Cvar[{self.name}] {self.type_spec} scope={self.scope} label={self.asm_name}"
        else:
            return f"Cvar[{self.name}] {self.type_spec} scope={self.scope} frame_offset={self.offset}"
    
    @property
    def is_static(self):
        """Check if variable has static storage duration"""
        return self.storage_class == 'static' or self.scope == 'global'

    @property
    def is_volatile(self):
        """Check if variable is volatile"""
        return 'volatile' in self.type_spec.qualifiers

    @property
    def is_const(self):
        """Check if variable is const"""
        return 'const' in self.type_spec.qualifiers

    def emit_static_declaration(self, emitter):
        """Generate assembly that defines the static var"""
        if not self.is_static:
            return
        
        # For arrays and structs, emit appropriate sized storage
        if self.static_type == 'inline':
            emitter(f'{self.asm_name} "' + "\\0"*self.size + '"')
        elif self.static_type == 'asm_var':
            if self.size == 1:
                emitter(f'VAR global byte {self.asm_name}')
            elif self.size == 2:
                emitter(f'VAR global word {self.asm_name}')
            else:
                emitter(f'VAR global {self.size} {self.asm_name}')

    def emit_load(self, emitter, index_expr=None):
        """
        Generate assembly to load this variable into A register.
        
        Args:
            emitter: Function that takes assembly code strings
            index_expr: For arrays, the index expression (already in A)
        """
        self.emit("# begin emit_load for {self.name}")
        # Arrays decay to pointers - load address instead
        if self.is_array and index_expr is None:
            self.emit_address(emitter)
            return
        
        # Handle array element access
        if index_expr is not None:
            self._emit_indexed_load(emitter)
            return
        
        # Scalar load
        base_size = self.type_spec._get_base_size() if not self.is_pointer else 2
        
        if self.is_static:
            if base_size == 2:
                emitter(f"LD16_A {self.asm_name}")
            elif base_size == 1:
                emitter(f"LD_AL {self.asm_name}")
                self._emit_extend(2, emitter)
            else:
                raise NotImplementedError(f"Cannot load {base_size}-byte global")
        elif self.scope in ('local', 'param'):
            emitter(f"LDI_BL {self.offset}")
            if base_size == 2:
                emitter("CALL :frame_load_BL_A")
            elif base_size == 1:
                emitter("CALL :frame_load_BL_AL")
                self._emit_extend(2, emitter)
            else:
                raise NotImplementedError(f"Cannot load {base_size}-byte type")
        else:
            raise ValueError(f"Unknown scope: {self.scope}")
        self.emit("# {self.name} is now in A")
    
    def _emit_indexed_load(self, emitter):
        """Load array element - index is already in A"""
        element_size = self.type_spec.element_type.size
        
        self.emit("# begin _emit_indexed_load for {self.name}")
        # Scale index by element size if needed
        if element_size > 1:
            emitter(f"# Scale index by element size {element_size}")
            num_shifts = math.log(element_size, 2)
            if int(num_shifts) == num_shifts:
                for idx in range(int(num_shifts)):
                    emitter("CALL :shift16_a_left")
            else:
                # Use :mul16 for anything where we can't do a simple shift
                emitter("CALL :heap_push_A")
                emitter(f"LDI_A {element_size}")
                emitter("CALL :heap_push_A")
                emitter("CALL :mul16")  # Result on heap
                emitter("CALL :heap_pop_A", "Scaled index in A")
                emitter("CALL :heap_pop_word", "Discard high word of multiplication")
        
        # Add to base address
        emitter("ALUOP_PUSH %A%+%AH%", "Save scaled index")
        emitter("ALUOP_PUSH %A%+%AL%")
        self.emit_address(emitter)  # Get base address in A
        emitter("POP_BL", "Restore index to B")
        emitter("POP_BH")
        emitter("CALL :add16_to_a", "# A = base + index")
        
        # Load from computed address (A now points to element)
        element_size = self.type_spec.element_type.size
        if element_size == 1:
            emitter("LDA_A_CL")
            emitter("MOV_CL_AL")
            self._emit_extend(2, emitter)
        elif element_size == 2:
            emitter("LDA_A_CH")
            emitter("CALL :incr16_a")
            emitter("LDA_A_CL")
            emitter("MOV_CH_AH")
            emitter("MOV_CL_AL")
        else:
            raise NotImplementedError(f"Cannot load {element_size}-byte array element")
        self.emit("# end _emit_indexed_load for {self.name}")
    
    def emit_store(self, emitter):
        """Generate assembly to store A register to this variable"""
        base_size = self.type_spec._get_base_size() if not self.is_pointer else 2
        
        self.emit("# begin emit_store for {self.name}")
        if self.is_static:
            if base_size == 2:
                emitter(f"ST_AH {self.asm_name}")
                emitter(f"ST_AL {self.asm_name}+1")
            elif base_size == 1:
                emitter(f"ST_AL {self.asm_name}")
            else:
                raise NotImplementedError(f"Cannot store {base_size}-byte global")
        elif self.scope in ('local', 'param'):
            emitter(f"LDI_BL {self.offset}")
            if base_size == 2:
                emitter("CALL :frame_store_BL_A")
            elif base_size == 1:
                emitter("CALL :frame_store_BL_AL")
            else:
                raise NotImplementedError(f"Cannot store {base_size}-byte type")
        else:
            raise ValueError(f"Unknown scope: {self.scope}")
        self.emit("# end emit_store for {self.name}")
    
    def _emit_extend(self, to_size, emitter):
        """Emit code to extend value in A to larger size"""
        base_size = self.type_spec._get_base_size()
        if base_size == 1 and to_size == 2:
            if self.signed:
                emitter("LDI_BL 0x80", "Sign-extend AL to 16-bit")
                emitter("ALUOP_FLAGS %A&B%+%AL%+%BL%")
                label = f".sext_{id(self)}"
                emitter("LDI_AH 0x00")
                emitter(f"JZ {label}")
                emitter("LDI_AH 0xff")
                emitter(f"{label}")
            else:
                emitter("LDI_AH 0x00", "Zero-extend AL to 16-bit")
        elif base_size == 2 and to_size == 4:
            raise NotImplementedError("32-bit types not yet supported")
    
    def emit_address(self, emitter):
        """Generate assembly to load the address of this variable into A"""
        emitter(f"# begin emit_address of {self.scope} variable {self.name} into A")
        if self.scope == 'global':
            emitter(f"LDI_A {self.asm_name}")
        elif self.scope in ('local', 'param'):
            emitter("MOV_DH_AH")
            emitter("MOV_DL_AL")
            emitter(f"LDI_B {self.offset}")
            emitter("CALL :add16_to_a")
        else:
            raise ValueError(f"Unknown scope: {self.scope}")
        emitter("# end emit_address")
    
    def emit_member_access(self, member_name, emitter):
        """
        Generate code to access a struct member.
        Loads the address of the member into A.
        """
        if not self.is_struct:
            raise ValueError(f"Variable {self.name} is not a struct")
        
        struct_def = self.type_spec.struct_def
        member_offset = struct_def.get_member_offset(member_name)

        emitter(f"# begin emit_member_access of {self.name} member {member_name} into A")
        
        # Get base address of struct
        self.emit_address(emitter)
        
        # Add member offset
        if member_offset > 0:
            emitter(f"LDI_B {member_offset}", "Add member offset")
            emitter("CALL :add16_to_a")
        
        # Now A points to the member - caller can load/store as needed
        emitter(f"# end emit_member_access of {self.name} member {member_name} into A")

    @staticmethod
    def promote(var1, var2):
        """C integer promotion rules for binary operations"""
        # Pointer + integer or vice versa: keep pointer type
        if var1.is_pointer or var2.is_pointer:
            return var1 if var1.is_pointer else var2
        
        # Larger size wins
        if var1.size != var2.size:
            return var1 if var1.size > var2.size else var2
        
        # Same size: unsigned wins
        if var1.signed != var2.signed:
            return var1 if not var1.signed else var2
        
        return var1


class VariableTable:
    """Manages variable scopes and lookups"""
    
    def __init__(self):
        self.globals = {}
        self.scopes = []
    
    def push_scope(self):
        """Enter a new scope"""
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
        """Look up a variable by name"""
        for scope in reversed(self.scopes):
            if name in scope:
                return scope[name]
        
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
