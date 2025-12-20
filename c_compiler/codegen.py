import sys
from pycparser import c_ast
from typespecbuilder import TypeSpecBuilder
from typespec import TypeSpec
from variables import Variable
from function import Function
from pprint import pprint
from contextlib import contextmanager
from copy import deepcopy
import ast

from dataclasses import dataclass
from typing import Optional

@dataclass
class LValueInfo:
    """Information needed to read from or write to a location"""
    var: Variable
    kind: str  # 'simple', 'array', 'pointer_deref'
    lvalue_in_b: bool = False  # If True, B register contains the lvalue address
    # For 'array': lvalue_in_b=True, address is in B register
    # For 'simple': lvalue_in_b=False, use var.offset or var.name directly

@dataclass
class ExprContext:
    """Result of evaluating an expression"""
    typespec: Optional[TypeSpec] = None
    lvalue_info: Optional[LValueInfo] = None
    const_int: Optional[int] = None
    # Value is always in A/AL register after expression evaluation
    # If lvalue_info is not None and lvalue_in_b=True, address is in B register

class CodeGenerator(c_ast.NodeVisitor, TypeSpecBuilder):
    """
    Visitor that generates Odyssey assembly from an AST
    """

    def __init__(self, context, output=sys.stdout):
        self.context = context
        self.output = output
        self.current_function = None
        self.func_return_label = []
        self.param_offset = None
        self.local_offset = None
        self.label_num = 0
        self.expr_stack = []

        # required for TypeSpecBuilder to ensure TypeSpec objects have a reference to the registry
        self.type_registry = self.context.typereg

    def _push_expr(self, typespec, lvalue_info=None, const_int=None):
        self.expr_stack.append(ExprContext(typespec, lvalue_info, const_int=const_int))

    def _pop_expr(self) -> ExprContext:
        if not self.expr_stack:
            raise ValueError("Expression stack underflow")
        return self.expr_stack.pop()

    def _peek_expr(self) -> ExprContext:
        if not self.expr_stack:
            return None
        return self.expr_stack[-1]

    @contextmanager
    def _debug_block(self, name: str, min_verbose: int = 1):
        """Emit debug comments for begin/end of operation block"""
        if self.context.verbose >= min_verbose:
            self.emit(f"# Begin {name}")
        try:
            yield
        finally:
            if self.context.verbose >= min_verbose:
                self.emit(f"# End {name}")

    def emit(self, asm, comment=None):
        if comment:
            print(f"{asm:<32} # {comment}", file=self.output)
        else:
            print(asm, file=self.output)

    def generic_visit(self, node):
        name = None
        if hasattr(node, 'name') and node.name:
            name = node.name
            if hasattr(name, 'name') and name.name:
                name = name.name
        self.emit(f"# \033[1;33m ⚠⚠ !!!!!!!! TODO {node.__class__.__name__} {name} !!!!!!!!  ⚠⚠\033[0m")
        for c in node:
            self.visit(c)

    def visit_FileAST(self, node):
        # Generate initialization code: Decl nodes at the top level
        self.emit("# Global var initialization")
        for c in node:
            if isinstance(c, c_ast.Decl):
                self.visit(c)
        # Initialize static local vars from each function
        for c in node:
            if isinstance(c, c_ast.FuncDef):
                self._generate_static_localvar_init(c)

        # If told to jump to the main function, and the main function
        # exists, insert the JMP instruction here
        if self.context.jmp_to_main and 'main' in self.context.funcreg:
            self.emit(f"JMP {self.context.funcreg['main'].asm_name()}")
        # Generate all the code
        for c in node:
            if not isinstance(c, c_ast.Decl):
                self.visit(c)
        # Finish the code by listing global/static vars and constant literals
        self.emit("")
        self.emit("# Constant literals")
        for literal in self.context.literalreg.get_all_literals():
            self.emit(f"{literal.label} {literal.asm()}")
        prefix = self._get_static_prefix()
        local_statics = self.context.vartable.get_all_local_statics()
        if local_statics:
            self.emit("# Static local variables")
            for var in local_statics:
                if prefix == '$':
                    if var.typespec.sizeof() == 1:
                        self.emit(f"VAR global byte ${var.padded_name()}")
                    elif var.typespec.sizeof() == 2:
                        self.emit(f"VAR global word ${var.padded_name()}")
                    else:
                        self.emit(f"VAR global {var.typespec.sizeof()} ${var.padded_name()}")
                else:
                    self.emit(f'.{var.padded_name()} "' + '\\0'*var.typespec.sizeof() + '"')
        globals = self.context.vartable.get_all_globals()
        if globals:
            self.emit("# Global variables")
            for var in globals:
                if prefix == '$':
                    if var.typespec.sizeof() == 1:
                        self.emit(f"VAR global byte ${var.padded_name()}")
                    elif var.typespec.sizeof() == 2:
                        self.emit(f"VAR global word ${var.padded_name()}")
                    else:
                        self.emit(f"VAR global {var.typespec.sizeof()} ${var.padded_name()}")
                else:
                    self.emit(f'.{var.padded_name()} "' + '\\0'*var.typespec.sizeof() + '"')


    def visit_EmptyStatement(self, node):
        # Not even sure why this exists in the AST, it has no code
        # associated and no children...
        pass

    def visit_Typedef(self, node):
        # We already collected types in earlier passes, now stored
        # in context.typereg, so we can skip over these nodes
        pass

    def _generate_static_localvar_init(self, node, **kwargs):
        """
        We generate the initialization code for function's static
        local vars outside the FuncDef itself, and we call into
        this function from visit_FileAST so that the static local
        vars are initialized only once, along with the globals.
        """
        if isinstance(node, c_ast.FuncDef):
            self._generate_static_localvar_init(node.body, funcname=node.decl.name)
        elif isinstance(node, c_ast.Decl) and 'static' in node.storage and node.init:
            self.emit(f"# function {kwargs['funcname']} static local var {node.name} init")
            typespec = self._build_typespec(node.name, node.type)
            var = Variable(name=node.name, typespec=typespec, storage_class='static')
            self._initialize_var(node.init, var)
        else:
            for c in node:
                self._generate_static_localvar_init(c, **kwargs)

    def visit_FuncDef(self, node):
        # We already collected functions in earlier passes, now stored
        # in context.funcreg, so we don't need to descend into the Decl
        # node, just get the name and descend into the body
        self.current_function = self.context.funcreg[node.decl.name]
        self.local_offset = 0
        self.context.vartable.push_scope()

        # Function header and prologue
        self.emit("")
        if self.context.verbose >= 1:
            self.emit(f"# Begin FuncDef Decl for {node.decl.name}")
        if self.current_function.storage == 'static':
            self.emit(f'.{self.current_function.name}', self.current_function.c_str())
        else:
            self.emit(f':{self.current_function.name}', self.current_function.c_str())
        self.func_return_label.append(f".{self.current_function.name}_return")
        self.emit_stackpush()

        # Set frame pointer
        self.emit("LD_DH $heap_ptr", "Set frame pointer")
        self.emit("LD_DL $heap_ptr+1", "Set frame pointer")

        # Local variable memory allocation
        localvar_space = self._total_localvar_size(node)
        if self.context.verbose >= 1:
            self.emit(f"# Found {localvar_space} bytes of local vars in this function")
        # Register parameter vars in context
        self.param_offset = 0
        self.visit(node.decl.type)
        if self.context.verbose >= 1:
            self.emit(f"# Found {self.param_offset * -1} bytes of param vars in this function")
        retreat_bytes = localvar_space + (self.param_offset * -1)
        self.param_offset = None
        if localvar_space > 0:
            self.emit(f"LDI_BL {localvar_space}", "Bytes to allocate for local vars")
            self.emit(f"CALL :heap_advance_BL")

        # Generate function body, including local var allocation and initialization
        if self.context.verbose >= 2:
            self.emit("# Begin function body")
        self.visit(node.body)
        if self.context.verbose >= 2:
            self.emit("# End function body")

        # Function epilogue
        self.emit(self.func_return_label[-1])
        self.func_return_label.pop()

        if retreat_bytes:
            self.emit(f"LDI_BL {retreat_bytes}", "Bytes to free from local vars and parameters")
            self.emit(f"CALL :heap_retreat_BL")

        if self.current_function.return_type.sizeof() == 0:
            self.emit("# void function, no push to heap")
        elif self.current_function.return_type.sizeof() == 1:
            self.emit("CALL :heap_push_AL", "Return value")
        elif self.current_function.return_type.sizeof() == 2:
            self.emit("CALL :heap_push_A", "Return value")
        else:
            raise NotImplementedError("Unable to return from function with > 2 bytes")

        # Unroll scope context
        self.emit_stackpop()
        self.context.vartable.pop_scope()
        self.local_offset = None
        self.current_function = None

        # Return
        self.emit("RET")

        if self.context.verbose >= 1:
            self.emit(f"# End FuncDef Decl for {node.decl.name}")

    def visit_FuncDecl(self, node):
        # visited when generating code from a FuncDef node. We need
        # to collect the parameter variables and register them in the
        # current scope, noting their offset in the stack frame
        if self.param_offset is None:
            raise ValueError("Unexpected entry into FuncDecl without param_offset set")
        if node.args:
            for param_node in node.args:
                param_typespec = self._build_typespec(param_node.name, param_node.type)
                param_var = Variable(param_node.name, param_typespec, param_node.storage[0] if param_node.storage else '', offset=self.param_offset, kind='param')
                self.context.vartable.add_local(param_var)
                if self.context.verbose >= 1:
                    self.emit(f"# Registered param var {param_var} at offset {self.param_offset}")
                self.param_offset -= param_typespec.sizeof()

    def visit_FuncCall(self, node):
        func = self.context.funcreg.lookup(node.name.name)
        if not func:
            raise ValueError(f"FuncCall to function {node.name.name} that does not exist in function registry")

        if func.storage == 'extern':
            if func.name.startswith('trace'):
                pass
            elif hasattr(self, f"generate_FuncCall_{func.name}"):
                getattr(self, f"generate_FuncCall_{func.name}")(node, func)
                return
            else:
                raise NotImplementedError(f"No generate_FuncCall_{func.name} function found to generate call to extern {func.name} function")

        if self.context.verbose >= 1:
            self.emit(f"# Begin function call {func.c_str()}")
        arg_nodes = reversed(node.args.exprs) if node.args else []
        param_types = reversed(func.parameters.values())
        for arg_node, param_type in zip(arg_nodes, param_types):
            if self.context.verbose >= 1:
                self.emit(f"# Begin pushing param {param_type.c_str()}")
            self.visit(arg_node)
            arg_ctx = self._pop_expr()
            if param_type.sizeof() == 1:
                self.emit(f"CALL :heap_push_AL")
            elif param_type.sizeof() == 2:
                self.emit(f"CALL :heap_push_A")
            else:
                raise NotImplementedError("Unable to handle function args larger than 2 bytes")
            if self.context.verbose >= 1:
                self.emit(f"# End pushing param {param_type.c_str()}")
        self.emit(f"CALL {func.asm_name()}")
        if func.return_type.sizeof() == 0:
            self.emit("# function returns nothing, not popping a return value")
        elif func.return_type.sizeof() == 1:
            self.emit(f"CALL :heap_pop_AL")
        elif func.return_type.sizeof() == 2:
            self.emit(f"CALL :heap_pop_A")
        else:
            raise NotImplementedError("Unable to handle function calls that return more than 2 bytes")
        if self.context.verbose >= 1:
            self.emit(f"# End function call {func.c_str()}")
        self._push_expr(func.return_type)  # Return value now in A/AL

    def visit_Compound(self, node):
        if self.context.verbose >= 1:
            self.emit(f"# Begin Compound")
        self.context.vartable.push_scope()
        if node.block_items:
            for item in node.block_items:
                self.visit(item)
        self.context.vartable.pop_scope()
        if self.context.verbose >= 1:
            self.emit(f"# End Compound")

    def visit_ParamList(self, node):
        self.param_offset = 0
        self.visit(node.params)
        self.param_offset = None

    def visit_DeclList(self, node):
        for d in node.decls:
            with self._debug_block(f"DeclList: {d.name}"):
                self.visit(d)

    def visit_Decl(self, node):
        # skip function declarations, we already did that in an earlier pass
        if type(node.type) is c_ast.FuncDecl:
            return

        typespec = self._build_typespec(node.name, node.type)
        storage = node.storage[0] if node.storage else 'auto'
        var = Variable(name=node.name, typespec=typespec, storage_class=storage)
        if not self.current_function:
            var.kind = 'global'
            self.context.vartable.add_global(var)
            if node.init:
                self._initialize_var(node.init, var)
            return

        if self.param_offset is not None:
            var.kind = 'param'
            var.offset = self.param_offset
            self.param_offset -= var.typespec.sizeof()
            self.context.vartable.add_local(var)
            if node.init:
                self._initialize_var(node.init, var)
            return

        if self.local_offset is not None:
            var.kind = 'local'
            # we only allocate memory and perform initialization
            # for non-static local vars, because initialization
            # was already done for the static locals in visit_FileAST
            # along with the globals
            if var.storage_class != 'static':
                var.offset = self.local_offset+1
                self.local_offset += var.typespec.sizeof()
                if node.init:
                    self._initialize_var(node.init, var)
            self.context.vartable.add_local(var)
            return

    def _initialize_var(self, node, var):
        """
        Initialize a variable with a value from an expression.
        
        REGISTER STATE:
        - Entry: (none)
        - Exit: A/AL may be clobbered
        
        STACK EFFECT: Pops 1 ExprContext (initializer expression)
        """
        # get the initializer value into A register
        self.emit("")
        with self._debug_block(f"initialize {var.kind} variable {var.name}" +
                              (f" at offset {var.offset}" if var.kind not in ('global',) and var.storage_class != 'static' else "")):
            self.visit(node)  # A/AL now contains the value we need to store in the variable
            expr_ctx = self._pop_expr()
            self._store_a_to_var(var)

    def visit_ArrayRef(self, node):
        """
        Generate code for array indexing (e.g., arr[i]).
        
        REGISTER STATE:
        - Entry: (none)
        - Exit: A/AL = element value
                B = address of element (lvalue_in_b=True)
        
        STACK EFFECT: Pops 1 ExprContext (subscript), pushes 1 (element)
        """
        with self._debug_block("ArrayRef"):
            # Start by computing the subscript as an offset, stored in A
            subscript_ctx = None
            with self._debug_block("compute ArrayRef subscript"):
                self.visit(node.subscript)
                subscript_ctx = self._pop_expr()
                if subscript_ctx.typespec.sizeof() == 1:
                    self.emit_sign_extend("A", TypeSpec('int', 'int', _registry=self.type_registry))
            
            # var is the pointer variable, not the datatype being pointed to.
            assert isinstance(node.name, c_ast.ID)
            var = self.context.vartable.lookup(node.name.name)
            assert var.typespec.is_pointer

            # Scale the index by element size
            if var.typespec.sizeof_element() == 1:
                if self.context.verbose >= 1:
                    self.emit(f"# ArrayRef offset no change, {var.name} element size==1")
            elif var.typespec.sizeof_element() == 2:
                self.emit("CALL :shift16_a_left", f"ArrayRef offset doubles, {var.name} element size==2")
            else:
                raise NotImplementedError("Indexing into arrays of types > 2 bytes is not yet supported")

            # Get the base address 
            with self._debug_block("get indexed value address"):
                if var.kind == 'global' or var.storage_class == 'static':
                    prefix = self._get_static_prefix()
                    self.emit(f"LD16_B {prefix}{var.padded_name()}", f"Contents of {var.name} into B")
                else:
                    # save A (the index offset)
                    self.emit("ALUOP_PUSH %A%+%AH%", f"Save index offset")
                    self.emit("ALUOP_PUSH %A%+%AL%", f"Save index offset")
                    # Compute base address into C
                    self._compute_local_address_to_b(var)
                    # B now contains the address of the pointer. We need to dereference the pointer to get the base address of the array
                    self.emit("ALUOP_CH %B%+%BH%", f"Copy address of {var.name} to C")
                    self.emit("ALUOP_CL %B%+%BL%", f"Copy address of {var.name} to C")
                    self.emit("LDA_C_BH", f"Dereference {var.name} into B")
                    self.emit("INCR_C", f"Dereference {var.name} into B")
                    self.emit("LDA_C_BL", f"Dereference {var.name} into B")
                    # restore A (the index offset)
                    self.emit("POP_AL", f"Restore index offset into A")
                    self.emit("POP_AH", f"Restore index offset into A")

                # Now add A (index offset) and B (base address) to get the final address in B
                self.emit("CALL :add16_to_b", f"B contains indexed address into {var.name}")

                # Load the value into A/AL
                if var.typespec.sizeof_element() == 2:
                    self.emit("LDA_B_AH", f"Load {var.name}[index] into A")
                    self.emit("CALL :incr16_b")
                    self.emit("LDA_B_AL", f"Load {var.name}[index] into A")
                elif var.typespec.sizeof_element() == 1:
                    self.emit("LDA_B_AL", f"Load {var.name}[index] into AL")
                else:
                    raise NotImplementedError("Can't load datatypes > 2 bytes yet")
            
            # Push result: value in A/AL, address still in B
            self._push_expr(TypeSpec('arr_element', var.typespec.base_type), LValueInfo(var, 'array', lvalue_in_b=True), _registry=self.type_registry)

    def visit_StructRef(self, node):
        # TODO: be sure to self._push_expr member typespec
        self.generic_visit(node)

    def visit_Cast(self, node):
        """
        Cast a variable to a new type.  Renders the same
        code for node.expr but pops the typespec from the
        expression context and replaces it with the one
        from the to_type node.
        """
        self.visit(node.expr)

        from_context = self._pop_expr()
        to_typespec = self._build_typespec(from_context.typespec.name, node.to_type.type)
        to_lvalue = from_context.lvalue_info
        self._push_expr(to_typespec, to_lvalue, const_int=from_context.const_int)
        if from_context.typespec.sizeof() == 1 and to_typespec.sizeof() == 2:
            self.emit(f"# Above value in A is cast from {from_context.typespec.name}/{from_context.typespec.base_type} to {to_typespec.name}/{to_typespec.base_type}, requiring sign extension")
            self.emit_sign_extend("A", to_typespec)
            self.emit("# Above value in A is now cast to full 16 bit")
        else:
            self.emit(f"# Above value in A is cast from {from_context.typespec.name}/{from_context.typespec.base_type} to {to_typespec.name}/{to_typespec.base_type}")

    def visit_Assignment(self, node):
        with self._debug_block(f"Assignment {node.op} to {node.lvalue.name}"):
            # generate rvalue, result will be in A/AL
            with self._debug_block(f"Generate rvalue for assignment"):
                self.visit(node.rvalue)
            rvalue_context = self._pop_expr()
            var = self.context.vartable.lookup(node.lvalue.name)
            with self._debug_block(f"Assign to {var.name} at offset {var.offset}"):
                self._store_a_to_var(var)

    def visit_Constant(self, node):
        """
        Generate code for constants (integers, strings).
        
        REGISTER STATE:
        - Entry: (none)
        - Exit: A/AL = constant value
        
        STACK EFFECT: Pushes 1 ExprContext (constant, no lvalue)
        """
        if node.type == 'int':
            typespec = TypeSpec('int', 'int', _registry=self.type_registry)
        elif node.type == 'char':
            typespec = TypeSpec('char', 'char', _registry=self.type_registry)
        elif node.type == 'string':
            typespec = TypeSpec('string', 'char', is_pointer=True, pointer_depth=1, _registry=self.type_registry)
        else:
            raise NotImplementedError(f"I don't know how to represent a {node.type} constant")
        
        const_size = typespec.sizeof()

        const_int=None
        if node.type == 'int':
            if const_size == 1:
                self.emit(f"LDI_AL {node.value}", "Constant assignment")
                const_int = int(node.value, base=0)
            elif const_size == 2:
                self.emit(f"LDI_A {node.value}", "Constant assignment")
                const_int = int(node.value, base=0)
            else:
                raise NotImplementedError("Can't load constants > 16 bit")
        elif node.type == 'char':
            const_int = ord(ast.literal_eval(node.value))
            self.emit(f"LDI_AL {const_int}", f"Constant assignment ord({node.value}): {const_int}")
        elif node.type == 'string':
            literal = self.context.literalreg.lookup_by_content(node.value, node.type)
            if not literal:
                raise ValueError(f"Could not find literal in registry matching {node.value}")
            self.emit(f"LDI_A {literal.label}", literal.content)
        
        # Constants don't have lvalues
        self._push_expr(typespec, None, const_int=const_int)

    def visit_Return(self, node):
        """
        Generate code for return statement.
        
        REGISTER STATE:
        - Entry: (none)
        - Exit: A/AL = return value (if any)
                Jumps to function epilogue
        
        STACK EFFECT: Pops 1 ExprContext (if return has expression)
        """
        # Ensure that the value we're returning is in A/AL by generating
        # any child code, otherwise we assume the value is already in A/AL.
        # then jump to the end of the function.
        if node.expr:
            self.visit(node.expr)
            expr_ctx = self._pop_expr()  # discard the return type info, value is already in A/AL

        self.emit(f"JMP {self.func_return_label[-1]}", f"Return from {self.current_function.name}")

    def visit_UnaryOp(self, node):
        if self.context.verbose >= 1:
            self.emit(f"# Begin UnaryOp {node.op}")
        
        if node.op in ('++', '--', 'p++', 'p--'):
            # Pre/post increment/decrement - need lvalue
            is_postfix = node.op.startswith('p')
            is_increment = '+' in node.op
            
            self.visit(node.expr)
            expr_ctx = self._pop_expr()
            
            if not expr_ctx.lvalue_info:
                raise ValueError(f"UnaryOp {node.op} requires an lvalue")
            
            lvalue = expr_ctx.lvalue_info
            
            # Current value is in A
            if is_postfix:
                # Save original value for return
                self.emit("ALUOP_PUSH %A%+%AL%", f"Save original for postfix {node.op}")
                if expr_ctx.typespec.sizeof() == 2:
                    self.emit("ALUOP_PUSH %A%+%AH%", f"Save original for postfix {node.op}")
            
            # Increment/decrement
            if expr_ctx.typespec.sizeof() == 1:
                if is_increment:
                    self.emit("ALUOP_AL %A+1%+%AL%", f"UnaryOp {node.op}")
                else:
                    self.emit("ALUOP_AL %A-1%+%AL%", f"UnaryOp {node.op}")
            else:
                if is_increment:
                    self.emit("CALL :incr16_a", f"UnaryOp {node.op}")
                else:
                    self.emit("CALL :decr16_a", f"UnaryOp {node.op}")
            
            # Store back using lvalue information
            self._store_to_lvalue(expr_ctx)
            
            if is_postfix:
                # Restore original value for expression result
                if expr_ctx.typespec.sizeof() == 2:
                    self.emit("POP_AH", f"Restore original for postfix {node.op}")
                self.emit("POP_AL", f"Restore original for postfix {node.op}")
            
            # Result is in A, lvalue info preserved
            self._push_expr(expr_ctx.typespec, lvalue)
            
        elif node.op == '&':
            # Address-of operator
            self.visit(node.expr)
            expr_ctx = self._pop_expr()
            
            if not expr_ctx.lvalue_info:
                raise ValueError("Cannot take address of non-lvalue")
            
            lvalue = expr_ctx.lvalue_info
            
            if lvalue.lvalue_in_b:
                # Address is already in B, move to A
                self.emit("ALUOP_AH %B%+%BH%", "Address-of: copy address from B to A")
                self.emit("ALUOP_AL %B%+%BL%")
            else:
                # Compute address for simple variables
                var = lvalue.var
                if var.kind == 'global' or var.storage_class == 'static':
                    prefix = self._get_static_prefix()
                    self.emit(f"LDI_A {prefix}{var.padded_name()}", f"Address-of {var.name}")
                else:
                    # Local/param: frame pointer + offset
                    self._compute_local_address_to_a(var)
            
            # Result is a pointer to the original type
            result_typespec = TypeSpec(
                expr_ctx.typespec.name + '*',
                expr_ctx.typespec.base_type,
                is_pointer=True,
                pointer_depth=expr_ctx.typespec.pointer_depth + 1,
                _registry=self.type_registry,
            )
            self._push_expr(result_typespec, None)  # Addresses themselves don't have lvalues
            
        elif node.op == '*':
            # Pointer dereference
            self.visit(node.expr)
            expr_ctx = self._pop_expr()
            
            # A contains the pointer (address)
            # Move it to B for dereferencing
            self.emit("ALUOP_BH %A%+%AH%", "Pointer deref: address to B")
            self.emit("ALUOP_BL %A%+%AL%")
            
            # Determine pointed-to type
            if expr_ctx.typespec.pointer_depth < 1:
                raise ValueError("Cannot dereference non-pointer type")
            
            pointed_type = TypeSpec(
                expr_ctx.typespec.base_type,
                expr_ctx.typespec.base_type,
                is_pointer = False if expr_ctx.typespec.pointer_depth == 1 else True,
                pointer_depth=expr_ctx.typespec.pointer_depth - 1,
                _registry=self.type_registry,
            )
            
            # Load value from address in B
            if pointed_type.sizeof() == 1:
                self.emit("LDA_B_AL", "Pointer deref: load byte")
            elif pointed_type.sizeof() == 2:
                self.emit("LDA_B_AH", "Pointer deref: load high byte")
                self.emit("CALL :incr16_b")
                self.emit("LDA_B_AL", "Pointer deref: load low byte")
            else:
                raise NotImplementedError("Cannot deref pointers to types > 2 bytes")
            
            # Create a pseudo-variable for the lvalue
            pseudo_var = Variable("*deref", pointed_type, 'auto')
            self._push_expr(pointed_type, LValueInfo(pseudo_var, 'pointer_deref', lvalue_in_b=True))
            
        elif node.op == '-':
            # Unary negation
            self.visit(node.expr)
            expr_ctx = self._pop_expr()
            
            if expr_ctx.typespec.sizeof() == 1:
                self.emit("ALUOP_AL %~A%+%AL%", "Unary negation")
                self.emit("ALUOP_AL %A+1%+%AL%", "Unary negation")
            else:
                self.emit("ALUOP_AL %~A%+%AL%", "Unary negation")
                self.emit("ALUOP_AH %~A%+%AH%", "Unary negation")
                self.emit("CALL :incr16_a", "Unary negation")
            
            self._push_expr(expr_ctx.typespec, None)  # Result has no lvalue
            
        elif node.op == '~':
            # Bitwise NOT
            self.visit(node.expr)
            expr_ctx = self._pop_expr()
            
            if expr_ctx.typespec.sizeof() == 1:
                self.emit("ALUOP_AL %~A%+%AL%", "Bitwise NOT")
            else:
                self.emit("ALUOP_AL %~A%+%AL%", "Bitwise NOT low")
                self.emit("ALUOP_AH %~A%+%AH%", "Bitwise NOT high")
            
            self._push_expr(expr_ctx.typespec, None)  # Result has no lvalue
            
        elif node.op == '!':
            # Logical NOT
            self.visit(node.expr)
            expr_ctx = self._pop_expr()
            
            # Check if value is zero
            self.emit(f"ALUOP_FLAGS %A%+%AL%", "Logical NOT: check zero in low byte")
            self.emit(f"LDI_AL 0", "Logical NOT: assume false")
            self.emit(f"JNZ .logical_not_false_{self.label_num}")
            self.emit(f"LDI_AL 1", "Logical NOT: was zero, now true")
            self.emit(f".logical_not_false_{self.label_num}")
            self.label_num += 1
            
            result_type = TypeSpec('bool', 'bool', _registry=self.type_registry)
            self._push_expr(result_type, None)  # Result has no lvalue
        else:
            raise NotImplementedError(f"UnaryOp {node.op} not implemented")
        
        if self.context.verbose >= 1:
            self.emit(f"# End UnaryOp {node.op}")

    def _store_to_lvalue(self, expr_ctx: ExprContext):
        """Store value in A to the lvalue described by expr_ctx"""
        if not expr_ctx.lvalue_info:
            raise ValueError("Cannot store to expression without lvalue")
        
        lvalue = expr_ctx.lvalue_info
        var = lvalue.var
        
        if lvalue.lvalue_in_b:
            # Address is in B, value is in A
            
            if expr_ctx.typespec.sizeof() == 1:
                self.emit("ALUOP_ADDR_B %A%+%AL%", "Store byte in AL to lvalue in B")
            elif expr_ctx.typespec.sizeof() == 2:
                self.emit("ALUOP_ADDR_B %A%+%AH%", "Store high byte in AH to lvalue in B")
                self.emit("CALL :incr16_b")
                self.emit("ALUOP_ADDR_B %A%+%AL%", "Store low byte in AL to lvalue in B")
                self.emit("CALL :decr16_b", "Store: restore address")
            else:
                raise NotImplementedError("Cannot store types > 2 bytes")
        else:
            # Simple variable: use var.name or var.offset
            if var.kind == 'global' or var.storage_class == 'static':
                prefix = self._get_static_prefix()
                if expr_ctx.typespec.sizeof() == 1:
                    self.emit(f"ALUOP_ADDR %A%+%AL% {prefix}{var.padded_name()}", "Store to global/static")
                elif expr_ctx.typespec.sizeof() == 2:
                    self.emit(f"ALUOP_ADDR %A%+%AH% {prefix}{var.padded_name()}", "Store to global/static")
                    self.emit(f"ALUOP_ADDR %A%+%AL% {prefix}{var.padded_name()}+1", "Store to global/static")
            else:
                # Local/param: need to compute address
                self.emit("ALUOP_CH %A%+%AH%", "Store: value to C")
                self.emit("ALUOP_CL %A%+%AL%")
                self._compute_local_address_to_a(var)
                if expr_ctx.typespec.sizeof() == 1:
                    self.emit("STA_A_CL", f"Store to {var.name}")
                elif expr_ctx.typespec.sizeof() == 2:
                    self.emit("STA_A_CH", f"Store to {var.name}")
                    self.emit("CALL :incr16_a")
                    self.emit("STA_A_CL", f"Store to {var.name}")
                else:
                    raise NotImplementedError("Cannot store types > 2 bytes")

    def visit_BinaryOp(self, node):
        """
        Generate code for binary operations.
        
        REGISTER STATE:
        - Entry: (none)
        - Exit: A/AL = result value
        
        STACK EFFECT: Pops 2 ExprContext (left, right), pushes 1 (result)
        
        Supported operators:
        - Arithmetic: +, -, &, |, ^
        - Comparison: <, <=, >, >=, !=
        """
        with self._debug_block(f"BinaryOp {node.op}"):
            self.visit(node.right)  # RHS in A
            right_ctx = self._pop_expr()
            
            if right_ctx.typespec.sizeof() == 2:
                self.emit("ALUOP_PUSH %A%+%AH%", "Preserve RHS of binary op")
            if right_ctx.typespec.sizeof() >= 1:
                self.emit("ALUOP_PUSH %A%+%AL%", "Preserve RHS of binary op")
            
            self.visit(node.left)  # LHS in A
            left_ctx = self._pop_expr()
            
            if right_ctx.typespec.sizeof() >= 1:
                self.emit("POP_BL", "Set RHS of binary op")
            if right_ctx.typespec.sizeof() == 2:
                self.emit("POP_BH", "Set RHS of binary op")

            # RHS now in B

            if left_ctx.typespec.sizeof() > 2 or right_ctx.typespec.sizeof() > 2:
                raise NotImplementedError(f"Unable to perform BinaryOp on values with sizeof > 2: LHS {left_ctx.typespec} RHS {right_ctx.typespec}")
            
            # Sign extend if there is a size mismatch
            op_size = 1
            result_type = left_ctx.typespec
            if left_ctx.typespec.sizeof() != right_ctx.typespec.sizeof():
                if left_ctx.typespec.sizeof() == 1:
                    self.emit_sign_extend("A", left_ctx.typespec)
                    result_type = right_ctx.typespec
                if right_ctx.typespec.sizeof() == 1:
                    self.emit_sign_extend("B", right_ctx.typespec)
                    result_type = left_ctx.typespec
            elif left_ctx.typespec.sizeof() == 2:
                op_size = 2

            # Set a flag for whether we'll be doing signed or unsigned operation.
            # We have some optimization here to avoid signed operations if the
            # variable side of the comparison is unsigned and the constant side is
            # a positive integer.
            signed_op = False

            # If either context is signed and are not constant (e.g. a signed variable)
            # then we have to perform a signed op
            if left_ctx.typespec.is_signed() and left_ctx.const_int is None:
                signed_op = True
            elif right_ctx.typespec.is_signed() and right_ctx.const_int is None:
                signed_op = True

            # If one side is unsigned and the other is signed but is a positive constant integer,
            # treat it as an unsigned operation.
            elif not left_ctx.typespec.is_signed() and right_ctx.typespec.is_signed() and right_ctx.const_int is not None and right_ctx.const_int >= 0:
                signed_op = False
                self.emit("# NOTE: treating this as an unsigned op because LHS is unsigned, and RHS is a signed (but positive) constant integer")
            elif not right_ctx.typespec.is_signed() and left_ctx.typespec.is_signed() and left_ctx.const_int is not None and left_ctx.const_int >= 0:
                signed_op = False
                self.emit("# NOTE: treating this as an unsigned op because RHS is unsigned, and LHS is a signed (but positive) constant integer")

            # Fallthrough and perform signed op if either side is signed
            elif left_ctx.typespec.is_signed() or right_ctx.typespec.is_signed():
                signed_op = True

            # generate op code
            if node.op in ('+', '-', '&', '|', '^'):
                asm_op = node.op
                if node.op == '^':
                    asm_op = 'x'
                if op_size == 1:
                    self.emit(f"ALUOP_AL %A{asm_op}B%+%AL%+%BL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {asm_op} ({right_ctx.typespec.c_str()})")
                else:
                    if asm_op == '+':
                        self.emit("CALL :add16_to_a", f"BinaryOp ({left_ctx.typespec.c_str()}) {asm_op} ({right_ctx.typespec.c_str()})")
                    elif asm_op == '-':
                        self.emit("CALL :sub16_a_minus_b", f"BinaryOp ({left_ctx.typespec.c_str()}) {asm_op} ({right_ctx.typespec.c_str()})")
                    else:
                        self.emit(f"ALUOP_AL %A{asm_op}B%+%AL%+%BL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {asm_op} ({right_ctx.typespec.c_str()})")
                        self.emit(f"ALUOP_AH %A{asm_op}B%+%AH%+%BH%", f"BinaryOp ({left_ctx.typespec.c_str()}) {asm_op} ({right_ctx.typespec.c_str()})")
            elif node.op in ('<', '<=', '>', '>='):
                if signed_op:
                    # For < and <=, we use A - B; for > and >= we use B - A
                    lhs = 'A'
                    rhs = 'B'
                    if node.op in ('>', '>='):
                        lhs = 'B'
                        rhs = 'A'
                    sign_reg = 'H'

                    # For signed comparisons we do full 16-bit operations since we don't have
                    # an 8-bit signed-overflow-detecting subtraction function in math.asm
                    if op_size == 1:
                        self.emit(f"ALUOP_AL %{lhs}-{rhs}_signed%+%AL%+%BL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                        sign_reg = 'L'
                    elif op_size == 2:
                        self.emit(f"CALL :signed_sub16_{lhs.lower()}_minus_{rhs.lower()}", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()}) (result in A)")

                    # Check overflow flag: if (signed) overflow, we need to check the
                    # sign bit and compare against the operands.
                    self.emit(f"JO .binop_gtlt_overflow_{self.label_num}")

                    # No-signed-overflow case
                    # Check the sign bit - if set, return true, if clear, return false
                    if op_size == 2:
                        self.emit(f"ALUOP_PUSH %A%+%AH%", "Save result for later")
                    self.emit(f"ALUOP_PUSH %A%+%AL%", "Save result for later")
                    self.emit(f"ALUOP_FLAGS %Amsb%+%A{sign_reg}%", "check sign bit of result")
                    self.emit(f"LDI_AL 1", "No signed overflow, sign bit set = true")
                    self.emit(f"JNZ .binop_gtlt_no_overflow_signbit_set_{self.label_num}")
                    self.emit(f"LDI_AL 0", "No signed overflow, sign bit clear = false")
                    self.emit(f".binop_gtlt_no_overflow_signbit_set_{self.label_num}")
                    self.emit(f"JMP .binop_gtlt_next_{self.label_num}")

                    # Signed-overflow case
                    # Check the sign bit - if set, return false, if clear, return true
                    self.emit(f".binop_gtlt_overflow_{self.label_num}")
                    if op_size == 2:
                        self.emit(f"ALUOP_PUSH %A%+%AH%", "Save result for later")
                    self.emit(f"ALUOP_PUSH %A%+%AL%", "Save result for later")
                    self.emit(f"ALUOP_FLAGS %Amsb%+%A{sign_reg}%", "check sign bit of result")
                    self.emit(f"LDI_AL 0", "Signed overflow, sign bit set = false")
                    self.emit(f"JNZ .binop_gtlt_overflow_signbit_set_{self.label_num}")
                    self.emit(f"LDI_AL 1", "Signed overflow, sign bit clear = true")
                    self.emit(f".binop_gtlt_overflow_signbit_set_{self.label_num}")

                    # Continue computation
                    self.emit(f".binop_gtlt_next_{self.label_num}")
                    self.emit(f"POP_BL", "Restore result into B")
                    if op_size == 2:
                        self.emit(f"POP_BH", "Restore result into B")

                    # if this was a <= or >= then we still might end up true if the result was zero,
                    # but can skip all this if the above computation ended up with 0 (false) in AL.
                    if '=' in node.op:
                        self.emit(f"ALUOP_FLAGS %A%+%AL%", "No need to check equality if {node.op.strip('=')} is true")
                        self.emit(f"JNZ .binop_true_{self.label_num}")

                        if op_size == 2:
                            self.emit("ALUOP_FLAGS %B%+%BH%", "Check if high byte of result is zero")
                            self.emit(f"JZ .binop_high_zero_{self.label_num}")
                            self.emit(f"JMP .binop_false_{self.label_num}")
                            self.emit(f".binop_high_zero_{self.label_num}")
                        self.emit("ALUOP_FLAGS %B%+%BL%", "Check if low byte of result is zero")
                        self.emit(f"JZ .binop_true_{self.label_num}")
                        self.emit(f"JMP .binop_false_{self.label_num}")

                        self.emit(f".binop_true_{self.label_num}")
                        self.emit(f"LDI_AL 1")
                        self.emit(f".binop_false_{self.label_num}")
                    self.label_num += 1
                else: # unsigned op
                    # For < and <=, we use A - B; for > and >= we use B - A
                    if op_size == 1:
                        if node.op in ('<', '<='):
                            self.emit(f"ALUOP_FLAGS %A-B%+%AL%+%BL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                        elif node.op in ('>', '>='):
                            self.emit(f"ALUOP_FLAGS %B-A%+%AL%+%BL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                    else:
                        # Note that :sub16_a_minus_b/:sub16_b_minus_a does not reliably set the E or Z status bits, we can only trust the O bit,
                        if node.op in ('<', '<='):
                            self.emit(f"CALL :sub16_a_minus_b", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                        elif node.op in ('>', '>='):
                            self.emit(f"CALL :sub16_b_minus_a", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")

                    # For < and >, we only need to check the overflow bit
                    if node.op in ('<', '>'):
                        self.emit(f"LDI_AL 1")
                        self.emit(f"JO .binop_true_{self.label_num}")
                        self.emit(f"LDI_AL 0")
                        self.emit(f".binop_true_{self.label_num}")
                        self.label_num += 1
                    # for <= and >=, we need to check the overflow AND zero bits
                    elif node.op in ('<=', '>='):
                        if op_size == 1:
                            self.emit(f"LDI_AL 1")
                            self.emit(f"JO .binop_true_{self.label_num}")
                            self.emit(f"JZ .binop_true_{self.label_num}")
                            self.emit(f"LDI_AL 0")
                            self.emit(f".binop_true_{self.label_num}")
                            self.label_num += 1
                        else:
                            self.emit(f"JO .binop_true_{self.label_num}")
                            if node.op == '<=':
                                self.emit(f"ALUOP_FLAGS %A%+%AH%")
                            elif node.op == '>=':
                                self.emit(f"ALUOP_FLAGS %B%+%BH%")
                            self.emit(f"JNZ .binop_false_{self.label_num}")
                            if node.op == '<=':
                                self.emit(f"ALUOP_FLAGS %A%+%AL%")
                            elif node.op == '>=':
                                self.emit(f"ALUOP_FLAGS %B%+%BL%")
                            self.emit(f"JNZ .binop_false_{self.label_num}")
                            self.emit(f"JMP .binop_true_{self.label_num}")
                            self.emit(f".binop_false_{self.label_num}")
                            self.emit(f"LDI_AL 0")
                            self.emit(f"JMP .binop_done_{self.label_num}")
                            self.emit(f".binop_true_{self.label_num}")
                            self.emit(f"LDI_AL 1")
                            self.emit(f".binop_done_{self.label_num}")
                            self.label_num += 1
                result_type = TypeSpec('binop_result', 'bool', _registry=self.type_registry)
            elif node.op in ('==', '!='):
                if node.op == '==':
                    default_state = 'false'
                    default_value = '0'
                    other_value = '1'
                else:
                    default_state = 'true'
                    default_value = '1'
                    other_value = '0'
                self.emit(f"ALUOP_FLAGS %A-B%+%AL%+%BL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                self.emit(f"LDI_AL {default_value}")
                self.emit(f"JNZ .binop_{default_state}_{self.label_num}")
                if op_size > 1:
                    self.emit(f"ALUOP_FLAGS %A-B%+%AH%+%BH%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                    self.emit(f"JNZ .binop_{default_state}_{self.label_num}")
                self.emit(f"LDI_AL {other_value}")
                self.emit(f".binop_{default_state}_{self.label_num}")
                self.label_num += 1
                result_type = TypeSpec('binop_result', 'bool', _registry=self.type_registry)
            elif node.op in ('<<', '>>'):
                if right_ctx.const_int is not None:
                    for _ in range(right_ctx.const_int):
                        if op_size == 1:
                            if left_ctx.typespec.is_signed():
                                if node.op == '<<':
                                    self.emit(f"ALUOP_AL %A*2%+%AL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} {right_ctx.const_int}")
                                elif node.op == '>>':
                                    self.emit(f"ALUOP_AL %A/2%+%AL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} {right_ctx.const_int}")
                            else:
                                self.emit(f"ALUOP_AL %A{node.op}1%+%AL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} {right_ctx.const_int}")
                        else:
                            if left_ctx.typespec.is_signed():
                                raise NotImplementedError("Unable to shift signed 16-bit integers")
                            else:
                                if node.op == '<<':
                                    self.emit(f"CALL :shift16_a_left", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} {right_ctx.const_int}")
                                elif node.op == '>>':
                                    self.emit(f"CALL :shift16_a_right", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} {right_ctx.const_int}")
                else:
                    raise NotImplementedError("Unable to shift by variable amounts")
            else:
                raise NotImplementedError(f"BinaryOp {node.op} not implemented")

            # Result is in A, no lvalue
            self._push_expr(result_type, None)

    def visit_TernaryOp(self, node):
        # TODO be sure to self._push_expr(result typespec)
        self.generic_visit(node)

    def visit_ID(self, node):
        # ID is the name of a variable. Pull info from current scope
        # and put the variable into A/AL
        var = self.context.vartable.lookup(node.name)
        if not var:
            raise ValueError(f"Unable to find var {node.name} in variable table")

        if var.kind == 'global' or var.storage_class == 'static':
            prefix = self._get_static_prefix()
            self.emit(f"LDI_B {prefix}{var.padded_name()}", f"Set up address (lvalue) for {var.storage_class} {var.typespec.base_type} {var.name}")
            if var.typespec.sizeof() == 2:
                self.emit(f"LD16_A {prefix}{var.padded_name()}", f"Load {var.storage_class} {var.typespec.base_type} {var.name}")
            elif var.typespec.sizeof() == 1:
                self.emit(f"LD_AL {prefix}{var.padded_name()}", f"Load {var.storage_class} {var.typespec.base_type} {var.name}")
            else:
                raise ValueError(f"Unable to load var {var.name} as it's not 1 or 2 bytes")
        else:
            self._compute_local_address_to_b(var)
            if var.typespec.sizeof() == 2:
                self.emit("LDA_B_AH", f"Load var {var.name} at offset {var.offset}")
                self.emit("CALL :incr16_b", f"Load var {var.name} at offset {var.offset}")
            self.emit("LDA_B_AL", f"Load var {var.name} at offset {var.offset}")

        # Value in A, lvalue info for simple variable (address not in B)
        self._push_expr(var.typespec, LValueInfo(var, 'simple', lvalue_in_b=True))

    def visit_If(self,node):
        """
        Generate code for for conditionals
        
        STACK EFFECT: Pops ExprContext for cond
        """
        false_label = f".if_cond_false_{self.label_num}"
        end_label = f".if_cond_end_{self.label_num}"
        self.label_num += 1
        with self._debug_block("If block"):
            with self._debug_block("If block: condition"):
                # Generate the condition code, result will be in A
                self.visit(node.cond)
                self.emit("ALUOP_FLAGS %A%+%AL%", "Check if condition is true")
                if node.iffalse:
                    self.emit(f"JZ {false_label}")
                else:
                    self.emit(f"JZ {end_label}")
            with self._debug_block("If block: if-true"):
                self.visit(node.iftrue)
                self.emit(f"JMP {end_label}")
            if node.iffalse:
                with self._debug_block("If block: if-false"):
                    self.emit(false_label)
                    self.visit(node.iffalse)
            self.emit(end_label)

    def visit_DoWhile(self, node):
        """
        Generate code for Do-While loops

        stmt: code to run
        cond: condition
        """
        top_label = f".do_while_top_{self.label_num}"
        exit_label = f".do_while_exit_{self.label_num}"
        self.label_num += 1
        with self._debug_block("Do-While loop"):
            self.context.vartable.push_scope()
            self.emit(top_label, "Top of do-while loop")
            with self._debug_block("Do-While loop statement"):
                self.visit(node.stmt)
            with self._debug_block("Do-While loop condition"):
                self.visit(node.cond)
                # AL will contain 1 for true (continue looping) or 0 for false (end loop)
                self.emit("ALUOP_FLAGS %A%+%AL%", "Check if loop condition is true (1) or false (0)")
                self.emit(f"JZ {exit_label}", "Terminate loop if condition is false")
                self.emit(f"JMP {top_label}", "Continue loop if condition is true")
            self.emit(exit_label, "Bottom of do-while loop")
            self.context.vartable.pop_scope()

    def visit_While(self, node):
        """
        Generate code for While loops

        cond: condition
        stmt: code to run
        """
        top_label = f".while_top_{self.label_num}"
        exit_label = f".while_exit_{self.label_num}"
        self.label_num += 1
        with self._debug_block("While loop"):
            self.context.vartable.push_scope()
            self.emit(top_label, "Top of while loop")
            with self._debug_block("While loop condition"):
                self.visit(node.cond)
                # AL will contain 1 for true (continue looping) or 0 for false (end loop)
                self.emit("ALUOP_FLAGS %A%+%AL%", "Check if loop condition is true (1) or false (0)")
                self.emit(f"JZ {exit_label}", "Terminate loop if condition is false")
            with self._debug_block("Do-While loop statement"):
                self.visit(node.stmt)
            self.emit(f"JMP {top_label}", "Continue loop if condition is true")
            self.emit(exit_label, "Bottom of do-while loop")
            self.context.vartable.pop_scope()

    def visit_For(self, node):
        """
        Generate code for for loops: for(init; cond; next) stmt
        
        Structure:
            init
        loop_top:
            if (!cond) goto loop_exit
            stmt
            next
            goto loop_top
        loop_exit:
        
        REGISTER STATE:
        - Entry: (none)
        - Exit: undefined
        
        STACK EFFECT: Pops ExprContext for init, cond, next (if present)
        """
        with self._debug_block("For loop"):
            self.context.vartable.push_scope()
            with self._debug_block("For loop init"):
                self.visit(node.init)
            loop_top_label = f".for_loop_top_{self.label_num}"
            loop_exit_label = f".for_loop_exit_{self.label_num}"
            self.label_num += 1
            self.emit(loop_top_label, "For loop begin")
            with self._debug_block("For loop cond"):
                self.visit(node.cond)

                # AL will contain 1 for true (continue looping) or 0 for false (end loop)
                self.emit("ALUOP_FLAGS %A%+%AL%", "Check if loop condition is true (1) or false (0)")
                self.emit(f"JZ {loop_exit_label}", "Terminate loop if condition is false")
            with self._debug_block("For loop statement"):
                self.visit(node.stmt)
            if node.next:
                with self._debug_block("For loop next"):
                    self.visit(node.next)
            self.emit(f"JMP {loop_top_label}", "Continue for loop")
            self.emit(loop_exit_label, "For loop terminate")
            self.context.vartable.pop_scope()

    def _total_localvar_size(self, node) -> int:
        """
        Recursively descend into the entirety of node's AST searching for
        local, non-static variable declarations (excluding parameters) and
        total up their size.
        """
        # Don't count function parameters in local var size
        if type(node) is c_ast.ParamList:
            return 0
        if type(node) is c_ast.Decl and type(node.type) is not c_ast.FuncDecl:
            ts = self._build_typespec(node.name, node.type)
            if self.context.verbose >= 2:
                self.emit(f"# _total_localvar_size: Computing size of {node.name}, {node.type.__class__.__name__} = {ts.sizeof()}")
            return ts.sizeof()
        recursive_sum = 0
        for child in node:
            recursive_sum += self._total_localvar_size(child)
        return recursive_sum

    def emit_stackpush(self, skip=set()):
        for alupush in ('AL', 'AH', 'BL', 'BH'):
            if alupush in skip:
                continue
            self.emit(f"ALUOP_PUSH %{alupush[0]}%+%{alupush}%")
        for push in ('CL', 'CH', 'DL', 'DH'):
            if push in skip:
                continue
            self.emit(f"PUSH_{push}")

    def emit_stackpop(self, skip=set()):
        for pop in ('DH', 'DL', 'CH', 'CL', 'BH', 'BL', 'AH', 'AL'):
            if pop in skip:
                continue
            self.emit(f"POP_{pop}")

    def emit_sign_extend(self, reg: str, typespec: TypeSpec):
        otherreg = 'B'
        if reg == 'B':
            otherreg = 'A'
        if typespec.is_signed():
            self.emit(f"ALUOP_PUSH %{otherreg}%+%{otherreg}L%", f"Sign extend {reg}L: save {otherreg}L")
            self.emit(f"LDI_{otherreg}L 0x80", f"Sign extend {reg}L: check sign bit")
            self.emit(f"ALUOP_FLAGS %A&B%+%AL%+%BL%", f"Sign extend {reg}L: check sign bit")
            self.emit(f"POP_{otherreg}L", f"Sign extend {reg}L: restore {otherreg}L")
            self.emit(f"LDI_{reg}H 0x00", f"Sign extend {reg}L: assume sign bit not set")
            self.emit(f"JZ .sign_extend_{self.label_num}", f"Sign extend {reg}L: don't overwrite {reg}H if sign bit was not set")
            self.emit(f"LDI_{reg}H 0xff", f"Sign extend {reg}L: sign bit was set")
            self.emit(f".sign_extend_{self.label_num}", f"Sign extend {reg}L")
            self.label_num += 1
        else:
            self.emit(f"LDI_{reg}H 0x00", f"Sign extend {reg}L: unsigned value in AL")

    def _get_static_prefix(self):
        """Get the assembly prefix for static/global variables"""
        return '$' if self.context.static_type == 'asm_var' else '.'

    def _compute_local_address_to_b(self, var: Variable, comment: str = ""):
        """
        Compute address of local/param variable into B register.
        Frame pointer (D) + var.offset -> B
        Clobbers A register temporarily.
        """
        if not comment:
            comment = f"Compute address of {var.name} at offset {var.offset} into B"
        self.emit("MOV_DH_AH", comment)
        self.emit("MOV_DL_AL", comment)
        self.emit(f"LDI_B {var.offset}", comment)
        self.emit("CALL :add16_to_b", comment)

    def _compute_local_address_to_a(self, var: Variable, comment: str = ""):
        """
        Compute address of local/param variable into A register.
        Frame pointer (D) + var.offset -> A
        Clobbers B register temporarily.
        """
        if not comment:
            comment = f"Compute address of {var.name} at offset {var.offset} into A"
        self.emit("MOV_DH_AH", comment)
        self.emit("MOV_DL_AL", comment)
        self.emit(f"LDI_B {var.offset}", comment)
        self.emit("CALL :add16_to_a", comment)

    def _load_var_value_to_a(self, var: Variable):
        """
        Load variable value into A/AL register.
        
        REGISTER STATE:
        - Entry: (none)
        - Exit: A/AL = variable value
        """
        if var.kind == 'global' or var.storage_class == 'static':
            prefix = self._get_static_prefix()
            if var.typespec.sizeof() == 2:
                self.emit(f"LD16_A {prefix}{var.padded_name()}", f"Load {var.storage_class} {var.typespec.base_type} {var.name}")
            elif var.typespec.sizeof() == 1:
                self.emit(f"LD_AL {prefix}{var.padded_name()}", f"Load {var.storage_class} {var.typespec.base_type} {var.name}")
            else:
                raise ValueError(f"Unable to load var {var.name} as it's not 1 or 2 bytes")
        else:
            # Local/param variable: compute address and load
            self._compute_local_address_to_b(var)
            if var.typespec.sizeof() == 2:
                self.emit("LDA_B_AH", f"Load var {var.name} at offset {var.offset}")
                self.emit("CALL :incr16_b", f"Load var {var.name} at offset {var.offset}")
            self.emit("LDA_B_AL", f"Load var {var.name} at offset {var.offset}")

    def _store_a_to_var(self, var: Variable):
        """
        Store value in A/AL to variable (global, static, or local).
        
        REGISTER STATE:
        - Entry: A/AL = value to store
        - Exit: A/AL preserved, C register used as scratch
        """
        if var.kind == 'global' or var.storage_class == 'static':
            prefix = self._get_static_prefix()
            if var.typespec.sizeof() == 1:
                self.emit(f"ALUOP_ADDR %A%+%AL% {prefix}{var.padded_name()}", f"Store to {var.name}")
            elif var.typespec.sizeof() == 2:
                self.emit(f"ALUOP_ADDR %A%+%AH% {prefix}{var.padded_name()}", f"Store to {var.name}")
                self.emit(f"ALUOP_ADDR %A%+%AL% {prefix}{var.padded_name()}+1", f"Store to {var.name}")
        else:
            # Local/param: need to compute address
            self.emit("ALUOP_CH %A%+%AH%", "Store: value to C")
            self.emit("ALUOP_CL %A%+%AL%")
            self._compute_local_address_to_a(var)
            if var.typespec.sizeof() == 1:
                self.emit("STA_A_CL", f"Store to {var.name}")
            elif var.typespec.sizeof() == 2:
                self.emit("STA_A_CH", f"Store to {var.name}")
                self.emit("CALL :incr16_a")
                self.emit("STA_A_CL", f"Store to {var.name}")
            else:
                raise NotImplementedError("Cannot store types > 2 bytes")

    def generate_FuncCall_printf(self, node: c_ast.FuncCall, func: Function):
        """
        External printf function call
        """
        if self.context.verbose >= 1:
            self.emit(f"# Begin special extern function call {func.c_str()}")
        arg_nodes = [*enumerate(node.args.exprs)]
        for idx, arg_node in reversed(arg_nodes):
            if self.context.verbose >= 1:
                self.emit(f"# Begin pushing param idx {idx}")
            self.visit(arg_node)
            arg_ctx = self._pop_expr()
            if idx > 0:
                if arg_ctx.typespec.sizeof() == 1:
                    self.emit(f"CALL :heap_push_AL")
                elif arg_ctx.typespec.sizeof() == 2:
                    self.emit(f"CALL :heap_push_A")
                else:
                    raise NotImplementedError("Unable to handle function args larger than 2 bytes")
            else:
                self.emit("ALUOP_CH %A%+%AH%", f"Load format string pointer into C")
                self.emit("ALUOP_CL %A%+%AL%", f"Load format string pointer into C")
            if self.context.verbose >= 1:
                self.emit(f"# End pushing param idx {idx}")
        self.emit(f"CALL {func.asm_name()}")
        if self.context.verbose >= 1:
            self.emit(f"# End special extern function call {func.c_str()}")

    def generate_FuncCall_print(self, node: c_ast.FuncCall, func: Function):
        self.generate_FuncCall_printf(node, func)

    def generate_FuncCall_putchar(self, node: c_ast.FuncCall, func: Function):
        if self.context.verbose >= 1:
            self.emit(f"# Begin special extern function call {func.c_str()}")
        arg_nodes = [*enumerate(node.args.exprs)]
        for idx, arg_node in reversed(arg_nodes):
            if self.context.verbose >= 1:
                self.emit(f"# Begin setting param idx {idx} in AL")
            self.visit(arg_node) # char will be in AL
            arg_ctx = self._pop_expr()
            if self.context.verbose >= 1:
                self.emit(f"# End setting param idx {idx} in AL")
        self.emit(f"CALL {func.asm_name()}")
        if self.context.verbose >= 1:
            self.emit(f"# End special extern function call {func.c_str()}")

    def generate_FuncCall_putchar_direct(self, node: c_ast.FuncCall, func: Function):
        self.generate_FuncCall_putchar(node, func)
