from pycparser import c_ast
from variables import *
from debug_mixin import DebugMixin
import sys

class CodeGenerator(DebugMixin, c_ast.NodeVisitor):
    """
    NodeVisitor that completes the compilation and emits assembly code
    """
    def __init__(self, context, output=sys.stdout):
        self.context = context
        set_type_context(self.context.typedef_reg, self.context.struct_reg)
        self.output = output
    
    def emit(self, asm, comment=None):
        if comment:
            print(f"{asm:<32} # {comment}", file=self.output)
        else:
            print(asm, file=self.output)

    def visit_FileAST(self, node):
        print("**** Code generation start ****", file=sys.stderr)
        # global var initialization
        self.emit("# Global var initialization")
        for g in node.ext:
            if isinstance(g, c_ast.Decl) and g.init:
                self.generate_globalvar_init(g)

        # jump to main function
        if self.context.jmp_to_main:
            main_func = self.context.function_table.func_lookup("main")
            if main_func:
                self.emit("# Jump to main function")
                self.emit(f"JMP {main_func.asm_name}")
            else:
                raise ValueError("jmp-to-main is set but no main function found")

        # function definitions
        self.emit("# Function definitions")

        # global and static var definitions and storage
        self.emit("# Global and static vars")
        for var in self.context.variable_table.get_all_globals():
            var.emit_static_declaration(self.emit)
        self.emit("# Constants")
        for var in self.context.variable_table.get_all_globals():
            var.emit_const(self.emit)

        print("**** Code generation end ****", file=sys.stderr)
    
    def visit_Typedef(self, node):
        # Typedefs were already handled in symbol collection phase, nothing to do here.
        pass

    def visit_Decl(self, node):
        if self.context.debug:
            print(self.get_debug(node), file=sys.stderr)
        self.emit(f"Welcome to {node.__class__.__name__} {node.name}")

    def visit_FuncDef(self, node):
        if self.context.debug:
            print(self.get_debug(node), file=sys.stderr)
        self.emit(f"Welcome to {node.__class__.__name__} {node.decl.name}")

    def generic_visit(self, node):
        if self.context.debug:
            print(self.get_debug(node), file=sys.stderr)
        raise NotImplementedError(f"CodeGen: No visit_{node.__class__.__name__} function found to handle this node")

    def generate(self, node, var=None):
        """
        Generic construction entrypoint for code generation nodes
        """
        if self.context.debug:
            print(self.get_debug(node), file=sys.stderr)
        if isinstance(node, c_ast.FuncCall):
            self.generate_funccall(node)
        else:
            raise NotImplementedError(f"CodeGen: generate() does not support {node.__class__.__name__} nodes yet")

    def generate_globalvar_init(self, node):
        """
        Generates assembly code that initializes a global variable
        """
        var = self.context.variable_table.lookup(node.name)
        if not var:
            print(f"WARNING: global variable {node.name} not found in variable table")
            return

        if var.is_const:
            # We don't need to generate any assembly for constants. They will
            # either be written inline into the assembly or will be referenced
            # at their data location.
            pass

        if isinstance(node.init, c_ast.Constant):
            if node.init.type == 'int':
                if var.size == 1:
                    self.emit(f"ST {var.asm_name} {node.init.value}", "Global var initialization")
                elif var.size == 2:
                    self.emit(f"ST16 {var.asm_name} {node.init.value}", "Global var initialization")
                else:
                    raise NotImplementedError("Global var assignment for ints > 2 bytes not implemented")
            elif node.init.type == 'string':
                self.emit(f"LDI_C {var.const_asm_name}", "Global var initialization")
                self.emit(f"LDI_D {var.asm_name}", "Global var initialization")
                self.emit(f"CALL :strcpy", "Global var initialization")
            else:
                raise NotImplementedError(f"Global var initialization for Constant of type {node.init.type} unsupported")
        else:
            self.generate(node.init, var)
            if var.size == 1:
                self.emit(f"ALUOP_ADDR %A%+%AL% {var.asm_name}")
            elif var.size == 2:
                self.emit(f"ALUOP_ADDR %A%+%AH% {var.asm_name}")
                self.emit(f"ALUOP_ADDR %A%+%AL% {var.asm_name}+1")

    def generate_funccall(self, node):
        """
        Execute the function and put the result into A or AL
        """
        func = self.context.function_table.func_lookup(node.name.name)
        if not func:
            raise ValueError(f"Unable to find function for {node.name.name}")
        
        # Push arguments in reverse order
        arg_types_iter = iter(reversed(func.parameter_types))
        arg_nodes_iter = iter(reversed([ *node.args ]))
        while True:
            try:
                arg_node = next(arg_nodes_iter)
                arg_type = next(arg_types_iter)
            except StopIteration:
                break
            if isinstance(arg_node, c_ast.Constant):
                if arg_node.type == 'int':
                    if arg_type.size == 1:
                        self.emit(f"LDI_AL {arg_node.value}")
                        self.emit(f"CALL :heap_push_AL")
                    elif arg_type.size == 2:
                        self.emit(f"LDI_A {arg_node.value}")
                        self.emit(f"CALL :heap_push_A")
                    else:
                        raise NotImplementedError("Constant parameter assignment for ints > 2 bytes not implemented")
                else:
                    raise NotImplementedError(f"Constant parameter initialization for Constant of type {arg.type} unsupported")
            else:
                raise NotImplementedError(f"Parameter initialization for {arg.__class__.__name__} not supported")

        # Call the function
        self.emit(f"CALL {func.asm_name}")

        # Pop the result into A/AL
        if func.return_type.size == 1:
            self.emit("CALL :heap_pop_AL")
        elif func.return_type.size == 2:
            self.emit("CALL :heap_pop_A")
