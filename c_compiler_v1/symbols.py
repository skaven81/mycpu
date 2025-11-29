from pycparser import c_ast
from variables import *
from functions import Function
from debug_mixin import DebugMixin
from extract_type import ExtractTypeMixin
import sys

class SymbolCollector(DebugMixin, ExtractTypeMixin, c_ast.NodeVisitor):
    """
    NodeVisitor that collects all the symbols (variables, typedefs, functions) and registers them
    """
    def __init__(self, context):
        self.context = context
        set_type_context(self.context.typedef_reg, self.context.struct_reg)

    def visit_FileAST(self, node):
        print("**** Symbols processing start ****", file=sys.stderr)
        super().generic_visit(node)
        print("**** Symbols processing end ****", file=sys.stderr)

    def visit_Typedef(self, node):
        if self.context.debug:
            print(self.get_debug(node), file=sys.stderr)

        # Special handling for structs
        if isinstance(node.type, c_ast.TypeDecl) and isinstance(node.type.type, c_ast.Struct):
            struct_node = node.type.type
            
            # For typedef'd structs, use the typedef name as the struct name
            if struct_node.decls:  # Has a body (definition)
                struct_def = StructDefinition(
                    node.name,  # Use typedef name as struct name
                    [(i.name, self._extract_type(i.type)) for i in struct_node.decls]
                )
                self.context.struct_reg.add_struct(struct_def)
            
            # Register the typedef as pointing to this struct
            typespec = TypeSpec(['struct', node.name])
            self.context.typedef_reg.add_typedef(node.name, typespec)
        else:
            # Normal typedef
            typespec = self._extract_type(node.type)
            self.context.typedef_reg.add_typedef(node.name, typespec)
        
        if self.context.debug:
            print(f"Registered typedef {node.name}: {typespec.__dict__}", file=sys.stderr)

    def visit_Decl(self, node):
        if self.context.debug:
            print(self.get_debug(node), file=sys.stderr)
        typespec = None
        if isinstance(node.type, c_ast.ArrayDecl) and node.init and node.init.type == "string":
            # initializer string value will have quotes -- adds two extra bytes. But we will
            # end up appending a null to the string when we generate the assembly so we only
            # subtract one byte from the length, to account for the null terminator.
            typespec = self._extract_type(node.type, array_dims=[len(node.init.value) - 1])
        else:
            typespec = self._extract_type(node.type)
        var = Variable(node.name, typespec, 'global',
                        static_type=self.context.static_type,
                        storage_class=node.funcspec[0] if node.funcspec else None,
                        initializer=node.init if isinstance(node.init, c_ast.Constant) else None)
        self.context.variable_table.add_global(var)
        if self.context.debug:
            print(f"Registered global variable {node.name}: {var.__dict__}", file=sys.stderr)

    def visit_FuncDef(self, node):
        if self.context.debug:
            print(self.get_debug(node), file=sys.stderr)

        func = Function(node.decl.name, node)
        self.context.function_table.add_function(func)
        if self.context.debug:
            print(f"Registered function {node.decl.name}: {func}", file=sys.stderr)

    def generic_visit(self, node):
        raise NotImplementedError(f"Symbol collection for {node.__class__.__name__} is not implemented")

