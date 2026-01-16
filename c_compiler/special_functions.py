
class SpecialFunctions():
    # Special function call functions are responsible for setting up the
    # parameters, calling the function, and ensuring the return value
    # ends up in dest_reg.
    #
    # def custom_FuncCall_<funcname>(self, node, mode, func, dest_reg='A', **kwargs):
    #
    # node - the FuncCall node in the AST
    # mode - either 'codegen' or 'generate_rvalue', generally can be ignored
    # func - the Function object describing the function to call
    # dest_reg - the register the return value should be loaded into

    def custom_FuncCall_printf(self, node, mode, func, dest_reg='A', **kwargs):
        arg_nodes = self.visit(node.args, mode='return_nodes')
        for idx, an in reversed([*enumerate(arg_nodes)]):
            with self._debug_block(f"Push param idx {idx}"):
                if idx > 0:
                    rvalue_var = self.visit(an, mode='generate_rvalue', dest_reg='A')
                    if rvalue_var.sizeof() == 1:
                        self.emit(f"CALL :heap_push_AL", f"Push parameter {rvalue_var.friendly_name()}")
                    elif rvalue_var.sizeof() == 2:
                        self.emit(f"CALL :heap_push_A", f"Push parameter {rvalue_var.friendly_name()}")
                    elif rvalue_var.is_array or rvalue_var.typespec.is_struct:
                        self.emit(f"CALL :heap_push_A", f"Push parameter {rvalue_var.friendly_name()} (pointer)")
                    else:
                        raise ValueError("Unable to push parameters larger than 2 bytes")
                else:
                    self.emit(f"PUSH_CH", "Save C before printf")
                    self.emit(f"PUSH_CL", "Save C before printf")
                    rvalue_var = self.visit(an, mode='generate_rvalue', dest_reg='C')
        self.emit(f"CALL {func.asm_name()}")
        # no return value for printf, nothing to pop
        self.emit(f"POP_CL", "Restore C after printf")
        self.emit(f"POP_CH", "Restore C after printf")

    def custom_FuncCall_print(self, node, mode, func, dest_reg='A', **kwargs):
        arg_nodes = self.visit(node.args, mode='return_nodes')
        self.emit(f"PUSH_CH", "Save C before printf")
        self.emit(f"PUSH_CL", "Save C before printf")
        rvalue_var = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='C')
        self.emit(f"CALL {func.asm_name()}")
        # no return value for print, nothing to pop
        self.emit(f"POP_CL", "Restore C after print")
        self.emit(f"POP_CH", "Restore C after print")
