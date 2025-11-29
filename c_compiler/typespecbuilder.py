from typecollection import TypeSpec
from pycparser import c_ast

class TypeSpecBuilder:
    """
    Mixin class that provides _build_typespec functionality.
    Used by both TypeCollector and FunctionCollector to avoid code duplication.
    """
    
    def _build_typespec(self, name: str, type_node, qualifiers=None) -> TypeSpec:
        """Recursively build a TypeSpec from a type node."""
        if qualifiers is None:
            qualifiers = []
        
        # Get the type registry from the implementing class
        type_registry = getattr(self, 'type_registry', None)
        spec = TypeSpec(name=name, qualifiers=qualifiers, _registry=type_registry)
        
        # Handle different type node types
        if isinstance(type_node, c_ast.TypeDecl):
            # Add qualifiers from TypeDecl
            if type_node.quals:
                spec.qualifiers.extend(type_node.quals)
            return self._build_typespec(name, type_node.type, spec.qualifiers)
        
        elif isinstance(type_node, c_ast.IdentifierType):
            # Simple type like 'int', 'char', etc.
            spec.base_type = ' '.join(type_node.names)
            return spec
        
        elif isinstance(type_node, c_ast.PtrDecl):
            # Pointer type
            spec.is_pointer = True
            if type_node.quals:
                spec.qualifiers.extend(type_node.quals)
            
            # Recursively process pointed-to type
            inner_spec = self._build_typespec('', type_node.type, spec.qualifiers)
            
            # Count pointer depth
            spec.pointer_depth = 1
            if inner_spec.is_pointer:
                spec.pointer_depth += inner_spec.pointer_depth
                spec.base_type = inner_spec.base_type
                spec.is_struct = inner_spec.is_struct
                spec.struct_name = inner_spec.struct_name
                spec.struct_members = inner_spec.struct_members
            else:
                spec.base_type = inner_spec.base_type
                spec.is_struct = inner_spec.is_struct
                spec.struct_name = inner_spec.struct_name
                spec.struct_members = inner_spec.struct_members
                spec.is_array = inner_spec.is_array
                spec.array_dims = inner_spec.array_dims
            
            return spec
        
        elif isinstance(type_node, c_ast.ArrayDecl):
            # Array type
            spec.is_array = True
            
            # Get array dimension
            if type_node.dim:
                if isinstance(type_node.dim, c_ast.Constant):
                    spec.array_dims.append(int(type_node.dim.value))
                else:
                    spec.array_dims.append(None)  # Variable or unknown size
            else:
                spec.array_dims.append(None)
            
            # Recursively process element type
            inner_spec = self._build_typespec('', type_node.type, qualifiers)
            
            # Merge inner array dimensions
            if inner_spec.is_array:
                spec.array_dims.extend(inner_spec.array_dims)
                spec.base_type = inner_spec.base_type
                spec.is_pointer = inner_spec.is_pointer
                spec.pointer_depth = inner_spec.pointer_depth
                spec.is_struct = inner_spec.is_struct
                spec.struct_name = inner_spec.struct_name
                spec.struct_members = inner_spec.struct_members
            else:
                spec.base_type = inner_spec.base_type
                spec.is_pointer = inner_spec.is_pointer
                spec.pointer_depth = inner_spec.pointer_depth
                spec.is_struct = inner_spec.is_struct
                spec.struct_name = inner_spec.struct_name
                spec.struct_members = inner_spec.struct_members
            
            return spec
        
        elif isinstance(type_node, c_ast.Struct):
            # Struct type
            spec.is_struct = True
            spec.struct_name = type_node.name
            
            # Process struct members if present
            if type_node.decls:
                for member_decl in type_node.decls:
                    if isinstance(member_decl, c_ast.Decl):
                        member_spec = self._build_typespec(
                            member_decl.name,
                            member_decl.type,
                            member_decl.quals if hasattr(member_decl, 'quals') else []
                        )
                        spec.struct_members.append(member_spec)
            
            return spec
        
        return spec


