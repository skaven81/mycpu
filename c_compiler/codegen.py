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

    def visit(self, node, mode, **kwargs):
        """
        Visit a node with a specified mode, and allow additional
        arguments 
        """
        if node is None:
            return None
            
        method = 'visit_' + node.__class__.__name__
        visitor = getattr(self, method, self.generic_visit)

        try:
            if self.context.verbose > 1:
                node_name = None
                if type(getattr(node, 'name', None)) is str:
                    node_name = node.name
                elif type(getattr(getattr(node, 'name', None), 'name', None)) is str:
                    node_name = node.name.name
                with self._debug_block(f"Visiting {node.__class__.__name__} {node_name if node_name else ''} mode {mode}"):
                    ret = visitor(node, mode, **kwargs)
            else:
                ret = visitor(node, mode, **kwargs)
        except Exception as e:
            parts = [str(e)]
            if hasattr(node, 'coord') and node.coord:
                parts.append(f"  At source: {node.coord}")
            else:
                parts.append(f"  AST node has no coord attribute")

            # For SyntaxError, modify the msg attribute as it doesn't use args
            if isinstance(e, SyntaxError):
                e.msg = "\n".join(parts)

            e.args = ("\n".join(parts),) + e.args[1:] if len(e.args) > 1 else ("\n".join(parts),)
            raise e
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
                    if var.storage_class == 'extern':
                        self.emit_verbose(f"External global declaration: assuming ${var.padded_name()} exists")
                    elif prefix == '$':
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
                        if var.sizeof() == 1:
                            self.emit(f"VAR global byte ${var.padded_name()}")
                        elif var.sizeof() == 2:
                            self.emit(f"VAR global word ${var.padded_name()}")
                        else:
                            self.emit(f"VAR global {var.sizeof()} ${var.padded_name()}")
                    else:
                        self.emit(f'.{var.padded_name()} "' + '\\0'*var.sizeof() + '"')
        else:
            raise NotImplementedError(f"visit_FileAST mode {mode} not yet supported")

    def visit_If(self, node, mode, **kwargs):
        if mode == 'codegen':
            true_label = self._get_label("condition_true")
            done_label = self._get_label("end_if")
            with self._debug_block("If block"):
                with self._debug_block("If block: condition"):
                    cond_var = self.visit(node.cond, mode='generate_rvalue', dest_reg='A', **kwargs)
                    if cond_var.sizeof() == 2:
                        #                          low      hi-if-Z  hi-if-NZ
                        self.emit(f"ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL%", f"Check if condition")
                    elif cond_var.sizeof() == 1:
                        self.emit(f"ALUOP_FLAGS %A%+%AL%", f"Check if condition")
                    self.emit(f"JNZ {true_label}", f"Condition was true")
                    self.emit_verbose("Condition was false")
                with self._debug_block("If block: false condition"):
                    self.visit(node.iffalse, mode='codegen', **kwargs)
                    self.emit(f"JMP {done_label}", f"Done with false condition")
                with self._debug_block("If block: true condition"):
                    self.emit(f"{true_label}", f"Condition was true")
                    self.visit(node.iftrue, mode='codegen', **kwargs)
                self.emit(f"{done_label}", f"End If")
        else:
            raise NotImplementedError(f"visit_If mode {mode} not yet supported")

    def visit_Break(self, node, mode, break_label, **kwargs):
        if mode == 'codegen':
            self.emit(f"JMP {break_label}", "Break out of loop/switch")
        else:
            raise NotImplementedError(f"visit_Break mode {mode} not yet supported")

    def visit_Continue(self, node, mode, continue_label, **kwargs):
        if mode == 'codegen':
            self.emit(f"JMP {continue_label}", "Continue loop")
        else:
            raise NotImplementedError(f"visit_Continue mode {mode} not yet supported")

    def visit_DoWhile(self, node, mode, **kwargs):
        if mode == 'codegen':
            top_label = self._get_label("dowhile_top")
            cond_label = self._get_label("dowhile_condition")
            done_label = self._get_label("dowhile_end")
            # nested loops may carry the continue and break labels from an upstream
            # loop.  We remove those from kwargs so that the body visit() doesn't
            # duplicate the continue and break label args.
            if 'continue_label' in kwargs:
                del(kwargs['continue_label'])
            if 'break_label' in kwargs:
                del(kwargs['break_label'])
            with self._debug_block("DoWhile block"):
                self.emit(f"ALUOP_PUSH %A%+%AH%", "Preserve A for dowhile loop condition")
                self.emit(f"ALUOP_PUSH %A%+%AL%", "Preserve A for dowhile loop condition")
                self.emit(f"{top_label}", f"DoWhile loop begin")
                with self._debug_block("DoWhile body"):
                    self.visit(node.stmt, mode='codegen', continue_label=cond_label, break_label=done_label, **kwargs)
                with self._debug_block("DoWhile condition"):
                    self.emit(f"{cond_label}", "DoWhile condition")
                    cond_var = self.visit(node.cond, mode='generate_rvalue', dest_reg='A', **kwargs)
                    self.emit(f"ALUOP_FLAGS %A%+%AL%", f"Check dowhile condition")
                    self.emit(f"JNZ {top_label}", f"Condition was true")
                    if cond_var.sizeof() == 2:
                        self.emit(f"ALUOP_FLAGS %A%+%AH%", f"Check dowhile condition")
                        self.emit(f"JNZ {top_label}", f"Condition was true")
                self.emit(f"{done_label}", f"Condition was false, end loop")
                self.emit(f"POP_AL", "Restore A from dowhile loop condition")
                self.emit(f"POP_AH", "Restore A from dowhile loop condition")
        else:
            raise NotImplementedError(f"visit_DoWhile mode {mode} not yet supported")

    def visit_While(self, node, mode, **kwargs):
        if mode == 'codegen':
            top_label = self._get_label("while_top")
            true_label = self._get_label("while_true")
            done_label = self._get_label("while_end")
            # nested loops may carry the continue and break labels from an upstream
            # loop.  We remove those from kwargs so that the body visit() doesn't
            # duplicate the continue and break label args.
            if 'continue_label' in kwargs:
                del(kwargs['continue_label'])
            if 'break_label' in kwargs:
                del(kwargs['break_label'])
            with self._debug_block("While block"):
                self.emit(f"ALUOP_PUSH %A%+%AH%", "Preserve A for while loop condition")
                self.emit(f"ALUOP_PUSH %A%+%AL%", "Preserve A for while loop condition")
                self.emit(f"{top_label}", f"While loop begin")
                with self._debug_block("While condition"):
                    cond_var = self.visit(node.cond, mode='generate_rvalue', dest_reg='A', **kwargs)
                    self.emit(f"ALUOP_FLAGS %A%+%AL%", f"Check while condition")
                    self.emit(f"JNZ {true_label}", f"Condition was true")
                    if cond_var.sizeof() == 2:
                        self.emit(f"ALUOP_FLAGS %A%+%AH%", f"Check while condition")
                        self.emit(f"JNZ {true_label}", f"Condition was true")
                    self.emit(f"JMP {done_label}", f"Condition was false, end loop")
                with self._debug_block("While body"):
                    self.emit(f"{true_label}", f"Begin while loop body")
                    self.visit(node.stmt, mode='codegen', continue_label=top_label, break_label=done_label, **kwargs)
                    self.emit(f"JMP {top_label}", f"Next While loop")
                self.emit(f"{done_label}", "End while loop")
                self.emit(f"POP_AL", "Restore A from while loop condition")
                self.emit(f"POP_AH", "Restore A from while loop condition")
        else:
            raise NotImplementedError(f"visit_While mode {mode} not yet supported")

    def visit_DeclList(self, node, mode, **kwargs):
        if mode == 'codegen':
            for decl in node.decls:
                self.visit(decl, mode='codegen', **kwargs)
        else:
            raise NotImplementedError(f"visit_DeclList mode {mode} not yet supported")

    def visit_For(self, node, mode, **kwargs):
        if mode == 'codegen':
            # nested loops may carry the continue and break labels from an upstream
            # loop.  We remove those from kwargs so that the body visit() doesn't
            # duplicate the continue and break label args.
            if 'continue_label' in kwargs:
                del(kwargs['continue_label'])
            if 'break_label' in kwargs:
                del(kwargs['break_label'])

            cond_label = self._get_label("for_condition")
            incr_label = self._get_label("for_increment")
            true_label = self._get_label("for_cond_true")
            sub_true_label = self._get_label("for_cond_sub_true")
            done_label = self._get_label("for_end")
            with self._debug_block("For loop"):
                with self._debug_block("For loop init"):
                    self.visit(node.init, mode='codegen', **kwargs)
                with self._debug_block("For loop condition"):
                    self.emit(f"{cond_label}", "For loop condition check")
                    self.emit(f"ALUOP_PUSH %A%+%AH%", "Preserve A for loop condition")
                    self.emit(f"ALUOP_PUSH %A%+%AL%", "Preserve A for loop condition")
                    cond_var = self.visit(node.cond, mode='generate_rvalue', dest_reg='A', **kwargs)
                    if cond_var.sizeof() == 1:
                        self.emit(f"ALUOP_FLAGS %A%+%AL%", f"Check for condition")
                        self.emit(f"POP_AL", "Restore A from for loop condition")
                        self.emit(f"POP_AH", "Restore A from for loop condition")
                        self.emit(f"JNZ {true_label}", f"Condition was true")
                        self.emit(f"JMP {done_label}", f"Condition was false, end loop")
                    elif cond_var.sizeof() == 2:
                        self.emit(f"ALUOP_FLAGS %A%+%AL%", f"Check for condition")
                        self.emit(f"JNZ {sub_true_label}", f"Condition was true")
                        self.emit(f"ALUOP_FLAGS %A%+%AH%", f"Check for condition")
                        self.emit(f"JNZ {sub_true_label}", f"Condition was true")
                        self.emit(f"POP_AL", "Restore A from for loop condition")
                        self.emit(f"POP_AH", "Restore A from for loop condition")
                        self.emit(f"JMP {done_label}", f"Condition was false, end loop")
                        self.emit(f"{sub_true_label}")
                        self.emit(f"POP_AL", "Restore A from for loop condition")
                        self.emit(f"POP_AH", "Restore A from for loop condition")
                    else:
                        raise ValueError(f"condition var has unexpected size: {cond_var.friendly_name()} {cond_var.sizeof()}")
                with self._debug_block("For loop body"):
                    self.emit(f"{true_label}", f"Begin for loop body")
                    self.visit(node.stmt, mode='codegen', continue_label=incr_label, break_label=done_label, **kwargs)
                with self._debug_block("For loop next"):
                    self.emit(f"{incr_label}", f"Begin for loop increment")
                    self.visit(node.next, mode='codegen', **kwargs)
                    self.emit(f"JMP {cond_label}", "Next for loop iteration")
                self.emit(f"{done_label}", "End for loop")
            pass
        else:
            raise NotImplementedError(f"visit_For mode {mode} not yet supported")

    def visit_Switch(self, node, mode, **kwargs):
        if mode == 'codegen':
            done_label = self._get_label("switch_end")
            cond_var = None
            with self._debug_block("Switch"):
                with self._debug_block("Switch: Load case statements and assign labels"):
                    if type(node.stmt) is not c_ast.Compound:
                        raise SyntaxError("Switch statements must contain a Compound with Case and Default statements")
                    cases = []
                    seen_values = set()
                    for c in node.stmt.block_items or []:
                        if type(c) is c_ast.Case:
                            try:
                                val = self.visit(c.expr, mode='get_value')
                                if val[0] in seen_values:
                                    raise SyntaxError(f"Duplicate case statement in switch: {val}")
                                seen_values.add(val[0])
                            except NotImplementedError as e:
                                raise SyntaxError(f"Case statements must have constant integer expressions that are supported with the get_value mode: {e}")
                            cases.append( (val[0], val[1], self._get_label('switch_case'), c.stmts or []) )
                        elif type(c) is c_ast.Default:
                            cases.append( (None, 'default', self._get_label('switch_case'), c.stmts or []) )
                        else:
                            raise SyntaxError("Switch statements may only contain Case and Default nodes")
                    self.emit_debug("Cases: " + str([(c[0], c[1], c[2]) for c in cases]))
                with self._debug_block("Switch: load condition into A"):
                    cond_var = self.visit(node.cond, mode='generate_rvalue', dest_reg='A', **kwargs)
                with self._debug_block("Switch: branch block"):
                    for case in [c for c in cases if c[0] is not None]:
                        with self._debug_block(f"Switch: case {case[1]}"):
                            if cond_var.sizeof() == 1:
                                self.emit(f"LDI_BL {case[0]}", f"case {case[1]}")
                                self.emit(f"ALUOP_FLAGS %A&B%+%AL%+%BL%", "Check condition")
                                self.emit(f"JEQ {case[2]}", "Jump if match")
                            elif cond_var.sizeof() == 2:
                                false_label = self._get_label("switch_case_false")
                                self.emit(f"LDI_B {case[0]}", f"case {case[1]}")
                                self.emit(f"ALUOP_FLAGS %A&B%+%AL%+%BL%", "Check condition")
                                self.emit(f"JNE {false_label}", "Go to next case if no match")
                                self.emit(f"ALUOP_FLAGS %A&B%+%AH%+%BH%", "Check condition")
                                self.emit(f"JNE {false_label}", "Go to next case if no match")
                                self.emit(f"JMP {case[2]}", "Jump if match")
                                self.emit(f"{false_label}", "Jump here if condidtion did not match")
                            else:
                                raise ValueError("cond_var can't be more than 2 bytes")
                    default_cases = [c for c in cases if c[0] is None]
                    if len(default_cases) > 1:
                        raise SyntaxError("Multiple default switch cases are not allowed")
                    if default_cases:
                        with self._debug_block(f"Switch: case {default_cases[0][1]}"):
                            self.emit(f"JMP {default_cases[0][2]}", "Jump to default case")
                    else:
                        self.emit(f"JMP {done_label}", "No cases matched, and no default, exit switch")
                with self._debug_block("Switch: case statements"):
                    for case in cases:
                        case_end = self._get_label("case_end")
                        with self._debug_block(f"Switch: case {case[0]} {case[1]}"):
                            self.emit(case[2], f"Case {case[1]} begin")
                            for s in case[3]:
                                self.visit(s, mode='codegen', break_label=done_label, **kwargs)
                            self.emit(case_end, f"Case {case[1]} end")
                with self._debug_block("Switch: epilogue"):
                    self.emit(f"{done_label}", "End switch")

        else:
            raise NotImplementedError(f"visit_Switch mode {mode} not yet supported")

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
            if not new_type.name:
                new_type.name = node.declname
            return new_type
        elif mode == 'return_typespec':
            return self.visit(node.type, mode=mode, **kwargs)
        elif mode == 'return_var':
            return Variable(name=node.declname,
                            typespec=self.visit(node.type, mode='return_typespec', **kwargs),
                            qualifiers=node.quals,
                            is_virtual=True)
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
            if not registered_type:
                raise ValueError(f"Type {type_name} not registered during type collection")
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
            ts = self.context.typereg.lookup(node.name)
            if not ts:
                raise SyntaxError(f"Struct type {node.name} used without declaration")
            return ts
        else:
            raise NotImplementedError(f"visit_Struct mode {mode} not yet supported")

    def visit_StructRef(self, node, mode, dest_reg='A', **kwargs):
        """
        Visit a struct member access: struct.member or ptr->member

        generate_lvalue: Returns address of member in dest_reg
        generate_rvalue: Returns value of member in dest_reg
                         (large members/nested structs return address)
        """
        # Get struct base address
        with self._debug_block(f"Get base address of struct into {dest_reg}"):
            if node.type == '.':
                # struct.member - get address of struct
                base_var = self.visit(node.name, mode='generate_lvalue', dest_reg=dest_reg)
            else:  # '->'
                # ptr->member - get value of pointer (which is an address)
                base_var = self.visit(node.name, mode='generate_rvalue', dest_reg=dest_reg)

        # Get member metadata
        member_var = base_var.typespec.struct_member(node.field.name)
        if mode == 'return_var':
            return member_var

        # Add member offset to base address
        with self._debug_block(f"Add member offset {member_var.offset} to struct address"):
            self._add_member_offset(member_var, dest_reg)

        if mode == 'generate_lvalue':
            # Address is already in dest_reg
            return member_var

        elif mode == 'generate_rvalue':
            # Check if we should load value or return address
            if member_var.sizeof() <= 2 and not member_var.is_array and not member_var.typespec.is_struct:
                # Load small value
                with self._debug_block(f"Load member value into {dest_reg}"):
                    other_reg = 'B' if dest_reg == 'A' else 'A'
                    self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"StructRef member value: Save {other_reg}")
                    if member_var.sizeof() == 2:
                        self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"StructRef member value: Save {other_reg}")

                    self._deref_load(member_var.sizeof(), addr_reg=dest_reg, dest_reg=other_reg)

                    # Transfer to dest_reg
                    if member_var.sizeof() == 2:
                        self.emit(f"ALUOP_{dest_reg}H %{other_reg}%+%{other_reg}H%", f"Transfer value")
                    self.emit(f"ALUOP_{dest_reg}L %{other_reg}%+%{other_reg}L%", f"Transfer value")

                    if member_var.sizeof() == 2:
                        self.emit(f"POP_{other_reg}H", f"StructRef member value: Restore {other_reg}")
                    self.emit(f"POP_{other_reg}L", f"StructRef member value: Restore {other_reg}")
                return member_var
            else:
                # Return address for large members, arrays, or nested structs
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
            if type(node.type) is c_ast.FuncDecl:
                raise ValueError(f"return_var for FuncDecl type Decl node doesn't make sense")
            if type(node.type) is c_ast.Struct:
                raise ValueError(f"return_var for Struct type Decl node should not happen: declare structs at top level, not locally")
            # New Variable declaration and storage allocation
            if type(node.type) in (c_ast.TypeDecl, c_ast.PtrDecl, c_ast.ArrayDecl):
                new_typespec = self.visit(node.type, mode='return_typespec', init=getattr(node, 'init'))
                new_var = self.visit(node.type, mode='return_var', var_kind=var_kind, register_var=register_var, **kwargs)
                assert new_var is not None
                if node.storage:
                    new_var.storage_class = node.storage[0]
                if not new_var.name:
                    new_var.name = node.name
                new_var.qualifiers.extend(node.quals)
                # return_var above will have returned a "fake" variable with
                # is_virtual set.  But we know this is a real declared variable
                # and so we mark it as not-virtual here before registering.
                new_var.is_virtual = False
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
                        if new_var.storage_class != 'static' and not new_var.offset:
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
                    if (var.is_array or var.typespec.is_struct) and not var.is_pointer:
                        self.visit(c_ast.ID(name=var.name), mode='generate_lvalue', dest_reg='B')
                        init_var = self.visit(node.init, mode='generate_rvalue', dest_reg='A', dest_var=var)
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
            params = []
            if node.args:
                params = self.visit(node.args, mode='return_parameter_vars')
            for p in params:
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
                if new_param.typespec.base_type == 'void' and not new_param.is_pointer:
                    continue # skip lone 'void' parameters
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

    def visit_Typename(self, node, mode, **kwargs):
        if mode == 'return_var':
            typespec = self.visit(node.type, mode='return_typespec')
            return Variable(typespec=typespec, name=typespec.name, is_type_wrapper=True)
        elif mode == 'return_typespec':
            return self.visit(node.type, mode='return_typespec')
        else:
            raise NotImplementedError(f"visit_Typename mode {mode} not yet supported")

    def visit_EllipsisParam(self, node, mode, **kwargs):
        if mode == 'return_var':
           return Variable(typespec=TypeSpec(name='...', base_type = '...', _registry=self.context.typereg),
                           name='...',
                           kind='param',
                           is_virtual=True)
        else:
            raise NotImplementedError(f"visit_EllipsisParam mode {mode} not yet supported")

    def visit_FuncDef(self, node, mode, **kwargs):
        # if kwargs contains a 'return_label' key, we have nested
        # function definitions (which probably shouldn't happen but
        # it's easy enough to add support for) and need to ensure
        # that the body code generation doesn't duplicate that key.
        if 'return_label' in kwargs:
            del(kwargs['return_label'])

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
                return_label = self._get_label(f"{func.name}_return")

                # Save the current stack
                self.emit_stackpush()

                # Set frame pointer
                self.emit("LD_DH $heap_ptr", "Set frame pointer")
                self.emit("LD_DL $heap_ptr+1", "Set frame pointer")

                # Local variable memory allocation
                localvar_bytes = self._total_localvar_size(node)
                self.emit_verbose(f"Found {localvar_bytes} bytes of local vars in this function")
                # Advance stack pointer
                if localvar_bytes > 0:
                    self.emit(f"LDI_BL {localvar_bytes}", "Bytes to allocate for local vars")
                    self.emit(f"CALL :heap_advance_BL")
                # Reset localvar offset so new registrations get correct offsets
                self.context.vartable.localvar_offset = 1
                # Register parameter variables; offsets were computed in function_collection pass
                parameter_bytes = 0
                if func.parameters:
                    for p in func.parameters:
                        if p.offset is None:
                            continue
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
                    self.visit(c, mode='codegen', return_label=return_label)

                # Function epilogue
                self.emit(return_label)

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

    def visit_Return(self, node, mode, return_label, **kwargs):
        if mode == 'codegen':
            self.visit(node.expr, mode='generate_rvalue', dest_reg='A')
            self.emit(f"JMP {return_label}")
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
                        return Variable(typespec=func.return_type, name=func.name, is_virtual=True)
                    return

                # Otherwise, it's a function with standard call semantics (heap_push
                # arguments in reverse order, call, heap_pop return value)
                if node.args:
                    param_vars = reversed(func.parameters)
                    arg_nodes = reversed(self.visit(node.args, mode='return_nodes'))
                    for pv, an in zip(param_vars, arg_nodes):
                        with self._debug_block(f"FuncCall {func.name} push parameter {pv.friendly_name()}"):
                            if pv.is_pointer:
                                rvalue_var = self.visit(an, mode='generate_rvalue', dest_reg='A', dest_var=pv)
                                if not rvalue_var.is_pointer and not rvalue_var.is_array:
                                    raise SyntaxError(f"Incompatible types in function call, function param: {pv.friendly_name()}, call param: {rvalue_var.friendly_name()}")
                                self.emit(f"CALL :heap_push_A", f"Push parameter {pv.friendly_name()} (pointer)")
                            elif pv.is_array or pv.typespec.is_struct:
                                rvalue_var = self.visit(an, mode='generate_lvalue', dest_reg='A', dest_var=pv)
                                if pv.is_array and (not rvalue_var.is_pointer or not rvalue_var.is_array):
                                    raise SyntaxError(f"Incompatible types in function call, function param: {pv.friendly_name()}, call param: {rvalue_var.friendly_name()}")
                                if pv.typespec.is_struct and (not rvalue_var.is_pointer or not rvalue_var.typespec.is_struct):
                                    raise SyntaxError(f"Incompatible types in function call, function param: {pv.friendly_name()}, call param: {rvalue_var.friendly_name()}")
                                self.emit(f"CALL :heap_push_A", f"Push parameter {pv.friendly_name()} (pointer to {rvalue_var.friendly_name()})")
                            else:
                                rvalue_var = self.visit(an, mode='generate_rvalue', dest_reg='A', dest_var=pv)
                                if pv.sizeof() != rvalue_var.sizeof():
                                    raise SyntaxError(f"Incompatible types in function call, function param: {pv.friendly_name()}, call param: {rvalue_var.friendly_name()}")
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
                return Variable(typespec=func.return_type, name=func.name, is_virtual=True)
        else:
            raise NotImplementedError(f"visit_FuncCall mode {mode} not yet supported")

    def visit_ExprList(self, node, mode, dest_reg='A', dest_var=None, **kwargs):
        if mode == 'return_nodes':
            return node.exprs if node.exprs else []
        elif mode == 'generate_rvalue':
            # Comma operator: evaluate all nodes but return the value of the last one
            last_var = None
            for c in node.exprs:
                last_var = self.visit(c, mode=mode, dest_reg=dest_reg, dest_var=dest_var, **kwargs)
            return last_var
        elif mode == 'codegen':
            for c in node.exprs:
                self.visit(c, mode=mode, dest_reg=dest_reg, dest_var=dest_var, **kwargs)
        else:
            raise NotImplementedError(f"visit_ExprList mode {mode} not yet supported: {node}")

    def _total_localvar_size(self, node) -> int:
        """
        Recursively descend into the entirety of node's AST searching for
        local, non-static variable declarations (excluding parameters) and
        total up their size.
        """
        # Don't count function parameters in local var size
        if type(node) is c_ast.ParamList:
            return 0

        this_node_size = 0
        if type(node) is c_ast.Decl and type(node.type) is not c_ast.FuncDecl:
            var = self.visit(node, mode='return_var', register_var=False)
            this_node_size = var.sizeof() if var.storage_class != 'static' else 0
            if self.context.verbose >= 2:
                self.emit_debug(f"_total_localvar_size: Computed size of {var.friendly_name()} = {var.sizeof()} (effective={this_node_size})")

        recursive_sum = 0
        for child in node:
            recursive_sum += self._total_localvar_size(child)
        return recursive_sum + this_node_size

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
            return new_typespec
        elif mode == 'return_var':
            new_var = self.visit(node.type, mode='return_var', **kwargs)
            new_var.is_array = True
            new_var.qualifiers.extend(node.dim_quals)
            if node.dim:
                new_var.array_dims.append(self.visit(node.dim, mode='get_value', **kwargs)[0])
            return new_var
        else:
            raise NotImplementedError(f"visit_ArrayDecl mode {mode} not yet supported")

    def visit_ArrayRef(self, node, mode, dest_reg='A', **kwargs):
        """
        Visit an array subscript operation: arr[index]

        return_var: Returns Variable metadata for the subscripted element
        generate_lvalue: Returns address of arr[index] element in dest_reg
        generate_rvalue: Returns value of arr[index] element in dest_reg
                         (large elements return address)
        """

        if mode == 'return_var':
            # Recursively get the base array variable
            base_var = self.visit(node.name, mode='return_var')
            if not base_var:
                raise ValueError(f"Cannot get variable info for array subscript")

            # Create element variable with reduced dimensionality
            element_var = Variable(
                typespec=base_var.typespec,
                name=f"{base_var.name}_element",
                is_array=len(base_var.array_dims) > 1,  # Still array if multi-dimensional
                array_dims=base_var.array_dims[1:] if len(base_var.array_dims) > 1 else [],
                pointer_depth=base_var.pointer_depth - 1,
                is_pointer=base_var.pointer_depth > 1,
                is_virtual=True,
            )
            return element_var

        if mode not in ('generate_rvalue', 'generate_lvalue'):
            raise NotImplementedError(f"visit_ArrayRef mode {mode} not yet supported")

        # For generate_lvalue and generate_rvalue modes:
        # We need to know the array dimensions at THIS level (before subscripting)
        # So we get the variable info for the base (node.name), not for this ArrayRef
        base_var = self.visit(node.name, mode='return_var')

        # Save other_reg
        other_reg = 'B' if dest_reg == 'A' else 'A'
        self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"ArrayRef {other_reg} backup")
        self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"ArrayRef {other_reg} backup")

        # Get base address into other_reg
        # For nested ArrayRef, this recursively computes the address
        with self._debug_block(f"Get base address of {base_var.friendly_name()} into {other_reg}"):
            self.visit(node.name, mode='generate_lvalue', dest_reg=other_reg)

        # Compute subscript (offset) into dest_reg
        with self._debug_block(f"Get subscript value into {dest_reg}"):
            # Save base address (computing subscript may clobber other_reg)
            self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"ArrayRef Save base address in {other_reg}")
            self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"ArrayRef Save base address in {other_reg}")

            subscript_var = self.visit(node.subscript, mode='generate_rvalue', dest_reg=dest_reg)
            if not subscript_var:
                raise ValueError("Cannot index array: subscript expression returned no variable")
            if subscript_var.sizeof() == 1:
                self.emit_sign_extend(dest_reg, subscript_var.typespec)

            # Restore base address
            self.emit(f"POP_{other_reg}L", f"ArrayRef Restore base address in {other_reg}")
            self.emit(f"POP_{other_reg}H", f"ArrayRef Restore base address in {other_reg}")

        # Compute element address: base + (index * element_size)
        with self._debug_block(f"Compute element address into {other_reg}"):

            # Calculate element size at THIS level
            # base_var.array_dims tells us the dimensions of the thing being indexed
            # For arr[3][3], when processing outer [2]:
            #   - base_var is the original arr with array_dims=[3,3]
            #   - element_size = sizeof(char) * 3 = 3
            # When processing inner [0] of the result:
            #   - base_var is the result of arr[2] with array_dims=[3]
            #   - element_size = sizeof(char) * 1 = 1

            if len(base_var.array_dims) > 1:
                # Multi-dimensional: element is a sub-array
                # Size = base_element_size * product of remaining dimensions (after this subscript)
                element_size = base_var.typespec.sizeof()
                for dim in base_var.array_dims[1:]:  # Skip first dimension, multiply rest
                    element_size *= dim
            elif base_var.is_pointer:
                # Array of pointers, each element is 2 bytes
                element_size = 2
            else:
                # Single dimension (or final dimension): use base element size
                element_size = base_var.typespec.sizeof()

            self.emit_debug(f"Element size for dimension: {element_size} bytes")

            # Add offset using the correct element size
            self._add_array_offset(
                element_size,
                index_reg=dest_reg,
                addr_reg=other_reg
            )

        # Create result variable (one dimension removed)
        element_var = Variable(
            typespec=base_var.typespec,
            name=f"{base_var.name}_element",
            is_array=len(base_var.array_dims) > 1,  # Still array if multi-dimensional
            array_dims=base_var.array_dims[1:] if len(base_var.array_dims) > 1 else [],
            pointer_depth=base_var.pointer_depth - 1,
            is_pointer=base_var.pointer_depth > 1,
            is_virtual=True,
        )

        if mode == 'generate_lvalue':
            # Copy element address from other_reg to dest_reg
            with self._debug_block(f"Copy element address to {dest_reg}"):
                self.emit(f"ALUOP_{dest_reg}H %{other_reg}%+%{other_reg}H%", f"Copy address")
                self.emit(f"ALUOP_{dest_reg}L %{other_reg}%+%{other_reg}L%", f"Copy address")

            self.emit(f"POP_{other_reg}L", f"ArrayRef Restore {other_reg}")
            self.emit(f"POP_{other_reg}H", f"ArrayRef Restore {other_reg}")
            return element_var

        elif mode == 'generate_rvalue':
            # Load value at element address into dest_reg
            with self._debug_block(f"Load element value into {dest_reg}"):
                if element_var.sizeof() <= 2 and not element_var.is_array:
                    # Load small value
                    self._deref_load(element_var.sizeof(), addr_reg=other_reg, dest_reg=dest_reg)
                else:
                    # Return address for large elements or nested arrays
                    self.emit(f"ALUOP_{dest_reg}H %{other_reg}%+%{other_reg}H%", f"Copy address")
                    self.emit(f"ALUOP_{dest_reg}L %{other_reg}%+%{other_reg}L%", f"Copy address")

            self.emit(f"POP_{other_reg}L", f"ArrayRef Restore {other_reg}")
            self.emit(f"POP_{other_reg}H", f"ArrayRef Restore {other_reg}")
            return element_var

        else:
            raise NotImplementedError(f"visit_ArrayRef mode {mode} not yet supported")

    def visit_Constant(self, node, mode, dest_reg='A', dest_var=None, **kwargs):
        if mode == 'return_typespec':
            if dest_var:
                return dest_var.typespec
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
                return (self.context.literalreg.lookup_by_content(ast.literal_eval(node.value), 'string').label, node.value)
            else:
                raise NotImplementedError(f"Unrecognized constant type: {node.type}")
        elif mode == 'return_array_dim':
            if node.type == 'string':
                return [ len(ast.literal_eval(node.value)) + 1 ] # Rough estimate, actual size depends on escapes
            else:
                raise ValueError(f"I don't know what to do with a Constant {node.type} node for setting array dims")
        elif mode in ('generate_rvalue', 'generate_lvalue'):
            # Register string literals as we encounter them, and
            # for these, the rvalue/lvalue is the address (label) of the string.
            if node.type == 'string':
                # Remove quotes from the string value
                content = ast.literal_eval(node.value)
                # Calculate size (including null terminator)
                # The value includes quotes, so we need to process escape sequences
                size = len(content) + 1  # account for null terminator
                self.context.literalreg.register(content, 'string', size)
                # Now that it's registered, return the address
                # of the literal in the dest_reg
                literal = self.context.literalreg.lookup_by_content(content, 'string')
                self.emit(f"LDI_{dest_reg} {literal.label}", node.value)
                # return fake Variable representing the constant
                return Variable(typespec=TypeSpec('string', 'char'), name='init_string', is_array=True, array_dims=[size], is_virtual=True)
            # For numeric constants, we load the value
            # directly into the destination register.
            elif node.type in ('int', 'char',) and mode == 'generate_rvalue':
                parsed_value = ast.literal_eval(node.value)
                if node.type == 'char':
                    parsed_value = f"'{parsed_value}'"
                if not dest_var:
                    ret_var = Variable(typespec=TypeSpec(node.type, node.type), name='const', qualifiers=['const'], is_virtual=True)
                    if ret_var.typespec.sizeof() == 1:
                        self.emit(f"LDI_{dest_reg}L {parsed_value}", f"Constant assignment {node.value} as {node.type}")
                    elif ret_var.typespec.sizeof() == 2:
                        self.emit(f"LDI_{dest_reg} {parsed_value}", f"Constant assignment {node.value} as {node.type}")
                    else:
                        raise ValueError("Unable to load integer constants larger than 16 bit: {ret_var.friendly_name()} (no dest_var)")
                    return ret_var
                elif dest_var.is_pointer:
                    self.emit(f"LDI_{dest_reg} {parsed_value}", f"Constant assignment {node.value} for pointer {dest_var.friendly_name()}")
                    return Variable(typespec=TypeSpec('int', 'int'), name='const', qualifiers=['const'], is_virtual=True)
                elif dest_var.typespec.sizeof() == 1:
                    self.emit(f"LDI_{dest_reg}L {parsed_value}", f"Constant assignment {node.value} for {dest_var.friendly_name()}")
                    return Variable(typespec=dest_var.typespec, name='const', qualifiers=['const'], is_virtual=True)
                elif dest_var.typespec.sizeof() == 2:
                    self.emit(f"LDI_{dest_reg} {parsed_value}", f"Constant assignment {node.value} for {dest_var.friendly_name()}")
                    return Variable(typespec=dest_var.typespec, name='const', qualifiers=['const'], is_virtual=True)
                else:
                    raise NotImplementedError(f"Unable to load integer constants larger than 16 bit: {dest_var.friendly_name()}")
            else:
                raise NotImplementedError(f"Constant value for {node.type} types using mode {mode} not yet supported")
        else:
            raise NotImplementedError(f"visit_Constant mode {mode} not yet supported")

    def visit_InitList(self, node, mode, dest_reg='A', dest_var=None, **kwargs):
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
                            ts = self.visit(expr, mode='return_typespec', dest_var=struct_member, **kwargs)
                            val, c_val = self.visit(expr, mode='get_value', dest_var=struct_member, **kwargs)
                            comments.append(c_val)

                            if ts.sizeof() == 1:
                                parts.append(f"0x{val:02x}")
                                vals.append(val & 0xff)
                                byte_count += 1
                            elif ts.sizeof() == 2:
                                low = val & 0xff
                                high = (val & 0xff00) >> 8
                                parts.append(f"0x{high:02x}")
                                parts.append(f"0x{low:02x}")
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
                            ts = self.visit(expr, mode='return_typespec', dest_var=Variable(typespec=target_typespec, name='init_element', is_virtual=True), **kwargs)
                            val, c_val = self.visit(expr, mode='get_value', dest_var=Variable(typespec=target_typespec, name='init_element', is_virtual=True), **kwargs)
                            comments.append(c_val)

                            if ts.sizeof() == 1:
                                parts.append(f"0x{val:02x}")
                                vals.append(val & 0xff)
                                byte_count += 1
                            elif ts.sizeof() == 2:
                                low = val & 0xff
                                high = (val & 0xff00) >> 8
                                parts.append(f"0x{high:02x}")
                                parts.append(f"0x{low:02x}")
                                vals.append(val & 0xffff)
                                byte_count += 2
                            else:
                                raise ValueError(f"Unable to create data from value with size > 2: {ts}")

                return parts, vals, comments, byte_count

            # Flatten the entire init list
            literal_parts, literal_vals, literal_comment, byte_count = flatten_init_list(node, dest_var.typespec)

            # Create the literal
            if dest_var and dest_var.typespec.is_struct:
                comment_str = f"Struct {dest_var.typespec.name} initializer data: {{{', '.join(literal_comment)}}}"
            else:
                type_name = dest_var.typespec.name if dest_var else "byte"
                comment_str = f"{type_name} initializer data: {{{', '.join(literal_comment)}}}"

            self.context.literalreg.register(" ".join(literal_parts), 'bytes', len(literal_parts), comment=comment_str)

            # Get the literal we just registered and load its address
            literal = self.context.literalreg.lookup_by_content(" ".join(literal_parts), 'bytes')
            self.emit(f"LDI_{dest_reg} {literal.label}", literal_vals if literal_vals else literal_parts)

            # Return a fake variable representing the initialized data
            retvar = Variable(typespec=TypeSpec('byte', 'unsigned char'),
                             name='initlist', is_array=True, array_dims=[byte_count], is_virtual=True)
            return retvar
        else:
            raise NotImplementedError(f"visit_InitList mode {mode} not yet supported")

    def visit_ID(self, node, mode, dest_reg='A', **kwargs):
        """
        Visit an identifier (variable reference).

        generate_lvalue: Returns address of variable in dest_reg
        generate_rvalue: Returns value of variable in dest_reg (arrays/structs decay to pointer)
        """
        if mode == 'return_var':
            var = self.context.vartable.lookup(node.name)
            if not var:
                raise SyntaxError(f"Variable {node.name} used without declaration")
            return var

        elif mode == 'return_typespec':
            var = self.context.vartable.lookup(node.name)
            if not var:
                raise SyntaxError(f"Type/Var {node.name} used without declaration")
            return var.typespec

        elif mode == 'return_function':
            return self.context.funcreg.lookup(node.name)

        elif mode == 'generate_lvalue':
            # Get the address of the identifier
            var = self.context.vartable.lookup(node.name)
            if var:
                self._get_var_base_address(var, dest_reg)
                return var

            # See if it's a function reference
            func = self.context.funcreg.lookup(node.name)
            if func:
                self._get_var_base_address(func, dest_reg)
                # Return a fake Variable that behaves like a function reference (void pointer)
                return Variable(name=node.name,
                                typespec=TypeSpec('funcref', 'void'),
                                is_pointer=True,
                                pointer_depth=1,
                                is_virtual=True)

            raise ValueError(f"Unable to find {node.name} in variable or function table")

        elif mode == 'generate_rvalue':
            # Get the value of the identifier
            var = self.context.vartable.lookup(node.name)
            if not var:
                raise ValueError(f"Unable to find variable {node.name} in variable table")

            if var.is_pointer:
                other_reg = 'B' if dest_reg == 'A' else 'A'
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"Save {other_reg} while we load pointer")
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"Save {other_reg} while we load pointer")

                # Dereference the pointer: load the address value stored in the pointer
                self._get_var_base_address(var, other_reg)
                self.emit_verbose(f"Dereference to get base address for frame-based pointer {var.friendly_name()}")
                self._deref_load(2, addr_reg=other_reg, dest_reg=dest_reg)  # Load 2-byte pointer

                self.emit(f"POP_{other_reg}H", f"Restore {other_reg}, pointer value in {dest_reg}")
                self.emit(f"POP_{other_reg}L", f"Restore {other_reg}, pointer value in {dest_reg}")

                return var

            # Arrays and structs decay to pointer-like address
            elif var.is_array or var.typespec.is_struct:
                # Just return the address (array/struct decay)
                self._get_var_base_address(var, dest_reg)
                return var

            else:
                # Simple value: load it
                other_reg = 'B' if dest_reg == 'A' else 'A'
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"Save {other_reg} while we load value")
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"Save {other_reg} while we load value")

                self._get_var_base_address(var, other_reg)
                self._deref_load(var.sizeof(), addr_reg=other_reg, dest_reg=dest_reg)

                self.emit(f"POP_{other_reg}H", f"Restore {other_reg}, value in {dest_reg}")
                self.emit(f"POP_{other_reg}L", f"Restore {other_reg}, value in {dest_reg}")

                return var
        else:
            raise NotImplementedError(f"visit_ID mode {mode} not yet supported")

    def visit_UnaryOp(self, node, mode, dest_reg='A', dest_var=None, **kwargs):
        """
        Visit unary operators: +, -, ~, !, &, *, ++, p++, --, p--
        """
        if node.op in ('++', 'p++', '--', 'p--'):
            if mode in ('generate_rvalue', 'codegen'):
                other_reg = 'B' if dest_reg == 'A' else 'A'
                if node.op.endswith('-'):
                    word_op = 'decr'
                    ptr_op = f'{dest_reg}-{other_reg}'
                    byte_op = '-'
                    descr = 'decrement'
                else:
                    word_op = 'incr'
                    ptr_op = f'A+B'
                    byte_op = '+'
                    descr = 'increment'
                # Load current value
                with self._debug_block(f"UnaryOp {node.op}: load current value into {dest_reg}"):
                    var = self.visit(node.expr, mode='generate_rvalue', dest_reg=dest_reg, dest_var=dest_var)
                # Save current value if we'll be returning it (prefixed increment/decrement)
                if node.op.startswith('p') and mode == 'generate_rvalue': # codegen mode means we're discarding the value, so no need to preserve it
                    if var.typespec.sizeof() == 2:
                        self.emit(f"ALUOP_PUSH %{dest_reg}%+%{dest_reg}H%", f"UnaryOp {node.op}: preserve previous value before {descr}ing")
                    self.emit(f"ALUOP_PUSH %{dest_reg}%+%{dest_reg}L%", f"UnaryOp {node.op}: preserve previous value before {descr}ing")
                # Perform increment/decrement
                with self._debug_block(f"UnaryOp {node.op}: compute {descr}ed value into {dest_reg}"):
                    # Pointer arithmetic requires +/- by the size of the referenced type, and all
                    # operations are words because we're dealing in addresses
                    if var.is_pointer:
                        unit_size = var.pointer_arithmetic_size()
                        self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"UnaryOp {node.op}: preserve {other_reg} before pointer arithmetic")
                        self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"UnaryOp {node.op}: preserve {other_reg} before pointer arithmetic")
                        self.emit(f"LDI_{other_reg} {unit_size}", f"UnaryOp {node.op}: pointed-at type size for {var.friendly_name()}")
                        self.emit(f"ALUOP16O_{dest_reg} %{ptr_op}%+%AL%+%BL% %{ptr_op}%+%AH%+%BH%+%Cin% %{ptr_op}%+%AH%+%BH%", f"UnaryOp {node.op}: move pointer by pointed-at type size for {var.friendly_name()}")
                        self.emit(f"POP_{other_reg}L", f"UnaryOp {node.op}: Restore {other_reg} after pointer arithmetic")
                        self.emit(f"POP_{other_reg}H", f"UnaryOp {node.op}: Restore {other_reg} after pointer arithmetic")
                    # Standard value that might be one or two bytes
                    elif var.typespec.sizeof() == 1:
                        self.emit(f"ALUOP_{dest_reg}L %{dest_reg}{byte_op}1%+%{dest_reg}L%", f"UnaryOp {node.op}: {descr} 1-byte value")
                    else:
                        #           16-bit ALU op       low-op (stored to AL)                hi-op (if low-op overflowed)        hi-op (of low-op no overflow)
                        self.emit(f"ALUOP16O_{dest_reg} %{dest_reg}{byte_op}1%+%{dest_reg}L% %{dest_reg}{byte_op}1%+%{dest_reg}H% %{dest_reg}%+%{dest_reg}H%", f"UnaryOp {node.op}: {descr} 1-byte value")
                # Get destination address into other_reg
                with self._debug_block(f"UnaryOp {node.op}: Store value in {dest_reg} back to {var.friendly_name()}"):
                    self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"UnaryOp {node.op}: Save {other_reg} before generating lvalue")
                    self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"UnaryOp {node.op}: Save {other_reg} before generating lvalue")
                    with self._debug_block(f"UnaryOp {node.op}: Generate lvalue address"):
                        var = self.visit(node.expr, mode='generate_lvalue', dest_reg=other_reg, dest_var=dest_var)
                    # Store updated value
                    with self._debug_block(f"UnaryOp {node.op}: Store {descr}ed value to lvalue"):
                        self._emit_store(var, lvalue_reg=other_reg, rvalue_reg=dest_reg)
                    self.emit(f"POP_{other_reg}L", f"UnaryOp {node.op}: Restore {other_reg}, return rvalue in {dest_reg}")
                    self.emit(f"POP_{other_reg}H", f"UnaryOp {node.op}: Restore {other_reg}, return rvalue in {dest_reg}")
                # If prefixed operation, restore original value
                if node.op.startswith('p') and mode == 'generate_rvalue':
                    self.emit(f"POP_{dest_reg}L", f"UnaryOp {node.op}: restore original value for return")
                    if var.typespec.sizeof() == 2:
                        self.emit(f"POP_{dest_reg}H", f"UnaryOp {node.op}: restore original value for return")
                # Return the var
                return var
            else:
                raise NotImplementedError(f"visit_UnaryOp mode {mode} op {node.op} not yet supported")

        elif node.op == 'sizeof':
            if mode == 'generate_rvalue':
                sizeof_var = Variable(typespec=TypeSpec('uint', 'unsigned int'), name='sizeof', is_virtual=True)
                try:
                    var = self.visit(node.expr, mode='return_var')
                except NotImplementedError:
                    pass
                if var:
                    if var.is_type_wrapper:
                        self.emit(f"LDI_{dest_reg} {var.sizeof()}", f"sizeof type {var.friendly_name()}")
                    else:
                        self.emit(f"LDI_{dest_reg} {var.sizeof()}", f"sizeof var {var.friendly_name()}")
                    return sizeof_var
                try:
                    ts = self.visit(node.expr, mode='return_typespec')
                except NotImplementedError:
                    pass
                if ts:
                    self.emit(f"LDI_{dest_reg} {ts.sizeof()}", f"sizeof type {ts.name} ({ts.base_type})")
                    return sizeof_var
                raise ValueError(f"Unable to get var or typespec from {node.expr}")
            else:
                raise NotImplementedError(f"visit_UnaryOp mode {mode} op {node.op} not yet supported")

        elif node.op in ('+', '-', '~', '!'):
            if mode == 'generate_rvalue':
                # try optimized path where we directly load constant negative values. If the
                # AST under node.expr doesn't support 'get_value', continue with the traditional path.
                value = None
                try:
                    value = self.visit(node.expr, mode='get_value', **kwargs)
                except NotImplementedError:
                    pass
                if value and node.op == '-':
                    if dest_var.sizeof() == 1:
                        self.emit(f"LDI_{dest_reg}L -{value[0]}", f"Load constant value, inverted {value[1]}")
                    elif dest_var.sizeof() == 2:
                        self.emit(f"LDI_{dest_reg} -{value[0]}", f"Load constant value, inverted {value[1]}")
                    else:
                        raise ValueError("Cannot invert non-simple types")
                    var = dest_var
                # traditional option, or operations other than '-'
                else:
                    with self._debug_block(f"UnaryOp {node.op}: load value into {dest_reg}"):
                        var = self.visit(node.expr, mode='generate_rvalue', dest_reg=dest_reg, dest_var=dest_var)

                    if node.op == '-':
                        with self._debug_block(f"UnaryOp {node.op}: negate value"):
                            if var.typespec.sizeof() == 1:
                                self.emit(f"ALUOP_{dest_reg}L %-{dest_reg}_signed%+%{dest_reg}L%", "Unary negation")
                            else:
                                self.emit(f"CALL :signed_invert_{dest_reg.lower()}", "Unary negation")
                    elif node.op == '~':
                        with self._debug_block(f"UnaryOp {node.op}: bitwise-not value"):
                            self.emit(f"ALUOP_{dest_reg}L %~{dest_reg}%+%{dest_reg}L%", "Unary bitwise NOT")
                            if var.typespec.sizeof() == 2:
                                self.emit(f"ALUOP_{dest_reg}H %~{dest_reg}%+%{dest_reg}H%", "Unary bitwise NOT")
                    elif node.op == '!':
                        with self._debug_block(f"UnaryOp {node.op}: boolean NOT"):
                            label_wastrue = self._get_label("unarynot_wastrue")
                            label_done = self._get_label("unarynot_done")

                            self.emit(f"ALUOP_FLAGS %{dest_reg}%+%{dest_reg}L%", "Unary boolean NOT")
                            self.emit(f"JNZ {label_wastrue}", "Unary boolean NOT, jump if true")
                            if var.typespec.sizeof() == 2:
                                self.emit(f"ALUOP_FLAGS %{dest_reg}%+%{dest_reg}H%", "Unary boolean NOT")
                                self.emit(f"JNZ {label_wastrue}", "Unary boolean NOT, jump if true")
                            if var.typespec.sizeof() == 2:
                                self.emit(f"LDI_{dest_reg} 1", "Unary boolan NOT, is false: return true")
                            else:
                                self.emit(f"LDI_{dest_reg}L 1", "Unary boolan NOT, is false: return true")
                            self.emit(f"JMP {label_done}", "Unary boolean NOT: done")

                            self.emit(f"{label_wastrue}")
                            if var.typespec.sizeof() == 2:
                                self.emit(f"LDI_{dest_reg} 0", "Unary boolan NOT, is true: return false")
                            else:
                                self.emit(f"LDI_{dest_reg}L 0", "Unary boolan NOT, is true: return false")
                            self.emit(f"{label_done}")
                    elif node.op == '+':
                        self.emit_verbose(f"UnaryOp {node.op} does not change value, {dest_reg} contains return value")
                    else:
                        raise NotImplementedError(f"visit_UnaryOp mode {mode} op {node.op} not yet supported")
                return var
            else:
                raise NotImplementedError(f"visit_UnaryOp mode {mode} op {node.op} not yet supported")

        elif node.op == '&':
            # Address-of operator: always returns address
            if mode in ('generate_rvalue', 'generate_lvalue'):
                with self._debug_block(f"UnaryOp {node.op}: get address into {dest_reg}"):
                    var = self.visit(node.expr, mode='generate_lvalue', dest_reg=dest_reg, dest_var=dest_var)

                    # Return pointer to the variable
                    result_var = Variable(
                        typespec=var.typespec,
                        name=f"ptr_to_{var.name}",
                        is_pointer=True,
                        pointer_depth=var.pointer_depth + 1,
                        is_virtual=True,
                    )
                    return result_var
            else:
                raise NotImplementedError(f"visit_UnaryOp mode {mode} op {node.op} not yet supported")

        elif node.op == '*':
            # Dereference operator
            if mode == 'generate_lvalue':
                # Get pointer value (which is an address)
                with self._debug_block(f"UnaryOp {node.op} lvalue: load pointer into {dest_reg}"):
                    var = self.visit(node.expr, mode='generate_rvalue', dest_reg=dest_reg, dest_var=dest_var)

                # Return dereferenced variable
                result_var = Variable(
                    typespec=var.typespec,
                    name=f"{var.name}_deref",
                    is_pointer=var.pointer_depth > 1,
                    pointer_depth=max(0, var.pointer_depth - 1),
                    is_virtual=True,
                )
                return result_var

            elif mode == 'generate_rvalue':
                # Get pointer value into other_reg, then load from that address
                other_reg = 'B' if dest_reg == 'A' else 'A'

                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"UnaryOp {node.op}: Save {other_reg} before generating expr value")
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"UnaryOp {node.op}: Save {other_reg} before generating expr value")
                with self._debug_block(f"UnaryOp {node.op} rvalue: load pointer into {other_reg}"):
                    var = self.visit(node.expr, mode='generate_rvalue', dest_reg=other_reg, dest_var=dest_var)

                result_var = Variable(
                    typespec=var.typespec,
                    name=f"{var.name}_deref",
                    is_pointer=var.pointer_depth > 1,
                    pointer_depth=max(0, var.pointer_depth - 1),
                    is_virtual=True,
                )
                # special case for generic void* pointers, treat as referencing a char
                if var.is_pointer and not result_var.is_pointer and result_var.typespec.base_type == 'void':
                    result_var.typespec = TypeSpec('void_ptr_ref', 'char')

                with self._debug_block(f"UnaryOp {node.op} rvalue: load value at pointer into {dest_reg}"):
                    if result_var.sizeof() <= 2:
                        self._deref_load(result_var.sizeof(), addr_reg=other_reg, dest_reg=dest_reg)
                    else:
                        # For large values, return the address
                        self.emit(f"ALUOP_{dest_reg}H %{other_reg}%+%{other_reg}H%", f"Copy address")
                        self.emit(f"ALUOP_{dest_reg}L %{other_reg}%+%{other_reg}L%", f"Copy address")

                self.emit(f"POP_{other_reg}L", f"UnaryOp {node.op}: Restore {other_reg}, dereferenced rvalue in {dest_reg}")
                self.emit(f"POP_{other_reg}H", f"UnaryOp {node.op}: Restore {other_reg}, dereferenced rvalue in {dest_reg}")

                return result_var

            else:
                raise NotImplementedError(f"visit_UnaryOp mode {mode} op {node.op} not yet supported")

        else:
            raise NotImplementedError(f"visit_UnaryOp op {node.op} not yet supported")


    def visit_BinaryOp(self, node, mode, dest_reg='A', dest_var=None, **kwargs):
        if mode == 'generate_rvalue':
            # node.left = dest_reg
            # node.right = other_reg
            other_reg = 'B' if dest_reg == 'A' else 'A'
            self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"BinaryOp {node.op}: Save {other_reg} for generating rhs")
            self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"BinaryOp {node.op}: Save {other_reg} for generating rhs")
            return_var = None

            # right/left_var_val will be defined if that operand is a constant literal
            with self._debug_block(f"BinaryOp {node.op}: Generate rhs into {other_reg}"):
                right_var_val = None
                try:
                    right_var_val = self.visit(node.right, mode='get_value', **kwargs)
                except NotImplementedError:
                    pass
                right_var = self.visit(node.right, mode='generate_rvalue', dest_reg=other_reg, dest_var=dest_var)

            with self._debug_block(f"BinaryOp {node.op}: Generate lhs into {dest_reg}"):
                left_var_val = None
                try:
                    left_var_val = self.visit(node.left, mode='get_value', **kwargs)
                except NotImplementedError:
                    pass
                left_var = self.visit(node.left, mode='generate_rvalue', dest_reg=dest_reg, dest_var=dest_var)

            # If given a var and a constant, return the var, not the constant
            if right_var_val and not left_var_val:
                return_var = left_var
            elif left_var_val and not right_var_val:
                return_var = right_var
            elif left_var:
                return_var = left_var
            elif right_var:
                return_var = right_var
            else:
                raise ValueError("Cannot determine which BinaryOp side to return var from")

            # If we have a constant value on either side, and the other side is
            # a byte, then treat both as bytes.
            right_var_size = right_var.sizeof()
            left_var_size = left_var.sizeof()
            if right_var_val and left_var_size == 1:
                right_var_size = 1
            if left_var_val and right_var_size == 1:
                left_var_size = 1

            # Compute the resulting op size and whether it will be signed
            signed_op = left_var.typespec.is_signed() or right_var.typespec.is_signed()
            if left_var.is_pointer or right_var.is_pointer:
                op_size = 2
                signed_op = False
            elif left_var_size == right_var_size == 1:
                op_size = 1
            elif left_var_size == right_var_size == 2:
                op_size = 2
            elif left_var_size != right_var_size:
                if left_var_size == 1 and right_var_size == 2:
                    self.emit_sign_extend(dest_reg, left_var.typespec)
                    op_size = 2
                elif left_var_size == 2 and right_var_size == 1:
                    self.emit_sign_extend(other_reg, left_var.typespec)
                    op_size = 2
                else:
                    raise ValueError(f"BinaryOp with incompatible sized types, left={left_var.friendly_name()}, right={right_var.friendly_name()}")
            else:
                raise ValueError(f"BinaryOp {node.op}: unsure what to do with these types > 2 bytes, left={left_var.friendly_name()}, right={right_var.friendly_name()}")

            alu_map = {
                '+': {'byte':f'ALUOP_{dest_reg}L %A+B%+%AL%+%BL%', 'word':f'ALUOP16O_{dest_reg} %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH%'},
                '-': {'byte':f'ALUOP_{dest_reg}L %{dest_reg}-{other_reg}%+%AL%+%BL%', 'word':f'ALUOP16O_{dest_reg} %{dest_reg}-{other_reg}%+%AL%+%BL% %{dest_reg}-{other_reg}%+%AH%+%BH%+%Cin% %{dest_reg}+{other_reg}%+%AH%+%BH%'},
                '&': {'byte':f'ALUOP_{dest_reg}L %A&B%+%AL%+%BL%', 'word':f'ALUOP16_{dest_reg} %A&B%+%AL%+%BL% %A&B%+%AH%+%BH%'},
                '&&': {'byte':f'ALUOP_{dest_reg}L %A&B%+%AL%+%BL%', 'word':f'ALUOP16_{dest_reg} %A&B%+%AL%+%BL% %A&B%+%AH%+%BH%'},
                '|': {'byte':f'ALUOP_{dest_reg}L %A|B%+%AL%+%BL%', 'word':f'ALUOP16_{dest_reg} %A|B%+%AL%+%BL% %A|B%+%AH%+%BH%'},
                '||': {'byte':f'ALUOP_{dest_reg}L %A|B%+%AL%+%BL%', 'word':f'ALUOP16_{dest_reg} %A|B%+%AL%+%BL% %A|B%+%AH%+%BH%'},
                '^': {'byte':f'ALUOP_{dest_reg}L %AxB%+%AL%+%BL%', 'word':f'ALUOP16_{dest_reg} %AxB%+%AL%+%BL% %AxB%+%AH%+%BH%'},
            }

            if node.op in ('+', '-') and (left_var.is_pointer or right_var.is_pointer):
                # Pointer arithmetic requires +/- by the size of the referenced type, and all
                # operations are words because we're dealing in addresses
                if left_var.is_pointer:
                    unit_size = left_var.pointer_arithmetic_size()
                    scale_reg = other_reg
                    ptr_reg = dest_reg
                else:
                    unit_size = right_var.pointer_arithmetic_size()
                    scale_reg = dest_reg
                    ptr_reg = other_reg
                if unit_size == 1:
                    self.emit_verbose(f"No operand scaling required for pointers to 1-byte types")
                elif unit_size in (2, 4, 8, 16, 32, 64, 128):
                    shifts = {2: 1, 4: 2, 8: 3, 16: 4, 32: 5, 64: 6, 128: 7}[unit_size]
                    for _ in range(shifts):
                        self.emit(f"ALUOP16O_{scale_reg} %{scale_reg}<<1%+%{scale_reg}L% %{scale_reg}<<1%+%{scale_reg}H%+%Cin% %{scale_reg}<<1%+%{scale_reg}H%", f"Multiply operand in {scale_reg} by pointer unit size {unit_size}")
                elif unit_size <= 8:
                    self.emit(f"ALUOP_PUSH %{ptr_reg}%+%{ptr_reg}H%", f"BinaryOp {node.op}: Save pointer in {ptr_reg} before scaling operand")
                    self.emit(f"ALUOP_PUSH %{ptr_reg}%+%{ptr_reg}L%", f"BinaryOp {node.op}: Save pointer in {ptr_reg} before scaling operand")
                    self.emit(f"ALUOP_{ptr_reg}H %{scale_reg}%+%{scale_reg}H%", f"BinaryOp {node.op}: Copy operand before scaling by unit size {unit_size}")
                    self.emit(f"ALUOP_{ptr_reg}L %{scale_reg}%+%{scale_reg}L%", f"BinaryOp {node.op}: Copy operand before scaling by unit size {unit_size}")
                    for _ in range(unit_size-1):
                        self.emit(f"ALUOP16O_{scale_reg} %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH+%BH%", f"Scale operand in {scale_reg} by unit size {unit_size}")
                    self.emit(f"POP_{ptr_reg}L", f"BinaryOp {node.op}: Restore {ptr_reg} after scaling computation")
                    self.emit(f"POP_{ptr_reg}H", f"BinaryOp {node.op}: Restore {ptr_reg} after scaling computation")
                else:
                    # Fallback to multiplication
                    self.emit(f"CALL :heap_push_{scale_reg}", f"Multiply operand in {scale_reg} by unit size {unit_size}")
                    self.emit(f"LDI_{scale_reg} {unit_size}", f"Multiply operand in {scale_reg} by unit size {unit_size}")
                    self.emit(f"CALL :heap_push_{scale_reg}", f"Multiply operand in {scale_reg} by unit size {unit_size}")
                    self.emit(f"CALL :mul16", f"Multiply operand in {scale_reg} by unit size {unit_size}")
                    self.emit(f"CALL :heap_pop_{scale_reg}", f"Multiply operand in {scale_reg} by unit size {unit_size}")
                    self.emit(f"CALL :heap_pop_word", f"Multiply operand in {scale_reg} by unit size {unit_size}")

            if node.op in alu_map:
                if op_size == 1:
                    self.emit(alu_map[node.op]['byte'], f"BinaryOp {node.op} {op_size} byte")
                elif op_size == 2:
                    self.emit(alu_map[node.op]['word'], f"BinaryOp {node.op} {op_size} byte")
            elif node.op in ('==', '!='):
                ne = ('false', 0)
                eq = ('true', 1)
                if node.op == '!=':
                    ne = ('true', 1)
                    eq = ('false', 0)

                label = self._get_label(f'binarybool_is{ne[0]}')
                label_done = self._get_label('binarybool_done')

                self.emit(f"ALUOP_FLAGS %A&B%+%AL%+%BL%", f"BinaryOp {node.op} {op_size} byte check equality")
                self.emit(f"JNE {label}", f"BinaryOp {node.op} is {ne[0]}")
                if op_size == 2:
                    self.emit(f"ALUOP_FLAGS %A&B%+%AH%+%BH%", f"BinaryOp {node.op} {op_size} byte check equality")
                    self.emit(f"JNE {label}", f"BinaryOp {node.op} is {ne[0]}")
                if op_size == 1:
                    self.emit(f"LDI_{dest_reg}L {eq[1]}", f"BinaryOp {node.op} was {eq[0]}")
                else:
                    self.emit(f"LDI_{dest_reg} {eq[1]}", f"BinaryOp {node.op} was {eq[0]}")
                self.emit(f"JMP {label_done}")
                self.emit(f"{label}")
                if op_size == 1:
                    self.emit(f"LDI_{dest_reg}L {ne[1]}", f"BinaryOp {node.op} was {ne[0]}")
                else:
                    self.emit(f"LDI_{dest_reg} {ne[1]}", f"BinaryOp {node.op} was {ne[0]}")
                self.emit(f"{label_done}")
            elif node.op in ('<<', '>>'):
                if right_var_val:
                    if (op_size == 1 and right_var_val[0] > 8) or (op_size == 2 and right_var_val[0] > 16):
                        raise SyntaxError(f"Constant shifting {node.op} {right_var_val[0]} positions is pointless")
                    for _ in range(right_var_val[0]):
                        if op_size == 1:
                            self.emit(f"ALUOP_{dest_reg}L %{dest_reg}{node.op}1%+%{dest_reg}L%", f"BinaryOp {node.op} {right_var_val[0]} positions")
                        else:
                            if node.op == '<<':
                                self.emit(f"ALUOP16O_{dest_reg} %{dest_reg}<<1%+%{dest_reg}L% %{dest_reg}<<1%+%{dest_reg}H%+%Cin% %{dest_reg}<<1%+%{dest_reg}H%", f"BinaryOp {node.op} {right_var_val[0]} positions")
                            else:
                                self.emit(f"CALL :shift16_{dest_reg.lower()}_right", f"BinaryOp {node.op} {right_var_val[0]} positions")
                else:
                    raise NotImplementedError(f"BinaryOp mode {mode} op {node.op} not implemented for non-constant shifts")
            elif node.op in ('<', '<=', '>', '>='):
                default_val = 1 if node.op.startswith('<') else 0
                other_val = 0 if node.op.startswith('<') else 1
                label_equal = self._get_label("binaryop_equal")
                label_done = self._get_label("binaryop_done")
                label_diffsigns = self._get_label("binaryop_diffsigns")
                label_overflow = self._get_label("binaryop_overflow")


                if signed_op:
                    # if operand signs are the same, we check for overflow.
                    # Otherwise, we can use the left side sign bit to determine
                    # the outcome
                    if op_size == 1:
                        self.emit(f"ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL%", f"Signed BinaryOp {node.op}: Check if signs differ")
                    else:
                        self.emit(f"ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH%", f"Signed BinaryOp {node.op}: Check if signs differ")
                    self.emit(f"JNZ {label_diffsigns}", f"Signed BinaryOp {node.op}: XOR of MSB == 0 if signs are the same, or nonzero if signs differ")

                    # Signs are the same, so we need to check for overflow
                    if op_size == 1:
                        self.emit(f"ALUOP_FLAGS %{other_reg}-{dest_reg}_signed%+%{other_reg}L%+%{dest_reg}L%", f"Signed BinaryOp {node.op}: Subtract to check E and O flags")
                    else:
                        self.emit(f"ALUOP16O_FLAGS %ALU16_s{other_reg}-{dest_reg}%", f"Signed BinaryOp {node.op}: Subtract to check O flag")
                    self.emit(f"JO {label_overflow}", f"Signed BinaryOp {node.op}: If overflow, result will be {'true' if other_val else 'false'}")

                    # Signs are the same and there was no overflow, check if the operands are equal
                    if op_size == 2:
                        self.emit(f"ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL%", f"Signed BinaryOp {node.op}: check 16-bit equality")
                    self.emit(f"JEQ {label_equal}", f"Signed BinaryOp {node.op}: If equal, we know if true/false now")

                    # Operands were unequal, same sign, and no overflow on subtraction, so we need
                    # to check if the result sign differs from the operands' signs.
                    if op_size == 1:
                        self.emit(f"ALUOP_{dest_reg}L %{other_reg}-{dest_reg}_signed%+%{other_reg}L%+%{dest_reg}L%", f"Signed BinaryOp {node.op}: Subtract to check for sign change")
                        self.emit(f"ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL%", f"Signed BinaryOp {node.op}: Compare signs")
                        self.emit(f"LDI_{dest_reg}L {default_val}", f"Signed BinaryOp {node.op}: Assume no sign change -> {'true' if default_val else 'false'}")
                    else:
                        self.emit(f"ALUOP16O_{dest_reg} %ALU16_s{other_reg}-{dest_reg}%", f"Signed BinaryOp {node.op}: Subtract to check for sign change")
                        self.emit(f"ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH%", f"Signed BinaryOp {node.op}: Compare signs")
                        self.emit(f"LDI_{dest_reg} {default_val}", f"Signed BinaryOp {node.op}: Assume no sign change -> {'true' if default_val else 'false'}")
                    self.emit(f"JZ {label_done}", f"Signed BinaryOp {node.op}: Assume signs were the same")
                    if op_size == 1:
                        self.emit(f"LDI_{dest_reg}L {other_val}", f"Signed BinaryOp {node.op}: Signs were different -> {'true' if other_val else 'false'}")
                    else:
                        self.emit(f"LDI_{dest_reg} {other_val}", f"Signed BinaryOp {node.op}: Signs were different -> {'true' if other_val else 'false'}")
                    self.emit(f"JMP {label_done}", f"Signed BinaryOp {node.op}: Signs were different")

                    # If operands were equal, < and > return false, and <= and >= return true
                    self.emit(f"{label_equal}")
                    if op_size == 1:
                        if node.op.endswith('='):
                            self.emit(f"LDI_{dest_reg}L 1", f"Signed BinaryOp {node.op}: true because equal")
                        else:
                            self.emit(f"LDI_{dest_reg}L 0", f"Signed BinaryOp {node.op}: false because equal")
                    else:
                        if node.op.endswith('='):
                            self.emit(f"LDI_{dest_reg} 1", f"Signed BinaryOp {node.op}: true because equal")
                        else:
                            self.emit(f"LDI_{dest_reg} 0", f"Signed BinaryOp {node.op}: false because equal")
                    self.emit(f"JMP {label_done}")

                    # If signs were the same and subtraction triggered a signed overflow, then 
                    self.emit(f"{label_overflow}")
                    if op_size == 1:
                        self.emit(f"LDI_{dest_reg}L {other_val}", f"Signed BinaryOp {node.op}: {'true' if other_val else 'false'} because signed overflow")
                    else:
                        self.emit(f"LDI_{dest_reg} {other_val}", f"Signed BinaryOp {node.op}: {'true' if other_val else 'false'} because signed overflow")
                    self.emit(f"JMP {label_done}")

                    # If signs differ, use the left side sign to determine result
                    self.emit(f"{label_diffsigns}")
                    if op_size == 1:
                        self.emit(f"ALUOP_FLAGS %{dest_reg}msb%+%{dest_reg}L%", f"Signed BinaryOp {node.op}: Check sign of left operand")
                    else:
                        self.emit(f"ALUOP_FLAGS %{dest_reg}msb%+%{dest_reg}H%", f"Signed BinaryOp {node.op}: Check sign of left operand")
                    if op_size == 1:
                        self.emit(f"LDI_{dest_reg}L {default_val}", f"Signed BinaryOp {node.op}: assume {'true' if default_val else 'false'}")
                    else:
                        self.emit(f"LDI_{dest_reg} {default_val}", f"Signed BinaryOp {node.op}: assume {'true' if default_val else 'false'}")
                    self.emit(f"JNZ {label_done}", f"Signed BinaryOpn {node.op}: if left side sign bit is set, return {'true' if default_val else 'false'}")
                    if op_size == 1:
                        self.emit(f"LDI_{dest_reg}L {other_val}", f"Signed BinaryOp {node.op}: flip to {'true' if other_val else 'false'}")
                    else:
                        self.emit(f"LDI_{dest_reg} {other_val}", f"Signed BinaryOp {node.op}: flip to {'true' if other_val else 'false'}")
                    self.emit(f"{label_done}")

                else:
                    # unsigned subtraction, check for overflow and equality
                    if op_size == 1:
                        self.emit(f"ALUOP_FLAGS %{other_reg}-{dest_reg}%+%{other_reg}L%+%{dest_reg}L%", f"Unsigned BinaryOp {node.op}: Subtract to check E and O flags")
                        # If operands are equal, < and > return false, but <= and >= return true
                        self.emit(f"JEQ {label_equal}", f"BinaryOp {node.op}: check if equal")
                        # O flag is still valid here
                    else:
                        self.emit(f"ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL%", f"Unsigned BinaryOp {node.op}: Check for equality")
                        # If operands are equal, < and > return false, but <= and >= return true
                        self.emit(f"JEQ {label_equal}", f"BinaryOp {node.op}: check if equal")
                        # O flag is not valid after ALUOP16E operation, so we do it again to get O flag
                        self.emit(f"ALUOP16O_FLAGS %ALU16_{other_reg}-{dest_reg}%", f"Unsigned BinaryOp {node.op}: Subtract to check O flag")

                    # Operands were not equal, so true/false depends on overflow flag
                    if op_size == 1:
                        self.emit(f"LDI_{dest_reg}L {default_val}", f"BinaryOp {node.op}: assume {'true' if {default_val} else 'false'}")
                    else:
                        self.emit(f"LDI_{dest_reg} {default_val}", f"BinaryOp {node.op}: assume {'true' if {default_val} else 'false'}")
                    self.emit(f"JNO {label_done}", f"BinaryOp {node.op} unsigned: no overflow, so baseline assumption is correct")
                    if op_size == 1:
                        self.emit(f"LDI_{dest_reg}L {other_val}", f"BinaryOp {node.op}: overflow, so {'true' if other_val else 'false'}")
                    else:
                        self.emit(f"LDI_{dest_reg} {other_val}", f"BinaryOp {node.op}: overflow, so {'true' if other_val else 'false'}")
                    self.emit(f"JMP {label_done}")

                    # If operands are equal, < and > return false, but <= and >= return true
                    self.emit(f"{label_equal}")
                    if op_size == 1:
                        if node.op.endswith('='):
                            self.emit(f"LDI_{dest_reg}L 1", f"BinaryOp {node.op}: operands equal: true")
                        else:
                            self.emit(f"LDI_{dest_reg}L 0", f"BinaryOp {node.op}: operands equal: false")
                    else:
                        if node.op.endswith('='):
                            self.emit(f"LDI_{dest_reg} 1", f"BinaryOp {node.op}: operands equal: true")
                        else:
                            self.emit(f"LDI_{dest_reg} 0", f"BinaryOp {node.op}: operands equal: false")
                    self.emit(f"{label_done}")
            else:
                raise NotImplementedError(f"BinaryOp mode {mode} op {node.op} not implemented")

            # Some Boolean ops require an extra step to convert the result into a Boolean 1 instead of any non-zero value,
            # since all that happened above is a bitwise AND or OR operation.
            if node.op in ('&&', '||'):
                label_wastrue = self._get_label("binarybool_wastrue")
                label_done = self._get_label("binarybool_done")

                self.emit(f"ALUOP_FLAGS %{dest_reg}%+%{dest_reg}L%", "Binary boolean format check")
                self.emit(f"JNZ {label_wastrue}", "Binary boolean format check, jump if true")
                if op_size == 2:
                    self.emit(f"ALUOP_FLAGS %{dest_reg}%+%{dest_reg}H%", "Binary boolean format check")
                    self.emit(f"JNZ {label_wastrue}", "Binary boolean format check, jump if true")
                self.emit(f"JMP {label_done}", "Binary boolean format check: done")

                self.emit(f"{label_wastrue}")
                if op_size == 2:
                    self.emit(f"LDI_{dest_reg} 1", "Binary boolean format check, is true")
                else:
                    self.emit(f"LDI_{dest_reg}L 1", "Binary boolean format check, is true")
                self.emit(f"{label_done}")
                
            self.emit(f"POP_{other_reg}L", f"BinaryOp {node.op}: Restore {other_reg} after use for rhs")
            self.emit(f"POP_{other_reg}H", f"BinaryOp {node.op}: Restore {other_reg} after use for rhs")

            return return_var
        else:
            raise NotImplementedError(f"visit_BinaryOp op {node.op} mode {mode} not yet supported")

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

    def visit_Cast(self, node, mode, dest_reg='A', dest_var=None, **kwargs):
        if mode == 'generate_rvalue':
            var = self.visit(node.expr, mode=mode, dest_reg=dest_reg, dest_var=dest_var, **kwargs)
            new_var = self.visit(node.to_type, mode='return_var', dest_reg=dest_reg, dest_var=dest_var, **kwargs)
            if not new_var:
                raise ValueError(f"Could not return var for {node.to_type}")
            new_var.name = var.name
            new_var.storage_class = var.storage_class
            new_var.offset = var.offset
            new_var.kind = var.kind
            self.emit(f"# Cast {var.friendly_name()} to {new_var.friendly_name()}")
            return new_var

    def visit_Assignment(self, node, mode, dest_reg='A', dest_var=None, **kwargs):
        if mode == 'codegen' or mode == 'generate_rvalue':
            other_reg = 'B' if dest_reg == 'A' else 'A'
            return_var = None
            if node.op == '=':
                # Get destination address into B
                with self._debug_block(f"Assign: Generate lvalue address"):
                    var = self.visit(node.lvalue, mode='generate_lvalue', dest_reg=other_reg)

                # Generate rvalue into A
                with self._debug_block(f"Assign: Generate rvalue"):
                    if var.typespec.is_struct and not var.is_pointer:
                        # For structs, we need the source address
                        return_var = self.visit(node.rvalue, mode='generate_lvalue', dest_reg=dest_reg, dest_var=var)
                    else:
                        return_var = self.visit(node.rvalue, mode='generate_rvalue', dest_reg=dest_reg, dest_var=var)
                # Store value
                with self._debug_block(f"Assign: Store rvalue to lvalue"):
                    self._emit_store(var, lvalue_reg=other_reg, rvalue_reg=dest_reg)
            elif node.op.endswith('='): # +=, -=, etc.
                # Generate rvalue through a synthetic BinaryOp

                # Get destination address into B
                with self._debug_block(f"Compound Assign {node.op}: Generate lvalue address"):
                    var = self.visit(node.lvalue, mode='generate_lvalue', dest_reg=other_reg)

                # Generate value into A
                with self._debug_block(f"Compound Assign {node.op}: Generate rvalue"):
                    binaryop = node.op[0]
                    if binaryop in ('<', '>',):
                        binaryop += binaryop
                    return_var = self.visit(c_ast.BinaryOp(left=node.lvalue, right=node.rvalue, op=binaryop), mode='generate_rvalue', dest_reg=dest_reg, dest_var=var)

                # Store value
                with self._debug_block(f"Compound Assign {node.op}: Store rvalue to lvalue"):
                    self._emit_store(var, lvalue_reg=other_reg, rvalue_reg=dest_reg)

            else:
                raise NotImplementedError(f"visit_Assignment op {node.op} not yet supported")

            if mode == 'generate_rvalue':
                return return_var
            return
        else:
            raise NotImplementedError(f"visit_Assignment mode {mode} not yet supported")

    def _get_var_base_address(self, var, dest_reg='A'):
        """Get base address of a variable or function into dest_reg."""
        if type(var) is Function:
            self.emit(f"LDI_{dest_reg} {var.asm_name()}", f"Load base address of function {var.name} into {dest_reg}")
            return

        # otherwise, we're dealing with a variable
        if var.kind == 'global' or (var.kind == 'local' and var.storage_class == 'static'):
            if var.kind == 'global' and var.storage_class == 'extern':
                prefix = '$'
            else:
                prefix = self._get_static_prefix()
            self.emit(f"LDI_{dest_reg} {prefix}{var.padded_name()}", f"Load base address of {var.name} into {dest_reg}")
        else:
            other_reg = 'A' if dest_reg == 'B' else 'B'
            # The naiive approach loading the offset into a register and calling :add16_to_reg
            #  ALUOP_PUSH -> 4 clocks
            #  POP -> 2 clocks
            #  LDI -> 4 clocks
            #  CALL :add16_to_reg -> 8 (CALL) + 4+4+4 + 2 (RET) -> 22 clocks
            # Total 43 clocks for the naiive method - expensive!

            # We can load values much faster using INCR_D/DECR_D for small offsets.
            #
            # For offset mode:
            #  INCR/DECR (~1 clocks for each abs(offset))
            #  MOV_DH/MOV_DL (4 clocks total)
            #  DECR/INCR (~1 clocks for each abs(offset))
            # We can go up to +/- 20 and still finish with fewer clocks than the naiive approach
            if abs(var.offset) <= 20:
                eight, rest = divmod(abs(var.offset), 8)
                four, one = divmod(rest, 4)
                for _ in range(eight):
                    self.emit(f"{'INCR' if var.offset > 0 else 'DECR'}8_D", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                for _ in range(four):
                    self.emit(f"{'INCR' if var.offset > 0 else 'DECR'}4_D", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                for _ in range(one):
                    self.emit(f"{'INCR' if var.offset > 0 else 'DECR'}_D", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                self.emit(f"MOV_DH_{dest_reg}H", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                self.emit(f"MOV_DL_{dest_reg}L", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                for _ in range(eight):
                    self.emit(f"{'DECR' if var.offset > 0 else 'INCR'}8_D", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                for _ in range(four):
                    self.emit(f"{'DECR' if var.offset > 0 else 'INCR'}4_D", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                for _ in range(one):
                    self.emit(f"{'DECR' if var.offset > 0 else 'INCR'}_D", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
            else:
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}L%", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                self.emit(f"ALUOP_PUSH %{other_reg}%+%{other_reg}H%", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                self.emit(f"MOV_DH_{dest_reg}H", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                self.emit(f"MOV_DL_{dest_reg}L", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                self.emit(f"LDI_{other_reg} {var.offset}", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                self.emit(f"ALUOP16O_{dest_reg} %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH%", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                self.emit(f"POP_{other_reg}H", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")
                self.emit(f"POP_{other_reg}L", f"Load base address of {var.name} at offset {var.offset} into {dest_reg}")

    def _add_array_offset(self, var_or_size, index_reg='B', addr_reg='A'):
        """Add array[index] offset to address in addr_reg. Destroys index_reg."""
        if index_reg not in ('A', 'B',):
            raise ValueError("index_reg must be A or B")
        if addr_reg not in ('A', 'B',):
            raise ValueError("addr_reg must be A or B")
        if type(var_or_size) is Variable:
            element_size = var_or_size.sizeof_element()
        else:
            element_size = var_or_size

        if element_size == 1:
            self.emit(f"ALUOP16O_{addr_reg} %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH%", f"Add array offset in {index_reg} to address reg {addr_reg}, element size {element_size}")
        elif element_size in (2, 4, 8, 16, 32, 64, 128):
            shifts = {2: 1, 4: 2, 8: 3, 16: 4, 32: 5, 64: 6, 128: 7}[element_size]
            for _ in range(shifts):
                self.emit(f"ALUOP16O_{index_reg} %{index_reg}<<1%+%{index_reg}L% %{index_reg}<<1%+%{index_reg}H%+%Cin% %{index_reg}<<1%+%{index_reg}H%", f"Multiply array offset in {index_reg} by element size {element_size}")
            self.emit(f"CALL :add16_to_{addr_reg.lower()}", f"Add array offset in {index_reg} to address reg {addr_reg}, element size {element_size}")
        elif element_size <= 8:
            for _ in range(element_size):
                self.emit(f"CALL :add16_to_{addr_reg.lower()}", f"Add array offset in {index_reg} to address reg {addr_reg}, element size {element_size}")
        else:
            # Fallback to multiplication
            self.emit(f"CALL :heap_push_{index_reg}", f"Multiply array offset in {index_reg} by element size {element_size} to address reg {addr_reg}")
            self.emit(f"LDI_{index_reg} {element_size}", f"Multiply array offset in {index_reg} by element size {element_size} to address reg {addr_reg}")
            self.emit(f"CALL :heap_push_{index_reg}", f"Multiply array offset in {index_reg} by element size {element_size} to address reg {addr_reg}")
            self.emit(f"CALL :mul16", f"Multiply array offset in {index_reg} by element size {element_size} to address reg {addr_reg}")
            self.emit(f"CALL :heap_pop_{index_reg}", f"Multiply array offset in {index_reg} by element size {element_size} to address reg {addr_reg}")
            self.emit(f"CALL :heap_pop_word", f"Multiply array offset in {index_reg} by element size {element_size} to address reg {addr_reg}")
            self.emit(f"ALUOP16O_{addr_reg} %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH%", f"Add array offset in {index_reg} to address reg {addr_reg}, element size {element_size}")

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
            self.emit(f"ALUOP16O_{addr_reg} %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH%", f"Add struct member {member_var.name} offset to address in {addr_reg}")
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
                #           16-bit ALU op       low-op (stored to AL)        hi-op (if low-op overflowed) hi-op (if low-op no overflow)
                self.emit(f"ALUOP16O_{addr_reg} %{addr_reg}+1%+%{addr_reg}L% %{addr_reg}+1%+%{addr_reg}H% %{addr_reg}%+%{addr_reg}H%", f"Dereferenced load")
            else:
                self.emit(f"INCR_{addr_reg}", f"Dereferenced load")
            self.emit(f"LDA_{addr_reg}_{dest_reg}L", f"Dereferenced load")
            if addr_reg in ('A', 'B',):
                #           16-bit ALU op       low-op (stored to AL)        hi-op (if low-op overflowed) hi-op (if low-op no overflow)
                self.emit(f"ALUOP16O_{addr_reg} %{addr_reg}-1%+%{addr_reg}L% %{addr_reg}-1%+%{addr_reg}H% %{addr_reg}%+%{addr_reg}H%", f"Dereferenced load")
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
        if var.typespec.is_struct and not var.is_pointer:
            self._emit_bulk_store(var, lvalue_reg, rvalue_reg)
        else:
            if var.is_pointer or var.typespec.sizeof() == 2:
                self.emit(f"ALUOP_ADDR_{lvalue_reg} %{rvalue_reg}%+%{rvalue_reg}H%", f"Store to {var.friendly_name()}")
                #           16-bit ALU op         low-op (stored to AL)            hi-op (if low-op overflowed)     hi-op (if low-op no overflow)
                self.emit(f"ALUOP16O_{lvalue_reg} %{lvalue_reg}+1%+%{lvalue_reg}L% %{lvalue_reg}+1%+%{lvalue_reg}H% %{lvalue_reg}%+%{lvalue_reg}H%", f"Store to {var.friendly_name()}")
                self.emit(f"ALUOP_ADDR_{lvalue_reg} %{rvalue_reg}%+%{rvalue_reg}L%", f"Store to {var.friendly_name()}")
                #           16-bit ALU op         low-op (stored to AL)            hi-op (if low-op overflowed)     hi-op (if low-op no overflow)
                self.emit(f"ALUOP16O_{lvalue_reg} %{lvalue_reg}-1%+%{lvalue_reg}L% %{lvalue_reg}-1%+%{lvalue_reg}H% %{lvalue_reg}%+%{lvalue_reg}H%", f"Store to {var.friendly_name()}")
            elif var.typespec.sizeof() == 1:
                self.emit(f"ALUOP_ADDR_{lvalue_reg} %{rvalue_reg}%+%{rvalue_reg}L%", f"Store to {var.friendly_name()}")
            else:
                raise NotImplementedError(f"_emit_store can't store simple values larger than 16 bit")

