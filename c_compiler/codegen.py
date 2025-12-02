import sys
from pycparser import c_ast
from typespecbuilder import TypeSpecBuilder
from typespec import TypeSpec
from variables import Variable
from function import Function
from pprint import pprint
from contextlib import contextmanager

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

    def _push_expr(self, typespec, lvalue_info=None):
        self.expr_stack.append(ExprContext(typespec, lvalue_info))

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
        if self.context.verbose >= 1:
            name = None
            if hasattr(node, 'name') and node.name:
                name = node.name
                if hasattr(name, 'name') and name.name:
                    name = name.name
            self.emit(f"# ⚠⚠ TODO {node.__class__.__name__} {name} ⚠⚠")
        for c in node:
            self.visit(c)

    def visit_FileAST(self, node):
        # If told to jump to the main function, and the main function
        # exists, insert the JMP instruction here
        if self.context.jmp_to_main and 'main' in self.context.funcreg:
            self.emit(f"JMP {self.context.funcreg['main'].asm_name()}")
        # Generate all the code
        for c in node:
            self.visit(c)
        # Finish the code by listing global/static vars and constant literals
        self.emit("")
        self.emit("# Constant literals")
        for literal in self.context.literalreg.get_all_literals():
            self.emit(f"{literal.label} {literal.asm()}")

    def visit_Typedef(self, node):
        # We already collected types in earlier passes, now stored
        # in context.typereg, so we can skip over these nodes
        pass

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
            if hasattr(self, f"generate_FuncCall_{func.name}"):
                getattr(self, f"generate_FuncCall_{func.name}")(node, func)
                return
            else:
                raise NotImplementedError(f"No generate_FuncCall_{func.name} function found to generate call to extern {func.name} function")

        if self.context.verbose >= 1:
            self.emit(f"# Begin function call {func.c_str()}")
        arg_nodes = reversed(node.args.exprs)
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
            if var.storage_class != 'static':
                self.local_offset += var.typespec.sizeof()
                var.offset = self.local_offset
            self.context.vartable.add_local(var)
            if node.init:
                self._initialize_var(node.init, var)
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
            with self._debug_block("compute ArrayRef subscript"):
                self.visit(node.subscript)
                subscript_ctx = self._pop_expr()
            
            assert isinstance(node.name, c_ast.ID)
            var = self.context.vartable.lookup(node.name.name)
            
            # Scale the index by element size
            if var.typespec.sizeof() == 1:
                if self.context.verbose >= 1:
                    self.emit(f"# ArrayRef offset no change, {var.name} sizeof==1")
            elif var.typespec.sizeof() == 2:
                self.emit("CALL :shift16_a_left", f"ArrayRef offset doubles, {var.name} sizeof==2")
            else:
                raise NotImplementedError("Indexing into arrays of types > 2 bytes is not yet supported")

            # Get the base address 
            with self._debug_block("get indexed value address"):
                if var.kind == 'global' or var.storage_class == 'static':
                    prefix = self._get_static_prefix()
                    self.emit(f"LD16_B {prefix}{var.name}", f"Address of {var.name} into B")
                else:
                    # save A (the index offset)
                    self.emit("ALUOP_PUSH %A%+%AH%", f"Save index offset")
                    self.emit("ALUOP_PUSH %A%+%AL%", f"Save index offset")
                    # Compute base address into B
                    self._compute_local_address_to_b(var, f"Base address of {var.name}")
                    # restore A (the index offset)
                    self.emit("POP_AL", f"Restore index offset")
                    self.emit("POP_AH", f"Restore index offset")

                # Now add A (index offset) and B (base address) to get the final address in B
                self.emit("CALL :add16_to_b", f"B contains indexed address into {var.name}")

                # Load the value into A/AL
                if var.typespec.sizeof() == 2:
                    self.emit("LDA_B_AH", f"Load {var.name}[index] into A")
                    self.emit("CALL :incr16_b")
                    self.emit("LDA_B_AL", f"Load {var.name}[index] into A")
                elif var.typespec.sizeof() == 1:
                    self.emit("LDA_B_AL", f"Load {var.name}[index] into AL")
                else:
                    raise NotImplementedError("Can't load datatypes > 2 bytes yet")
            
            # Push result: value in A, address still in B
            self._push_expr(var.typespec, LValueInfo(var, 'array', lvalue_in_b=True))

    def visit_StructRef(self, node):
        # TODO: be sure to self._push_expr member typespec
        self.generic_visit(node)

    def visit_Cast(self, node):
        # TODO: be sure to self._push_expr target typespec
        self.generic_visit(node)

    def visit_Constant(self, node):
        """
        Generate code for constants (integers, strings).
        
        REGISTER STATE:
        - Entry: (none)
        - Exit: A/AL = constant value
        
        STACK EFFECT: Pushes 1 ExprContext (constant, no lvalue)
        """
        if node.type == 'int':
            typespec = TypeSpec('int', 'int')
        elif node.type == 'string':
            typespec = TypeSpec('string', 'char', pointer_depth=1)
        else:
            raise NotImplementedError(f"I don't know how to represent a {node.type} constant")
        
        const_size = typespec.sizeof()

        if node.type == 'int':
            if const_size == 1:
                self.emit(f"LDI_AL {node.value}", "Constant assignment")
            elif const_size == 2:
                self.emit(f"LDI_A {node.value}", "Constant assignment")
            else:
                raise NotImplementedError("Can't load constants > 16 bit")
        elif node.type == 'string':
            literal = self.context.literalreg.lookup_by_content(node.value, node.type)
            if not literal:
                raise ValueError(f"Could not find literal in registry matching {node.value}")
            self.emit(f"LDI_A {literal.label}", literal.content)
        
        # Constants don't have lvalues
        self._push_expr(typespec, None)

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
                    self.emit("ALUOP_AL %A%+%AL%+1", f"UnaryOp {node.op}")
                else:
                    self.emit("ALUOP_AL %A%+%AL%-1", f"UnaryOp {node.op}")
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
                self.emit("MOV_BH_AH", "Address-of: copy address from B to A")
                self.emit("MOV_BL_AL")
            else:
                # Compute address for simple variables
                var = lvalue.var
                if var.kind == 'global' or var.storage_class == 'static':
                    prefix = self._get_static_prefix()
                    self.emit(f"LDI_A {prefix}{var.name}", f"Address-of {var.name}")
                else:
                    # Local/param: frame pointer + offset
                    self.emit("MOV_DH_AH", "Address-of: frame pointer to A")
                    self.emit("MOV_DL_AL")
                    self.emit(f"LDI_B {var.offset}", f"Address-of: offset for {var.name}")
                    self.emit("CALL :add16_to_a", f"Address-of {var.name}")
            
            # Result is a pointer to the original type
            result_typespec = TypeSpec(
                expr_ctx.typespec.name + '*',
                expr_ctx.typespec.base_type,
                is_pointer=True,
                pointer_depth=expr_ctx.typespec.pointer_depth + 1
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
                pointer_depth=expr_ctx.typespec.pointer_depth - 1
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
                self.emit("ALUOP_AL %0-A%+%AL%", "Unary negation")
            else:
                self.emit("CALL :negate16_a", "Unary negation")
            
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
            if expr_ctx.typespec.sizeof() == 1:
                self.emit("ALUOP_FLAGS %A%+%AL%", "Logical NOT: check zero")
            else:
                self.emit("ALUOP_FLAGS %A%+%AL%", "Logical NOT: check low byte")
                self.emit(f"JNZ .logical_not_false_{self.label_num}")
                self.emit("ALUOP_FLAGS %A%+%AH%", "Logical NOT: check high byte")
            
            self.emit(f"LDI_AL 0", "Logical NOT: assume false")
            self.emit(f"JNZ .logical_not_false_{self.label_num}")
            self.emit(f"LDI_AL 1", "Logical NOT: was zero, now true")
            self.emit(f".logical_not_false_{self.label_num}")
            self.label_num += 1
            
            result_type = TypeSpec('int', 'int')
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
            # Save B temporarily
            self.emit("ALUOP_PUSH %B%+%BH%", "Store: save address")
            self.emit("ALUOP_PUSH %B%+%BL%", "Store: save address")
            
            if expr_ctx.typespec.sizeof() == 1:
                self.emit("POP_BL", "Store: restore address")
                self.emit("POP_BH", "Store: restore address")
                self.emit("STA_B_AL", "Store byte to lvalue")
            elif expr_ctx.typespec.sizeof() == 2:
                self.emit("POP_BL", "Store: restore address")
                self.emit("POP_BH", "Store: restore address")
                self.emit("STA_B_AH", "Store high byte to lvalue")
                self.emit("CALL :incr16_b")
                self.emit("STA_B_AL", "Store low byte to lvalue")
            else:
                raise NotImplementedError("Cannot store types > 2 bytes")
        else:
            # Simple variable: use var.name or var.offset
            if var.kind == 'global' or var.storage_class == 'static':
                prefix = self._get_static_prefix()
                if expr_ctx.typespec.sizeof() == 1:
                    self.emit(f"ALUOP_ADDR %A%+%AL% {prefix}{var.name}", "Store to global/static")
                elif expr_ctx.typespec.sizeof() == 2:
                    self.emit(f"ALUOP_ADDR %A%+%AH% {prefix}{var.name}", "Store to global/static")
                    self.emit(f"ALUOP_ADDR %A%+%AL% {prefix}{var.name}+1", "Store to global/static")
            else:
                # Local/param: need to compute address
                self.emit("PUSH_CH", "Store: save C")
                self.emit("PUSH_CL")
                self.emit("ALUOP_CH %A%+%AH%", "Store: value to C")
                self.emit("ALUOP_CL %A%+%AL%")
                self.emit("MOV_DH_AH", "Store: frame pointer to A")
                self.emit("MOV_DL_AL")
                self.emit(f"LDI_B {var.offset}", f"Store: offset for {var.name}")
                self.emit("CALL :add16_to_a", f"Store: address in A")
                if expr_ctx.typespec.sizeof() == 1:
                    self.emit("STA_A_CL", f"Store to {var.name}")
                elif expr_ctx.typespec.sizeof() == 2:
                    self.emit("STA_A_CH", f"Store to {var.name}")
                    self.emit("CALL :incr16_a")
                    self.emit("STA_A_CL", f"Store to {var.name}")
                else:
                    raise NotImplementedError("Cannot store types > 2 bytes")
                self.emit("POP_CL", "Store: restore C")
                self.emit("POP_CH")

    def visit_BinaryOp(self, node):
        """
        Generate code for binary operations.
        
        REGISTER STATE:
        - Entry: (none)
        - Exit: A/AL = result value
        
        STACK EFFECT: Pops 2 ExprContext (left, right), pushes 1 (result)
        
        Supported operators:
        - Arithmetic: +, -, &, |, ^
        - Comparison: <, <=, >, >=
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
            elif node.op == '<':
                # A < B -> B - A = ?  OEZ result
                # 1 < 1 -> 1 - 1 = 0  011 false
                # 1 < 2 -> 2 - 1 = 1  000 true
                # 2 < 1 -> 1 - 2 = -1 100 false
                if op_size == 1:
                    self.emit(f"ALUOP_FLAGS %B-A%+%AL%+%BL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                    self.emit(f"LDI_AL 0")
                    self.emit(f"JO .less_than_false_{self.label_num}")
                    self.emit(f"JZ .less_than_false_{self.label_num}")
                    self.emit(f"LDI_AL 1")
                    self.emit(f".less_than_false_{self.label_num}")
                    self.label_num += 1
                else:
                    # Note that :sub16_b_minus_a does not reliably set the E or Z status bits, we can only trust the O bit,
                    self.emit(f"CALL :sub16_b_minus_a", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                    self.emit(f"LDI_AL 0")
                    self.emit(f"JO .less_than_false_{self.label_num}")
                    self.emit(f"ALUOP_FLAGS %B%+%BL%")  # if BL is nonzero then true (since there was no overflow)
                    self.emit(f"JNZ .less_than_true_{self.label_num}")
                    self.emit(f"ALUOP_FLAGS %B%+%BH%")  # if BH is nonzero then true (since there was no overflow)
                    self.emit(f"JNZ .less_than_true_{self.label_num}")
                    self.emit(f"JMP .less_than_false_{self.label_num}")  # otherwise false, since both BH and BL were zero
                    self.emit(f".less_than_true_{self.label_num}")
                    self.emit(f"LDI_AL 1")
                    self.emit(f".less_than_false_{self.label_num}")
                    self.label_num += 1
                result_type = TypeSpec('int', 'int')
            elif node.op == '<=':
                # A <= B -> B - A = ?  OEZ result
                # 1 <= 1 -> 1 - 1 = 0  011 true
                # 1 <= 2 -> 2 - 1 = 1  000 true
                # 2 <= 1 -> 1 - 2 = -1 100 false
                if op_size == 1:
                    self.emit(f"ALUOP_FLAGS %B-A%+%AL%+%BL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                    self.emit(f"LDI_AL 0")
                    self.emit(f"JO .less_than_equal_false_{self.label_num}")
                    self.emit(f"LDI_AL 1")
                    self.emit(f".less_than_equal_false_{self.label_num}")
                    self.label_num += 1
                else:
                    # Note that :sub16_b_minus_a does not reliably set the E or Z status bits, we can only trust the O bit,
                    self.emit(f"CALL :sub16_b_minus_a", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                    self.emit(f"LDI_AL 0")
                    self.emit(f"JO .less_than_equal_false_{self.label_num}")
                    self.emit(f"LDI_AL 1")
                    self.emit(f".less_than_equal_false_{self.label_num}")
                    self.label_num += 1
                result_type = TypeSpec('int', 'int')
            elif node.op == '>':
                # A > B -> A - B = ?  OEZ result
                # 1 > 1 -> 1 - 1 = 0  011 false
                # 1 > 2 -> 1 - 2 = -1 100 false
                # 2 > 1 -> 2 - 1 = 1  000 true
                if op_size == 1:
                    self.emit(f"ALUOP_FLAGS %A-B%+%AL%+%BL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                    self.emit(f"LDI_AL 0")
                    self.emit(f"JO .greater_than_false_{self.label_num}")
                    self.emit(f"JZ .greater_than_false_{self.label_num}")
                    self.emit(f"LDI_AL 1")
                    self.emit(f".greater_than_false_{self.label_num}")
                    self.label_num += 1
                else:
                    # Note that :sub16_b_minus_a does not reliably set the E or Z status bits, we can only trust the O bit,
                    self.emit(f"CALL :sub16_a_minus_b", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                    self.emit(f"LDI_AL 0")
                    self.emit(f"JO .greater_than_false_{self.label_num}")
                    self.emit(f"ALUOP_FLAGS %A%+%AL%")  # if AL is nonzero then true (since there was no overflow)
                    self.emit(f"JNZ .greater_than_true_{self.label_num}")
                    self.emit(f"ALUOP_FLAGS %A%+%AH%")  # if AH is nonzero then true (since there was no overflow)
                    self.emit(f"JNZ .greater_than_true_{self.label_num}")
                    self.emit(f"JMP .greater_than_false_{self.label_num}")  # otherwise false, since both AH and AL were zero
                    self.emit(f".greater_than_true_{self.label_num}")
                    self.emit(f"LDI_AL 1")
                    self.emit(f".greater_than_false_{self.label_num}")
                    self.label_num += 1
                result_type = TypeSpec('int', 'int')
            elif node.op == '>=':
                # A >= B -> A - B = ?  OEZ result
                # 1 >= 1 -> 1 - 1 = 0  011 true
                # 1 >= 2 -> 1 - 2 = -1 100 false
                # 2 >= 1 -> 2 - 1 = 1  000 true
                if op_size == 1:
                    self.emit(f"ALUOP_FLAGS %A-B%+%AL%+%BL%", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                    self.emit(f"LDI_AL 0")
                    self.emit(f"JO .greater_than_equal_false_{self.label_num}")
                    self.emit(f"LDI_AL 1")
                    self.emit(f".greater_than_equal_false_{self.label_num}")
                    self.label_num += 1
                else:
                    # Note that :sub16_b_minus_a does not reliably set the E or Z status bits, we can only trust the O bit,
                    self.emit(f"CALL :sub16_a_minus_b", f"BinaryOp ({left_ctx.typespec.c_str()}) {node.op} ({right_ctx.typespec.c_str()})")
                    self.emit(f"LDI_AL 0")
                    self.emit(f"JO .greater_than_equal_false_{self.label_num}")
                    self.emit(f"LDI_AL 1")
                    self.emit(f".greater_than_equal_false_{self.label_num}")
                    self.label_num += 1
                result_type = TypeSpec('int', 'int')
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
            self.emit(f"LDI_B {prefix}{var.name}", f"Set up address (lvalue) for {var.storage_class} {var.typespec.base_type} {var.name}")
            if var.typespec.sizeof() == 2:
                self.emit(f"LD16_A {prefix}{var.name}", f"Load {var.storage_class} {var.typespec.base_type} {var.name}")
            elif var.typespec.sizeof() == 1:
                self.emit(f"LD_AL {prefix}{var.name}", f"Load {var.storage_class} {var.typespec.base_type} {var.name}")
            else:
                raise ValueError(f"Unable to load var {var.name} as it's not 1 or 2 bytes")
        else:
            self.emit(f"LDI_B {var.offset}", f"Load var {var.name} at offset {var.offset}")
            self.emit("MOV_DH_AH", f"Load var {var.name} at offset {var.offset}")
            self.emit("MOV_DL_AL", f"Load var {var.name} at offset {var.offset}")
            self.emit("CALL :add16_to_b", f"Load var {var.name} at offset {var.offset}")
            if var.typespec.sizeof() == 2:
                self.emit("LDA_B_AH", f"Load var {var.name} at offset {var.offset}")
                self.emit("CALL :incr16_b", f"Load var {var.name} at offset {var.offset}")
            self.emit("LDA_B_AL", f"Load var {var.name} at offset {var.offset}")
        
        # Value in A, lvalue info for simple variable (address not in B)
        self._push_expr(var.typespec, LValueInfo(var, 'simple', lvalue_in_b=True))

    def _total_localvar_size(self, node) -> int:
        """
        Recursively descend into the entirety of node's AST searching for
        local, non-static variable declarations (excluding parameters) and
        total up their size.
        """
        if type(node) is c_ast.Decl and type(node.type) is not c_ast.FuncDecl:
            ts = self._build_typespec(node.name, node.type)
            if self.context.verbose >= 2:
                self.emit(f"# _total_localvar_size: Computing size of {node.name}, {node.type.__class__.__name__} = {ts.sizeof()}")
            return ts.sizeof()
        recursive_sum = 0
        for child in node:
            if child and type(child) is c_ast.Decl and type(child.type) is not c_ast.FuncDecl:
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
            self.emit(f"ALUOP_PUSH %{otherreg}%+%{otherreg}L", f"Sign extend {reg}L: save {otherreg}L")
            self.emit(f"LDI_{otherreg}L 0x80", f"Sign extend {reg}L: check sign bit")
            self.emit(f"ALUOP_FLAGS %A&B%+%AL%+%BL%", f"Sign extend {reg}L: check sign bit")
            self.emit(f"POP_{otherreg}L", f"Sign extend {reg}L: restore {otherreg}L")
            self.emit(f"LDI_{reg}H 0x00", f"Sign extend {reg}L: assume sign bit not set")
            self.emit(f"JZ .sign_extend_{self.label_num}", f"Sign extend {reg}L: don't overwrite {reg}H if sign bit was not set")
            self.emit(f"LDI_{reg}H 0xff", f"Sign extend {reg}L: sign bit was set")
            self.emit(f".sign_extend_{self.label_num}", f"Sign extend {reg}L")
            self.label_num += 1

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
            comment = f"Compute address of {var.name} into B"
        self.emit("MOV_DH_AH", comment)
        self.emit("MOV_DL_AL", comment)
        self.emit(f"LDI_B {var.offset}", comment)
        self.emit("CALL :add16_to_b", comment)

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
                self.emit(f"LD16_A {prefix}{var.name}", f"Load {var.storage_class} {var.typespec.base_type} {var.name}")
            elif var.typespec.sizeof() == 1:
                self.emit(f"LD_AL {prefix}{var.name}", f"Load {var.storage_class} {var.typespec.base_type} {var.name}")
            else:
                raise ValueError(f"Unable to load var {var.name} as it's not 1 or 2 bytes")
        else:
            # Local/param variable: compute address and load
            self.emit(f"LDI_B {var.offset}", f"Load var {var.name} at offset {var.offset}")
            self.emit("MOV_DH_AH", f"Load var {var.name} at offset {var.offset}")
            self.emit("MOV_DL_AL", f"Load var {var.name} at offset {var.offset}")
            self.emit("CALL :add16_to_b", f"Load var {var.name} at offset {var.offset}")
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
                self.emit(f"ALUOP_ADDR %A%+%AL% {prefix}{var.name}", f"Store to {var.name}")
            elif var.typespec.sizeof() == 2:
                self.emit(f"ALUOP_ADDR %A%+%AH% {prefix}{var.name}", f"Store to {var.name}")
                self.emit(f"ALUOP_ADDR %A%+%AL% {prefix}{var.name}+1", f"Store to {var.name}")
        else:
            # Local/param: need to compute address
            self.emit("PUSH_CH", "Store: save C")
            self.emit("PUSH_CL")
            self.emit("ALUOP_CH %A%+%AH%", "Store: value to C")
            self.emit("ALUOP_CL %A%+%AL%")
            self.emit("MOV_DH_AH", "Store: frame pointer to A")
            self.emit("MOV_DL_AL")
            self.emit(f"LDI_B {var.offset}", f"Store: offset for {var.name}")
            self.emit("CALL :add16_to_a", f"Store: address in A")
            if var.typespec.sizeof() == 1:
                self.emit("STA_A_CL", f"Store to {var.name}")
            elif var.typespec.sizeof() == 2:
                self.emit("STA_A_CH", f"Store to {var.name}")
                self.emit("CALL :incr16_a")
                self.emit("STA_A_CL", f"Store to {var.name}")
            else:
                raise NotImplementedError("Cannot store types > 2 bytes")
            self.emit("POP_CL", "Store: restore C")
            self.emit("POP_CH")

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
