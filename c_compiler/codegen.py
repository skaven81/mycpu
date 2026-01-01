import sys
from contextlib import contextmanager
from pycparser import c_ast
from typespec import TypeSpec
from function import Function
from variable import Variable
from special_functions import SpecialFunctions
import ast

class CodeGenerator(c_ast.NodeVisitor, SpecialFunctions):
    def __init__(self, context, output=sys.stdout):
        self.context = context
        self.output = output
        self.label_num = 0
        self.debug_depth = 0
        self.func_return_label = None

    def visit(self, node, mode, **kwargs):
        """
        Visit a node with a specified mode, and allow additional
        arguments 
        """
        if node is None:
            return None
            
        method = 'visit_' + node.__class__.__name__
        visitor = getattr(self, method, self.generic_visit)

        if self.context.verbose > 1:
            node_name = None
            if type(getattr(node, 'name', None)) is str:
                node_name = node.name
            elif type(getattr(getattr(node, 'name', None), 'name', None)) is str:
                node_name = node.name.name
            with self._debug_block(f"Visiting {node.__class__.__name__} {node_name if node_name else ''}"):
                ret = visitor(node, mode, **kwargs)
        else:
            ret = visitor(node, mode, **kwargs)
        return ret

    def _get_label(self, name, prefix='.'):
        self.label_num += 1
        return f"{prefix}{name}_{self.label_num}"

    def _get_static_prefix(self):
        """Get the assembly prefix for static/global variables"""
        return '$' if self.context.static_type == 'asm_var' else '.'

    @contextmanager
    def _debug_block(self, name: str, min_verbose: int = 2):
        """Emit debug comments for begin/end of operation block"""
        if self.context.verbose >= min_verbose:
            self.emit(f"# {'-'*self.debug_depth*2}Begin {name}")
            self.debug_depth += 1
        try:
            yield
        finally:
            if self.context.verbose >= min_verbose:
                self.debug_depth -= 1
                self.emit(f"# {'-'*self.debug_depth*2}End {name}")

    def emit_debug(self, comment: str, min_verbose: int = 2):
        if self.context.verbose >= min_verbose:
            self.emit(f"# {'-'*self.debug_depth*2}{comment}")

    def emit_verbose(self, comment: str, min_verbose: int = 2):
        if self.context.verbose >= min_verbose:
            self.emit(f"# {'-'*self.debug_depth*2}{comment}")
        elif self.context.verbose >= 1:
            self.emit(f"# {comment}")

    def emit(self, asm, comment=None):
        if comment:
            print(f"{asm:<32} # {comment}", file=self.output)
        else:
            print(asm, file=self.output)

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
        if typespec.is_signed():
            label = self._get_label("sign_extend")
            self.emit(f"ALUOP_FLAGS %{reg}msb%+%{reg}L%", f"Sign extend {reg}L: check sign bit")
            self.emit(f"LDI_{reg}H 0x00", f"Sign extend {reg}L: assume sign bit not set")
            self.emit(f"JZ {label}", f"Sign extend {reg}L: don't overwrite {reg}H if sign bit was not set")
            self.emit(f"LDI_{reg}H 0xff", f"Sign extend {reg}L: sign bit was set")
            self.emit(f"{label}", f"Sign extend {reg}L")
            self.label_num += 1
        else:
            self.emit(f"LDI_{reg}H 0x00", f"Sign extend {reg}L: unsigned value in {reg}L")

    def generic_visit(self, node, mode, **kwargs):
        raise NotImplementedError(f"{node.__class__.__name__} visitor not implemented yet. mode={mode}")

    def visit_FileAST(self, node, mode, **kwargs):
        if mode == 'type_collection':
            for c in node:
                if type(c) is c_ast.Typedef:
                    self.visit(c, mode=mode, **kwargs)
                elif type(c) is c_ast.Decl and type(c.type) is c_ast.Struct:
                    # insert a fake Typedef node so non-typedef structs get
                    # picked up in the type registry as well.
                    self.visit(c_ast.Typedef(name=c.type.name, quals=[], storage=['struct'], type=c), mode=mode, **kwargs)
            return
        elif mode == 'function_collection':
            for c in node:
                if type(c) in (c_ast.Decl, c_ast.FuncDef):
                    self.visit(c, mode=mode, **kwargs)
            return
        elif mode == 'codegen':
            visited_toplevel_nodes = []
            # Generate code for declaring global vars
            self.emit_debug("#"*40)
            with self._debug_block("Global var declaration"):
                for c in node:
                    if type(c) is c_ast.Decl:
                        self.visit(c, mode=mode, **kwargs)
                        visited_toplevel_nodes.append(c)
            self.emit_debug("#"*40)
            self.emit_verbose("")

            # Generate the jump-to-main if configured
            main_func = self.context.funcreg.lookup('main')
            if self.context.jmp_to_main and main_func:
                self.emit(f"JMP {main_func.asm_name()}", "Initialization complete, go to main function")
                self.emit("")

            # Generate the functions
            self.emit_debug("#"*40)
            with self._debug_block("Function declarations"):
                self.emit("")
                for c in node:
                    if type(c) is c_ast.FuncDef:
                        self.visit(c, mode=mode, **kwargs)
                        self.emit("")
                        visited_toplevel_nodes.append(c)
            self.emit_debug("#"*40)
            self.emit_verbose("")

            # Generate data block: constant literals
            prefix = self._get_static_prefix()
            with self._debug_block("Constant literals"):
                for literal in self.context.literalreg.get_all_literals():
                    if literal.comment:
                        self.emit_verbose(literal.comment)
                    self.emit(f"{literal.label} {literal.asm()}")
            # Generate data block: global vars
            with self._debug_block("Global vars"):
                for var in self.context.vartable.get_all_globals():
                    if prefix == '$':
                        if var.sizeof() == 1:
                            self.emit(f"VAR global byte ${var.padded_name()}")
                        elif var.sizeof() == 2:
                            self.emit(f"VAR global word ${var.padded_name()}")
                        else:
                            self.emit(f"VAR global {var.typespec.sizeof()} ${var.padded_name()}")
                    else:
                        self.emit(f'.{var.padded_name()} "' + '\\0'*var.sizeof() + '"')
            # Generate data block: static local vars
            with self._debug_block("Static local vars"):
                for var in self.context.vartable.get_all_local_statics():
                    if prefix == '$':
                        if var.typespec.sizeof() == 1:
                            self.emit(f"VAR global byte ${var.padded_name()}")
                        elif var.typespec.sizeof() == 2:
                            self.emit(f"VAR global word ${var.padded_name()}")
                        else:
                            self.emit(f"VAR global {var.typespec.sizeof()} ${var.padded_name()}")
                    else:
                        self.emit(f'.{var.padded_name()} "' + '\\0'*var.typespec.sizeof() + '"')
        else:
            raise NotImplementedError(f"visit_FileAST mode {mode} not yet supported")

    def visit_Typedef(self, node, mode, **kwargs):
        if mode == 'type_collection':
            new_type = self.visit(node.type, mode=mode, **kwargs)
            self.context.typereg.register(node.name, new_type)
            return 
        elif mode in ('codegen',):
            return
        else:
            raise NotImplementedError(f"visit_Typedef mode {mode} not yet supported")

    def visit_TypeDecl(self, node, mode, **kwargs):
        registered_type = self.context.typereg.lookup(node.declname)
        if mode == 'type_collection':
            if registered_type:
                return registered_type
            new_type = self.visit(node.type, mode=mode, **kwargs)
            new_type.qualifiers.extend(node.quals)
            if not new_type.name:
                new_type.name = node.declname
            return new_type
        elif mode == 'return_typespec':
            return self.visit(node.type, mode=mode, **kwargs)
        elif mode == 'return_var':
            return Variable(name=node.declname,
                            typespec=self.visit(node.type, mode='return_typespec', **kwargs))
        else:
            raise NotImplementedError(f"visit_TypeDecl mode {mode} not yet supported")
       
    def visit_IdentifierType(self, node, mode, **kwargs):
        type_name = ' '.join(node.names)
        registered_type = self.context.typereg.lookup(type_name)
        if mode == 'type_collection':
            if registered_type:
                return registered_type
            else:
                return TypeSpec(base_type = ' '.join(node.names), _registry=self.context.typereg)
        elif mode == 'return_typespec':
            return registered_type
        else:
            raise NotImplementedError(f"visit_IdentifierType mode {mode} not yet supported")

    def visit_Struct(self, node, mode, **kwargs):
        if mode == 'type_collection':
            member_vars = []
            member_offset = 0
            for c in node.decls:
                membervar = self.visit(c, mode='return_var', var_kind='struct_member', **kwargs)
                membervar.is_struct_member = True
                membervar.name = c.name
                membervar.kind = "struct_member"
                membervar.offset = member_offset
                member_vars.append(membervar)
                member_offset += membervar.sizeof()
            new_typespec = TypeSpec(name=node.name, is_struct=True, struct_members=member_vars, _registry=self.context.typereg)
            return new_typespec
        elif mode == 'return_typespec':
            return self.context.typereg.lookup(node.name)
        else:
            raise NotImplementedError(f"visit_Struct mode {mode} not yet supported")

    def visit_StructRef(self, node, mode, dest_reg='A', **kwargs):
        with self._debug_block(f"Get base address of struct into {dest_reg}"):
            if node.type == '.':
                base_var = self.visit(node.name, mode='generate_lvalue_address', dest_reg=dest_reg)
            else:  # '->'
                base_var = self.visit(node.name, mode='generate_rvalue', dest_reg=dest_reg)
        
        # dest_reg now has struct base address
        member_var = base_var.typespec.struct_member(node.field.name)
        with self._debug_block(f"Add member {member_var.name} offset {member_var.offset} to struct address"):
            self._add_member_offset(member_var, dest_reg)
        
        if mode == 'generate_lvalue_address':
            # address is already in dest_reg, we're done
            return member_var
        elif mode == 'generate_rvalue':
            if member_var.sizeof() <= 2 and not member_var.is_array:
                with self._debug_block(f"Load value for {member_var.name} into {dest_reg}"):
                    other_reg = 'B' if dest_reg == 'A' else 'A'
                    self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"Save {other_reg} while we load struct member value")
                    if member_var.sizeof() == 2:
                        self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"Save {other_reg} while we load struct member value")
                    self._deref_load(member_var.sizeof(), addr_reg=dest_reg, dest_reg=other_reg)
                    if member_var.sizeof() == 2:
                        self.emit(f"ALUOP_{dest_reg}H %{other_reg}%+%{other_reg}H%", f"Transfer value to {dest_reg}")
                    self.emit(f"ALUOP_{dest_reg}L %{other_reg}%+%{other_reg}L%", f"Transfer value to {dest_reg}")
                    self.emit(f"POP_{other_reg}L", f"Restore {other_reg} after loading struct member value")
                    if member_var.sizeof() == 2:
                        self.emit(f"POP_{other_reg}H", f"Restore {other_reg} after loading struct member value")
                return member_var
            else:
                # address is already in dest_reg, we're done
                return member_var
        else:
            raise NotImplementedError(f"visit_StructRef mode {mode} not yet supported")

    def visit_Decl(self, node, mode, var_kind=None, register_var=True, **kwargs):
        if mode in ('return_typespec', 'type_collection',):
            return self.visit(node.type, mode=mode, **kwargs)
        elif mode == 'function_collection':
            if type(node.type) is c_ast.FuncDecl:
                # Don't re-register functions we already have
                if node.name in self.context.funcreg:
                    return
                new_funcdef = self.visit(node.type, mode=mode, **kwargs)
                if node.storage:
                    new_funcdef.storage = node.storage[0]
                new_funcdef.name = node.name
                self.context.funcreg.register(node.name, new_funcdef)
                return
        elif mode == 'return_var':
            # Don't redo the work of generating the variable if the
            # identifier already exists in the table
            var = self.context.vartable.lookup(node.name)
            if var:
                return var
            if type(node.type) in (c_ast.Struct, c_ast.FuncDecl,):
                raise ValueError(f"return_var for Struct or FuncDecl type Decl node doesn't make sense")
            # New Variable declaration and storage allocation
            if type(node.type) in (c_ast.TypeDecl, c_ast.PtrDecl, c_ast.ArrayDecl):
                new_typespec = self.visit(node.type, mode='return_typespec', init=getattr(node, 'init'))
                new_var = self.visit(node.type, mode='return_var', var_kind=var_kind, register_var=register_var, **kwargs)
                if node.storage:
                    new_var.storage = node.storage[0]
                if not new_var.name:
                    new_var.name = node.name
                new_var.typespec.qualifiers.extend(node.quals)
                if new_var.is_array and not new_var.array_dims:
                    if not node.init:
                        raise ValueError("Cannot declare dimensionless array without intiializer")
                    new_var.array_dims.extend(self.visit(node.init, mode='return_array_dim'))
                if var_kind in ('struct_member', 'param',):
                    new_var.kind = var_kind
                    return new_var
                elif self.context.vartable.get_scope_depth() == 0:
                    # global var declaration
                    new_var.kind = 'global'
                    if register_var:
                        self.context.vartable.add(new_var)
                    self.emit_verbose(f"Registered {new_var.kind} variable {new_var.friendly_name()}")
                    return new_var
                else:
                    # local var declaration
                    new_var.kind = 'local'
                    if register_var:
                        self.context.vartable.add(new_var) # registration sets the offset
                        new_var = self.context.vartable.lookup(new_var.name)
                        self.emit_verbose(f"Registered {new_var.kind} variable {new_var.friendly_name()}, size {new_var.sizeof()} at offset {new_var.offset}")
                        if not new_var.offset:
                            raise ValueError(f"Local var {new_var.name} was not assigned an offset")
                    return new_var
            else:
                raise NotImplementedError(f"visit_Decl mode {mode} not yet supported for {node.type.__class__.__name__} types")
        elif mode == 'codegen':
            if type(node.type) in (c_ast.Struct, c_ast.FuncDecl,):
                # skip code generation for Struct and FuncDecl declarations, these
                # were handled during type and function collection
                return
            var = self.visit(node, mode='return_var')
            if not var:
                raise ValueError(f"Can't generate code for an unregistered variable")
            if node.init:
                with self._debug_block(f"Initialize var {var.name}"):
                    if var.is_array or var.typespec.is_struct:
                        self.visit(c_ast.ID(name=var.name), mode='generate_lvalue_address', dest_reg='B')
                        init_var = self.visit(node.init, mode='generate_rvalue', dest_reg='A', dest_typespec=var.typespec)
                        if not init_var:
                            raise ValueError(f"Cannot safely init var {var.name} without init list size")
                        self.emit_debug(f"init_var sizeof: {init_var.sizeof()}, var sizeof: {var.sizeof()}")
                        self._emit_bulk_store(var, lvalue_reg='B', rvalue_reg='A', bytes=min(init_var.sizeof(), var.sizeof()))
                    else:
                        self.visit(c_ast.Assignment(op='=', lvalue=c_ast.ID(name=var.name), rvalue=node.init), mode='codegen')
        else:
            raise NotImplementedError(f"visit_Decl mode {mode} not yet supported")

    def visit_FuncDecl(self, node, mode, **kwargs):
        if mode == 'function_collection':
            new_funcdef = Function()
            new_funcdef.return_type = self.visit(node.type, mode='return_typespec')
            offset = 0
            for p in self.visit(node.args, mode='return_parameter_vars'):
                if p.is_array or p.typespec.is_struct:
                    p.offset = offset - 1
                    offset -= 2
                elif p.sizeof() == 2:
                    p.offset = offset - 1
                    offset -= 2
                elif p.sizeof() == 1:
                    p.offset = offset
                    offset -= 1
                elif p.sizeof() == 0:
                    pass # void or variadic parameter
                else:
                    raise ValueError("Cannot register function parameter larger than two bytes")
                new_funcdef.parameters.append(p)
            return new_funcdef
        else:
            raise NotImplementedError(f"visit_FuncDecl mode {mode} not yet supported")

    def visit_ParamList(self, node, mode, **kwargs):
        if mode == 'return_parameter_vars':
            params = []
            for p in node.params:
                new_param = self.visit(p, mode='return_var', var_kind='param', register_var=False)
                new_param.kind = 'param'
                if (new_param.typespec.is_struct or new_param.is_array) and not new_param.is_pointer:
                    raise ValueError(
                        f"Parameter '{new_param.name}' cannot be passed by value. "
                        f"Structs and arrays must be passed by pointer (use {new_param.typespec.name}* or {new_param.typespec.name}[])"
                    )
                params.append(new_param)
            return params
        else:
            raise NotImplementedError(f"visit_ParamList mode {mode} not yet supported")

    def visit_EllipsisParam(self, node, mode, **kwargs):
        if mode == 'return_var':
           return Variable(typespec=TypeSpec(name='...', base_type = '...', _registry=self.context.typereg),
                           name='...',
                           kind='param')
        else:
            raise NotImplementedError(f"visit_EllipsisParam mode {mode} not yet supported")

    def visit_FuncDef(self, node, mode, **kwargs):
        if mode == 'function_collection':
            self.visit(node.decl, mode=mode)
            return
        elif mode == 'codegen':
            # Enter a new scope
            self.context.vartable.push_scope()

            # Function header and prologue
            with self._debug_block(f"FuncDef Decl for {node.decl.name}"):
                func = self.context.funcreg.lookup(node.decl.name)
                if not func:
                    raise ValueError("Cannot generate function that hasn't been registered")

                if func.storage == 'static':
                    self.emit(f'.{func.name}', func.c_str())
                else:
                    self.emit(f':{func.name}', func.c_str())
                self.func_return_label = self._get_label(f"{func.name}_return")

                # Save the current stack
                self.emit_stackpush()

                # Set frame pointer
                self.emit("LD_DH $heap_ptr", "Set frame pointer")
                self.emit("LD_DL $heap_ptr+1", "Set frame pointer")

                # Local variable memory allocation
                localvar_bytes = self._total_localvar_size(node)
                if self.context.verbose >= 1:
                    self.emit_debug(f"Found {localvar_bytes} bytes of local vars in this function")
                # Advance stack pointer
                self.param_offset = None
                if localvar_bytes > 0:
                    self.emit(f"LDI_BL {localvar_bytes}", "Bytes to allocate for local vars")
                    self.emit(f"CALL :heap_advance_BL")
                # Reset localvar offset so new registrations get correct offsets
                self.context.vartable.localvar_offset = 1
                # Register parameter variables; offsets were computed in function_collection pass
                parameter_bytes = 0
                if func.parameters:
                    for p in func.parameters:
                        self.context.vartable.add(p)
                        parameter_bytes += p.sizeof()
                        if self.context.verbose >= 1:
                            self.emit_debug(f"Registered parameter {p.friendly_name()}, {p.sizeof()} bytes at offset {p.offset}")
                if self.context.verbose >= 1:
                    self.emit_debug(f"Found {parameter_bytes} bytes of parameter vars in this function")

                # Compute retreat value (local vars + parameters)
                retreat_bytes = localvar_bytes + parameter_bytes

                # Generate function body, registering local vars as we encounter them
                for c in node:
                    self.visit(c, mode='codegen')

                # Function epilogue
                self.emit(self.func_return_label)
                self.func_return_label = None

                # Retreat the stack pointer
                if retreat_bytes:
                    self.emit(f"LDI_BL {retreat_bytes}", "Bytes to free from local vars and parameters")
                    self.emit(f"CALL :heap_retreat_BL")

                # Set up return value
                if func.return_type.sizeof() == 0:
                    self.emit_debug("# void function, no push to heap")
                elif func.return_type.sizeof() == 1:
                    self.emit("CALL :heap_push_AL", "Return value")
                elif func.return_type.sizeof() == 2:
                    self.emit("CALL :heap_push_A", "Return value")
                else:
                    raise NotImplementedError("Unable to return from function with > 2 bytes")

                # Unroll scope - this removes the local vars and
                # parameter vars from the variable table
                self.emit_stackpop()
                self.context.vartable.pop_scope()

                # Return
                self.emit("RET")
        else:
            raise NotImplementedError(f"visit_FuncDef mode {mode} not yet supported")

    def visit_Return(self, node, mode, **kwargs):
        if mode == 'codegen':
            self.visit(node.expr, mode='generate_rvalue', dest_reg='A')
            self.emit(f"JMP {self.func_return_label}")
        else:
            raise NotImplementedError(f"visit_Return mode {mode} not yet supported")

    def visit_FuncCall(self, node, mode, dest_reg='A', **kwargs):
        if mode in ('codegen', 'generate_rvalue',):
            func = self.visit(node.name, mode='return_function')
            if not func:
                raise ValueError(f"Function {node.name} not found in function registry")
            with self._debug_block(f"FuncCall {func.name}"):
                # Check for custom function call override, for external library
                # functions that don't conform to our standard call semantics
                custom_func_call = getattr(self, f"custom_FuncCall_{func.name}", None)
                if custom_func_call and func.storage == 'extern':
                    custom_func_call(node, mode, func=func, dest_reg=dest_reg, **kwargs)
                    if mode == 'generate_rvalue':
                        return Variable(typespec=func.return_type, name=func.name)
                    return

                # Otherwise, it's a function with standard call semantics (heap_push
                # arguments in reverse order, call, heap_pop return value)
                param_vars = reversed(func.parameters)
                arg_nodes = reversed(self.visit(node.args, mode='return_nodes'))
                for pv, an in zip(param_vars, arg_nodes):
                    with self._debug_block(f"FuncCall {func.name} push parameter {pv.friendly_name()}"):
                        if pv.is_pointer or pv.is_array or pv.typespec.is_struct:
                            rvalue_var = self.visit(an, mode='generate_lvalue_address', dest_reg='A', dest_typespec=pv.typespec)
                            self.emit(f"CALL :heap_push_A", f"Push parameter {pv.friendly_name()} (pointer to {rvalue_var.friendly_name()})")
                        else:
                            rvalue_var = self.visit(an, mode='generate_rvalue', dest_reg='A', dest_typespec=pv.typespec)
                            if rvalue_var.is_array or rvalue_var.typespec.is_struct:
                                self.emit(f"CALL :heap_push_A", f"Push parameter {pv.friendly_name()} (pointer to {rvalue_var.friendly_name()})")
                            elif rvalue_var.sizeof() == 1:
                                self.emit(f"CALL :heap_push_AL", f"Push parameter {pv.friendly_name()}")
                            elif rvalue_var.sizeof() == 2:
                                self.emit(f"CALL :heap_push_A", f"Push parameter {pv.friendly_name()}")
                            else:
                                raise ValueError("Unable to push parameters larger than 2 bytes")
                self.emit(f"CALL {func.asm_name()}")
                if func.return_type.sizeof() == 0:
                    self.emit("# function returns nothing, not popping a return value")
                elif func.return_type.sizeof() == 1:
                    self.emit(f"CALL :heap_pop_{dest_reg}L")
                elif func.return_type.sizeof() == 2:
                    self.emit(f"CALL :heap_pop_{dest_reg}")
                else:
                    raise NotImplementedError("Unable to handle function calls that return more than 2 bytes")
            if mode == 'generate_rvalue':
                return Variable(typespec=func.return_type, name=func.name)
        else:
            raise NotImplementedError(f"visit_FuncCall mode {mode} not yet supported")

    def visit_ExprList(self, node, mode, **kwargs):
        if mode == 'return_nodes':
            return node.exprs
        else:
            raise NotImplementedError(f"visit_ExprList mode {mode} not yet supported")

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
            var = self.visit(node, mode='return_var', register_var=False)
            if self.context.verbose >= 2:
                self.emit_debug(f"_total_localvar_size: Computing size of {var.friendly_name()} = {var.sizeof()}")
            return var.sizeof()
        recursive_sum = 0
        for child in node:
            recursive_sum += self._total_localvar_size(child)
        return recursive_sum

    def visit_PtrDecl(self, node, mode, **kwargs):
        if mode in ('type_collection', 'return_typespec',):
            return self.visit(node.type, mode=mode, **kwargs)
        elif mode == 'return_var':
            new_var = self.visit(node.type, mode=mode, **kwargs)
            new_var.is_pointer = True
            new_var.pointer_depth += 1
            return new_var
        else:
            raise NotImplementedError(f"visit_PtrDecl mode {mode} not yet supported")

    def visit_ArrayDecl(self, node, mode, **kwargs):
        if mode == 'return_typespec':
            new_typespec = self.visit(node.type, mode=mode, **kwargs)
            new_typespec.qualifiers.extend(node.dim_quals)
            return new_typespec
        elif mode == 'return_var':
            new_var = self.visit(node.type, mode='return_var', **kwargs)
            new_var.is_array = True
            if node.dim:
                new_var.array_dims.append(self.visit(node.dim, mode='get_value', **kwargs)[0])
            return new_var
        else:
            raise NotImplementedError(f"visit_ArrayDecl mode {mode} not yet supported")

    def visit_ArrayRef(self, node, mode, dest_reg='A', **kwargs):
        var = self.visit(node.name, mode='return_var')
        
        # Compute element address
        other_reg = 'B' if dest_reg == 'A' else 'A'
        self.emit(f"ALUOP_PUSH %{other_reg}H%", f"ArrayRef {other_reg} backup")
        self.emit(f"ALUOP_PUSH %{other_reg}L%", f"ArrayRef {other_reg} backup")
            
        with self._debug_block(f"Get base address of {var.friendly_name()} into {other_reg}"):
            # Get base address into other_reg
            self._get_var_base_address(var, other_reg)
            # Save the base address on the stack, because computing
            # the subscript may clobber other_reg if it's a complex
            # operation.
            self.emit(f"ALUOP_PUSH %{other_reg}H%", f"Save base address of {var.friendly_name()}")
            self.emit(f"ALUOP_PUSH %{other_reg}L%", f"Save base address of {var.friendly_name()}")

        # Load subscript, check return var to get type (might need sign extension)
        with self._debug_block(f"Get subscript value (offset) into {dest_reg}"):
            subscript_var = self.visit(node.subscript, mode='generate_rvalue', dest_reg=dest_reg)
            if not subscript_var:
                raise ValueError("Can't index array if generate_rvalue does not return a var")
            if subscript_var.sizeof() == 1:
                self.emit_sign_extend(dest_reg, subscript_var.typespec)

        with self._debug_block(f"Compute subscripted address into {other_reg}"):
            # Restore the base address first
            self.emit(f"POP_{other_reg}L", f"Restore base address of {var.friendly_name()}")
            self.emit(f"POP_{other_reg}H", f"Restore base address of {var.friendly_name()}")
            self._add_array_offset(var, index_reg=dest_reg, addr_reg=other_reg) # Indexed address now in other_reg
        
        if mode == 'generate_lvalue_address':
            # Copy address computed above in other_reg into dest_reg
            with self._debug_block(f"Copy subscripted address into {dest_reg}"):
                self.emit(f"ALUOP_{dest_reg}H %{other_reg}%+%{other_reg}H%", f"Copy subscripted address from {other_reg} to {dest_reg}")
                self.emit(f"ALUOP_{dest_reg}L %{other_reg}%+%{other_reg}L%", f"Copy subscripted address from {other_reg} to {dest_reg}")
            self.emit(f"POP_{other_reg}L", f"ArrayRef {other_reg} restore")
            self.emit(f"POP_{other_reg}H", f"ArrayRef {other_reg} restore")
            return var
        
        elif mode == 'generate_rvalue':
            with self._debug_block(f"Load value at subscripted address into {dest_reg}"):
                if var.sizeof_element() <= 2:
                    self._deref_load(var.sizeof_element(), addr_reg=other_reg, dest_reg=dest_reg)
                else:
                    # Return address for large elements
                    self.emit(f"ALUOP_{dest_reg}H %{other_reg}%+%{other_reg}H%", f"Copy subscripted address from {other_reg} to {dest_reg}")
                    self.emit(f"ALUOP_{dest_reg}L %{other_reg}%+%{other_reg}L%", f"Copy subscripted address from {other_reg} to {dest_reg}")
            self.emit(f"POP_{other_reg}L", f"ArrayRef {other_reg} restore")
            self.emit(f"POP_{other_reg}H", f"ArrayRef {other_reg} restore")
            return Variable(typespec=var.typespec, name=f"{var.name}_element")
        else:
            raise NotImplementedError(f"visit_ArrayRef mode {mode} not yet supported")

    def visit_Constant(self, node, mode, dest_reg='A', dest_typespec=None, **kwargs):
        if mode == 'return_typespec':
            if dest_typespec:
                return dest_typespec
            elif node.type == 'string':
                return TypeSpec('string', 'char')
            elif node.type == 'int':
                return TypeSpec('int', 'int')
            elif node.type == 'char':
                return TypeSpec('char', 'char')
            else:
                raise NotImplementedError(f"Unrecognized constant type: {node.type}")
        elif mode == 'get_value':
            if node.type == 'int':
                return (int(node.value, base=0), node.value)
            elif node.type == 'char':
                return (ord(ast.literal_eval(node.value)), node.value)
            elif node.type == 'string':
                return (self.context.literalreg.lookup_by_content(node.value, 'string').label, node.value)
            else:
                raise NotImplementedError(f"Unrecognized constant type: {node.type}")
        elif mode == 'return_array_dim':
            if node.type == 'string':
                return [ len(node.value) - 1 ] # Rough estimate, actual size depends on escapes
            else:
                raise ValueError(f"I don't know what to do with a Constant {node.type} node for setting array dims")
        elif mode == 'generate_rvalue':
            # Register string literals as we encounter them, and
            # for these, the rvalue is the address (label) of the string.
            if node.type == 'string':
                # Remove quotes from the string value
                content = node.value
                # Calculate size (including null terminator)
                # The value includes quotes, so we need to process escape sequences
                size = len(content) - 1  # Rough estimate, actual size depends on escapes
                self.context.literalreg.register(content, 'string', size)
                # Now that it's registered, return the address
                # of the literal in the dest_reg
                literal = self.context.literalreg.lookup_by_content(content, 'string')
                self.emit(f"LDI_{dest_reg} {literal.label}", content)
                # return fake Variable representing the constant
                return Variable(typespec=TypeSpec('string', 'char'), name='init_string', is_array=True, array_dims=[size])
            # For numeric constants, we load the value
            # directly into the destination register.
            elif node.type == 'int':
                if not dest_typespec:
                    self.emit(f"LDI_{dest_reg} {node.value}", "Constant assignment")
                    return Variable(typespec=TypeSpec('int', 'int'), name='const')
                elif dest_typespec.sizeof() == 1:
                    self.emit(f"LDI_{dest_reg}L {node.value}", "Constant assignment")
                    return Variable(typespec=dest_typespec, name='const')
                elif dest_typespec.sizeof() == 2:
                    self.emit(f"LDI_{dest_reg} {node.value}", "Constant assignment")
                    return Variable(typespec=dest_typespec, name='const')
                else:
                    raise NotImplementedError(f"Unable to load integer constants larger than 16 bit")
            elif node.type == 'char':
                const_int = ord(ast.literal_eval(node.value))
                if not dest_typespec:
                    self.emit(f"LDI_{dest_reg} {node.value}", f"Constant char assignment {node.value}")
                    return Variable(typespec=TypeSpec('int', 'int'), name='const')
                elif dest_typespec.sizeof() == 1:
                    self.emit(f"LDI_{dest_reg}L {node.value}", f"Constant char assignment {node.value}")
                    return Variable(typespec=dest_typespec, name='const')
                elif dest_typespec.sizeof() == 2:
                    self.emit(f"LDI_{dest_reg} {node.value}", f"Constant char assignment {node.value}")
                    return Variable(typespec=dest_typespec, name='const')
                else:
                    raise NotImplementedError(f"Unable to load char constants larger than 16 bit")
            else:
                raise NotImplementedError(f"Constant value for {node.type} types not yet supported")
        else:
            raise NotImplementedError(f"visit_Constant mode {mode} not yet supported")

    def visit_InitList(self, node, mode, dest_reg='A', dest_typespec=None, **kwargs):
        if mode == 'return_array_dim':
            # Return the number of elements in the init list
            return [len(node.exprs)]
        elif mode == 'generate_rvalue':
            # Recursively flatten the init list into bytes
            def flatten_init_list(init_node, target_typespec):
                """
                Recursively process an InitList node and return:
                - A list of hex byte strings (e.g., ["0x0a", "0x14"])
                - A list of values for documentation
                - A list of comment strings
                - Total byte count
                """
                parts = []
                vals = []
                comments = []
                byte_count = 0

                if target_typespec and target_typespec.is_struct:
                    # Processing struct initialization
                    for expr, struct_member in zip(init_node.exprs, target_typespec.struct_members):
                        if type(expr) is c_ast.InitList:
                            # Recursively flatten nested init list
                            sub_parts, sub_vals, sub_comments, sub_bytes = flatten_init_list(expr, struct_member.typespec)
                            parts.extend(sub_parts)
                            vals.extend(sub_vals)
                            comments.append(f"<nested {struct_member.name}>")
                            byte_count += sub_bytes
                        else:
                            # Simple constant value
                            ts = self.visit(expr, mode='return_typespec', dest_typespec=struct_member.typespec, **kwargs)
                            val, c_val = self.visit(expr, mode='get_value', dest_typespec=struct_member.typespec, **kwargs)
                            comments.append(c_val)

                            if ts.sizeof() == 1:
                                parts.append(f"0x{val:02x}")
                                vals.append(val & 0xff)
                                byte_count += 1
                            elif ts.sizeof() == 2:
                                low = val & 0xff
                                high = (val & 0xff00) >> 8
                                parts.append(f"0x{low:02x}")
                                parts.append(f"0x{high:02x}")
                                vals.append(val & 0xffff)
                                byte_count += 2
                            else:
                                raise ValueError(f"Unable to create data from value with size > 2: {ts}")
                else:
                    # Processing array initialization
                    for expr in init_node.exprs:
                        if type(expr) is c_ast.InitList:
                            # Recursively flatten nested init list
                            element_typespec = target_typespec if target_typespec else None
                            sub_parts, sub_vals, sub_comments, sub_bytes = flatten_init_list(expr, element_typespec)
                            parts.extend(sub_parts)
                            vals.extend(sub_vals)
                            comments.append("<nested>")
                            byte_count += sub_bytes
                        else:
                            # Simple constant value
                            ts = self.visit(expr, mode='return_typespec', dest_typespec=target_typespec, **kwargs)
                            val, c_val = self.visit(expr, mode='get_value', dest_typespec=target_typespec, **kwargs)
                            comments.append(c_val)

                            if ts.sizeof() == 1:
                                parts.append(f"0x{val:02x}")
                                vals.append(val & 0xff)
                                byte_count += 1
                            elif ts.sizeof() == 2:
                                low = val & 0xff
                                high = (val & 0xff00) >> 8
                                parts.append(f"0x{low:02x}")
                                parts.append(f"0x{high:02x}")
                                vals.append(val & 0xffff)
                                byte_count += 2
                            else:
                                raise ValueError(f"Unable to create data from value with size > 2: {ts}")

                return parts, vals, comments, byte_count

            # Flatten the entire init list
            literal_parts, literal_vals, literal_comment, byte_count = flatten_init_list(node, dest_typespec)

            # Create the literal
            if dest_typespec and dest_typespec.is_struct:
                comment_str = f"Struct {dest_typespec.name} initializer data: {{{', '.join(literal_comment)}}}"
            else:
                type_name = dest_typespec.name if dest_typespec else "byte"
                comment_str = f"{type_name} initializer data: {{{', '.join(literal_comment)}}}"

            self.context.literalreg.register(" ".join(literal_parts), 'bytes', len(literal_parts), comment=comment_str)

            # Get the literal we just registered and load its address
            literal = self.context.literalreg.lookup_by_content(" ".join(literal_parts), 'bytes')
            self.emit(f"LDI_{dest_reg} {literal.label}", literal_vals if literal_vals else literal_parts)

            # Return a fake variable representing the initialized data
            retvar = Variable(typespec=TypeSpec('byte', 'unsigned char'),
                             name='initlist', is_array=True, array_dims=[byte_count])
            return retvar
        else:
            raise NotImplementedError(f"visit_InitList mode {mode} not yet supported")

    def visit_ID(self, node, mode, dest_reg='A', **kwargs):
        if mode == 'return_var':
            return self.context.vartable.lookup(node.name)
        if mode == 'return_function':
            return self.context.funcreg.lookup(node.name)
        elif mode == 'generate_lvalue_address':
            # generate the address of the identifier and place the value in dest_reg
            var = self.context.vartable.lookup(node.name)
            if not var:
                raise ValueError(f"Unable to find variable {node.name} in variable table")
            self._get_var_base_address(var, dest_reg)
            return var
        elif mode == 'generate_rvalue':
            # Get the value of the identifier and place the value in dest_reg
            var = self.context.vartable.lookup(node.name)
            if not var:
                raise ValueError(f"Unable to find variable {node.name} in variable table")
            if var.is_array or var.is_pointer or var.typespec.is_struct:
                # Arrays and Structs decay to pointers
                # Load pointer value
                other_reg = 'B' if dest_reg == 'A' else 'A'
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"Save {other_reg} while we load pointer")
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"Save {other_reg} while we load pointer")
                self._get_var_base_address(var, other_reg)
                self._deref_load(2, addr_reg=other_reg, dest_reg=dest_reg)  # Load 2-byte pointer
                if var.is_pointer:
                    var.pointer_depth -= 1
                    if var.pointer_depth == 0:
                        var.is_pointer = False
                self.emit(f"POP_{other_reg}H", f"Restore {other_reg}, pointer is in {dest_reg}")
                self.emit(f"POP_{other_reg}L", f"Restore {other_reg}, pointer is in {dest_reg}")
            else:
                # Load simple value
                other_reg = 'B' if dest_reg == 'A' else 'A'
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"Save {other_reg} while we load value")
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"Save {other_reg} while we load value")
                self._get_var_base_address(var, other_reg)
                self._deref_load(var.sizeof(), addr_reg=other_reg, dest_reg=dest_reg)
                self.emit(f"POP_{other_reg}H", f"Restore {other_reg}, value is in {dest_reg}")
                self.emit(f"POP_{other_reg}L", f"Restore {other_reg}, value is in {dest_reg}")
            return var
        else:
            raise NotImplementedError(f"visit_ID mode {mode} not yet supported")

    def visit_Compound(self, node, mode, **kwargs):
        if mode in ('literal_collection',):
            for c in node:
                self.visit(c, mode=mode, **kwargs)
        elif mode == 'codegen':
            self.context.vartable.push_scope()
            for c in node:
                self.visit(c, mode=mode, **kwargs)
            self.context.vartable.pop_scope()
        else:
            raise NotImplementedError(f"visit_Compound mode {mode} not yet supported")

    def visit_Assignment(self, node, mode, **kwargs):
        if mode == 'codegen':
            if node.op == '=':
                # Set up the destination address, where we will store the result
                # of the rvalue expression, into B. Returns the Variable on the
                # left side of the assignment.
                with self._debug_block(f"Assign op {node.op}: Generate lvalue address"):
                    var = self.visit(node.lvalue, mode='generate_lvalue_address', dest_reg='B')

                # Generate the value we are going to store, into register A (or AL)
                with self._debug_block(f"Assign op {node.op}: Generate rvalue"):
                    if var.typespec.is_struct:
                        self.visit(node.rvalue, mode='generate_rvalue_address', dest_reg='A', dest_typespec=var.typespec)
                    else:
                        self.visit(node.rvalue, mode='generate_rvalue', dest_reg='A', dest_typespec=var.typespec)

                # Store the value
                with self._debug_block(f"Assign op {node.op}: Store rvalue to lvalue"):
                    self._emit_store(var, lvalue_reg='B', rvalue_reg='A')
            else:
                raise NotImplementedError(f"visit_Assignment mode {mode} not yet supported for op {node.op}")
        else:
            raise NotImplementedError(f"visit_Assignment mode {mode} not yet supported")

    def visit_UnaryOp(self, node, mode, dest_reg='A', dest_typespec=None, **kwargs):
        if node.op == '-':
            if mode == 'generate_rvalue':
                with self._debug_block(f"UnaryOp {node.op}: load rvalue into {dest_reg}"):
                    var = self.visit(node.expr, mode=mode, dest_reg=dest_reg, dest_typespec=dest_typespec)
                with self._debug_block(f"UnaryOp {node.op}: invert value in {dest_reg}"):
                    if var.typespec.sizeof() == 1:
                        self.emit(f"ALUOP_{dest_reg}L %-{dest_reg}_signed%+%{dest_reg}L%", "Unary negation")
                    else:
                        self.emit(f"CALL :signed_invert_{dest_reg.lower()}", "Unary negation")
                return var
        elif node.op == '&':
            if mode in ('generate_rvalue', 'generate_lvalue_address',):
                with self._debug_block(f"UnaryOp {node.op}: load lvalue into {dest_reg}"):
                    var = self.visit(node.expr, mode='generate_lvalue_address', dest_reg=dest_reg, dest_typespec=dest_typespec)
                    var.is_pointer = True
                    var.pointer_depth += 1
                return var
            else:
                raise NotImplementedError(f"visit_UnaryOp mode {mode} op {node.op} not yet supported")
        elif node.op == '*':
            if mode in ('generate_rvalue', 'generate_lvalue_address',):
                with self._debug_block(f"UnaryOp {node.op}: load lvalue into {dest_reg}"):
                    other_reg = 'B' if dest_reg == 'A' else 'A'
                    # generate_rvalue places the pointer value into other_reg
                    var = self.visit(node.expr, mode='generate_rvalue', dest_reg=other_reg, dest_typespec=dest_typespec)
                    if mode == 'generate_lvalue_address':
                        return var
                    self._deref_load(var.sizeof(), addr_reg=other_reg, dest_reg=dest_reg)
                    var.pointer_depth -= 1
                    if var.pointer_depth == 0:
                        var.is_pointer = False
                return var
            else:
                raise NotImplementedError(f"visit_UnaryOp mode {mode} op {node.op} not yet supported")
        else:
            raise NotImplementedError(f"visit_UnaryOp mode {mode} op {node.op} not yet supported")

    def _get_var_base_address(self, var, dest_reg='A'):
        """Get base address of a variable into dest_reg."""
        if var.kind == 'global' or (var.kind == 'local' and var.storage_class == 'static'):
            prefix = self._get_static_prefix()
            self.emit(f"LDI_{dest_reg} {prefix}{var.padded_name()}", f"Load base address of {var.name} into {dest_reg}")
        else:
            other_reg = 'A' if dest_reg == 'B' else 'B'
            self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"Load base address of {var.name} into {dest_reg}")
            self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"Load base address of {var.name} into {dest_reg}")
            self.emit(f"MOV_DH_{dest_reg}H", f"Load base address of {var.name} into {dest_reg}")
            self.emit(f"MOV_DL_{dest_reg}L", f"Load base address of {var.name} into {dest_reg}")
            self.emit(f"LDI_{other_reg} {var.offset}", f"Load base address of {var.name} into {dest_reg}")
            self.emit(f"CALL :add16_to_{dest_reg.lower()}", f"Load base address of {var.name} into {dest_reg}")
            self.emit(f"POP_{other_reg}H", f"Load base address of {var.name} into {dest_reg}")
            self.emit(f"POP_{other_reg}L", f"Load base address of {var.name} into {dest_reg}")

    def _add_array_offset(self, var, index_reg='B', addr_reg='A'):
        """Add array[index] offset to address in addr_reg. Destroys index_reg."""
        if index_reg not in ('A', 'B',):
            raise ValueError("index_reg must be A or B")
        if addr_reg not in ('A', 'B',):
            raise ValueError("addr_reg must be A or B")
        element_size = var.sizeof_element()
        if element_size == 1:
            self.emit(f"CALL :add16_to_{addr_reg.lower()}", f"Add array offset in {index_reg} to address reg {addr_reg}")
        elif element_size == 2:
            self.emit(f"CALL :shift16_{index_reg.lower()}_left", f"Add array offset in {index_reg} to address reg {addr_reg}")
            self.emit(f"CALL :add16_to_{addr_reg.lower()}", f"Add array offset in {index_reg} to address reg {addr_reg}")
        elif element_size in (4, 8, 16):
            shifts = {4: 2, 8: 3, 16: 4}[element_size]
            for _ in range(shifts):
                self.emit(f"CALL :shift16_{index_reg.lower()}_left", f"Add array offset in {index_reg} to address reg {addr_reg}")
            self.emit(f"CALL :add16_to_{addr_reg.lower()}", f"Add array offset in {index_reg} to address reg {addr_reg}")
        else:
            # Fallback to multiplication
            self.emit(f"CALL :heap_push_{index_reg}", f"Add array offset in {index_reg} to address reg {addr_reg}")
            self.emit(f"LDI_{index_reg} {element_size}", f"Add array offset in {index_reg} to address reg {addr_reg}")
            self.emit(f"CALL :mul16", f"Add array offset in {index_reg} to address reg {addr_reg}")
            self.emit(f"CALL :heap_pop_{index_reg}", f"Add array offset in {index_reg} to address reg {addr_reg}")
            self.emit(f"CALL :heap_pop_word", f"Add array offset in {index_reg} to address reg {addr_reg}")
            self.emit(f"CALL :add16_to_{addr_reg.lower()}", f"Add array offset in {index_reg} to address reg {addr_reg}")

    def _add_member_offset(self, member_var, addr_reg):
        """Add struct member offset to address in addr_reg."""
        if addr_reg not in ('A', 'B',):
            raise ValueError("addr_reg must be A or B")
        if member_var.offset > 0:
            other_reg = 'B'
            if addr_reg == 'B':
                other_reg='A'
            self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"Add struct member {member_var.name} offset to address in {addr_reg}")
            self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"Add struct member {member_var.name} offset to address in {addr_reg}")
            self.emit(f"LDI_{other_reg} {member_var.offset}", f"Add struct member {member_var.name} offset to address in {addr_reg}")
            self.emit(f"CALL :add16_to_{addr_reg.lower()}", f"Add struct member {member_var.name} offset to address in {addr_reg}")
            self.emit(f"POP_{other_reg}H", f"Add struct member {member_var.name} offset to address in {addr_reg}")
            self.emit(f"POP_{other_reg}L", f"Add struct member {member_var.name} offset to address in {addr_reg}")

    def _deref_load(self, size, addr_reg, dest_reg):
        """Load 'size' bytes from address in addr_reg into dest_reg. Destroys addr_reg."""
        if addr_reg == dest_reg:
            raise ValueError("Cannot perform deref load with addr_reg and dest_reg the same")
        if size == 1:
            self.emit(f"LDA_{addr_reg}_{dest_reg}L", f"Dereferenced load")
        elif size == 2:
            self.emit(f"LDA_{addr_reg}_{dest_reg}H", f"Dereferenced load")
            if addr_reg in ('A', 'B',):
                self.emit(f"CALL :incr16_{addr_reg.lower()}", f"Dereferenced load")
            else:
                self.emit(f"INCR_{addr_reg}", f"Dereferenced load")
            self.emit(f"LDA_{addr_reg}_{dest_reg}L", f"Dereferenced load")
            if addr_reg in ('A', 'B',):
                self.emit(f"CALL :decr16_{addr_reg.lower()}", f"Dereferenced load")
            else:
                self.emit(f"DECR_{addr_reg}", f"Dereferenced load")
        else:
            raise ValueError(f"Cannot deref load size > 2 into register")

    def _emit_bulk_store(self, var, lvalue_reg, rvalue_reg, bytes=None):
        """
        Performs a bulk copy memory-to-memory, from the rvalue_reg
        (which should be a memory address of the source value), to
        the lvalue_reg (which should also be a memory address. The
        variable representing the lvalue_reg's address is passed in,
        and determines the number of bytes to be copied from the
        rvalue_reg. If `bytes` is provided, it overrides the var.sizeof()
        value.
        """
        with self._debug_block(f"Bulk copy from address in {rvalue_reg} to address in {lvalue_reg} ({var.friendly_name()})"):
            if bytes:
                self.emit_debug(f"Bulk copy limited to {bytes} bytes")
            self.emit(f"PUSH_DH", "Save frame pointer")
            self.emit(f"PUSH_DL", "Save frame pointer")
            self.emit(f"PUSH_CH", "Save C register")
            self.emit(f"PUSH_CL", "Save C register")
            self.emit(f"ALUOP_CH %{rvalue_reg}%+%{rvalue_reg}H%", "Copy source pointer to C")
            self.emit(f"ALUOP_CL %{rvalue_reg}%+%{rvalue_reg}L%", "Copy source pointer to C")
            self.emit(f"ALUOP_DH %{lvalue_reg}%+%{lvalue_reg}H%", "Set destination pointer in D")
            self.emit(f"ALUOP_DL %{lvalue_reg}%+%{lvalue_reg}L%", "Set destination pointer in D")
            byte=0
            if bytes:
                bytecount = bytes
            else:
                bytecount = var.sizeof()
            four, one = divmod(bytecount, 4)
            for _ in range(four):
                newbyte = byte + 4
                self.emit("MEMCPY4_C_D", f"Copy bytes {byte}-{newbyte-1} from C to D")
                byte = newbyte
            for byte in range(byte, byte+one):
                self.emit("MEMCPY_C_D", f"Copy byte {byte} from C to D")
                byte = byte + 1
            self.emit(f"POP_CL", "Restore C register")
            self.emit(f"POP_CH", "Restore C register")
            self.emit(f"POP_DL", "Restore frame pointer")
            self.emit(f"POP_DH", "Restore frame pointer")

    def _emit_store(self, var, lvalue_reg, rvalue_reg):
        """
        lvalue_reg contains the address we need to write, representing var.
        rvalue_reg contains the value we need to write.
        If var is a struct, rvalue_reg must contain a pointer to the source data,
        and a bulk store is performed.  For any other data type, the value in
        rvalue_reg is the actual data value (not a pointer).
        """
        if var.typespec.is_struct:
            self._emit_bulk_store(var, lvalue_reg, rvalue_reg)
        else:
            if var.typespec.sizeof() == 1:
                self.emit(f"ALUOP_ADDR_{lvalue_reg} %{rvalue_reg}%+%{rvalue_reg}L%", f"Store to {var.friendly_name()}")
            elif var.typespec.sizeof() == 2:
                self.emit(f"ALUOP_ADDR_{lvalue_reg} %{rvalue_reg}%+%{rvalue_reg}H%", f"Store to {var.friendly_name()}")
                self.emit(f"CALL :incr16_{lvalue_reg.lower()}", f"Store to {var.friendly_name()}")
                self.emit(f"ALUOP_ADDR_{lvalue_reg} %{rvalue_reg}%+%{rvalue_reg}L%", f"Store to {var.friendly_name()}")
                self.emit(f"CALL :decr16_{lvalue_reg.lower()}", f"Store to {var.friendly_name()}")
            else:
                raise NotImplementedError(f"_emit_store can't store simple values larger than 16 bit")

