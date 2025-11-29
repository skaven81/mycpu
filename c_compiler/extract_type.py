from pycparser import c_ast
from variables import TypeSpec

class ExtractTypeMixin:
    def _extract_type(self, type_node, array_dims=None, pointer_level=0):
        """
        Recursively extract type information from any type node.
        Returns a TypeSpec or similar unified representation.
        """
        if isinstance(type_node, c_ast.TypeDecl):
            return self._extract_type(type_node.type, array_dims=array_dims, pointer_level=pointer_level)
        
        elif isinstance(type_node, c_ast.IdentifierType):
            return TypeSpec(type_node.names, array_dims=array_dims, pointer_level=pointer_level)
        
        elif isinstance(type_node, c_ast.Struct):
            # For struct references (not definitions), just return the type
            # Don't register here - let visit_Typedef or visit_Decl handle registration
            if type_node.name:
                return TypeSpec(['struct', type_node.name], array_dims=array_dims, pointer_level=pointer_level)
            else:
                raise ValueError("Anonymous struct encountered outside of typedef")
        
        elif isinstance(type_node, c_ast.ArrayDecl):
            # Handle arrays
            arr_dim = None
            if not type_node.dim:
                return self._extract_type(type_node.type, array_dims=array_dims, pointer_level=pointer_level)
            elif array_dims:
                return self._extract_type(type_node.type, array_dims=[*array_dims, int(type_node.dim.value)], pointer_level=pointer_level)
            else:
                return self._extract_type(type_node.type, array_dims=[int(type_node.dim.value)], pointer_level=pointer_level)
        
        elif isinstance(type_node, c_ast.PtrDecl):
            # Handle pointers
            return self._extract_type(type_node.type, array_dims=array_dims, pointer_level=pointer_level+1)
        
        elif isinstance(type_node, c_ast.FuncDecl):
            # Handle function types
            return self._extract_type(type_node.type, array_dims=array_dims, pointer_level=pointer_level)
        
        else:
            raise NotImplementedError(f"Type extraction for {type_node.__class__.__name__}")

