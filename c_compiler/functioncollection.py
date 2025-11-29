from pycparser import c_ast
from typing import Optional, Dict
from typespec import TypeSpec
from typecollection import TypeRegistry
from function import Function
from typespecbuilder import TypeSpecBuilder

class FunctionRegistry:
    """Registry for storing and looking up Function objects by name."""
    
    def __init__(self):
        self._functions: Dict[str, Function] = {}
    
    def register(self, name: str, function: Function) -> None:
        """Register a Function with the given name."""
        self._functions[name] = function
    
    def lookup(self, name: str) -> Optional[Function]:
        """Look up a Function by name."""
        return self._functions.get(name)
    
    def __contains__(self, name: str) -> bool:
        """Check if a function name is registered."""
        return name in self._functions
    
    def __getitem__(self, name: str) -> Function:
        """Get a Function by name (raises KeyError if not found)."""
        return self._functions[name]
    
    def keys(self):
        """Return all registered function names."""
        return self._functions.keys()
    
    def values(self):
        """Return all registered Function objects."""
        return self._functions.values()
    
    def items(self):
        """Return all (name, Function) pairs."""
        return self._functions.items()


class FunctionCollector(c_ast.NodeVisitor, TypeSpecBuilder):
    """
    Visitor that collects function definitions and builds Function objects.
    After instantiation, call visit(ast) to perform collection.
    Inherits _build_typespec from TypeSpecBuilder mixin.
    """
    
    def __init__(self, function_registry: FunctionRegistry, type_registry: TypeRegistry):
        self.function_registry = function_registry
        self.type_registry = type_registry
    
    def visit_FuncDef(self, node: c_ast.FuncDef) -> None:
        """Visit a function definition node and create a Function."""
        # The function declaration is in node.decl
        if not isinstance(node.decl, c_ast.Decl):
            return
        
        func_name = node.decl.name
        func_decl = node.decl.type
        
        if not isinstance(func_decl, c_ast.FuncDecl):
            return
        
        # Build the Function object
        function = Function(name=func_name, _type_registry=self.type_registry)
        
        # Get return type
        function.return_type = self._build_typespec('', func_decl.type)
        
        # Get parameters
        if func_decl.args:
            for param in func_decl.args.params:
                if isinstance(param, c_ast.Decl):
                    param_name = param.name if param.name else ''
                    param_type = self._build_typespec(param_name, param.type)
                    if param_name:  # Only add named parameters
                        function.parameters[param_name] = param_type
                elif isinstance(param, c_ast.EllipsisParam):
                    # Handle variadic functions (...)
                    function.parameters['...'] = TypeSpec(name='...', base_type='...')
        
        self.function_registry.register(func_name, function)


