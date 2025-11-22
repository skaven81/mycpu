# Variable Management System for C Compiler

This module provides a complete type system and variable management infrastructure for building a C compiler using `pycparser`. It handles typedef resolution, struct definitions, arrays, pointers, and all C type modifiers.

## Table of Contents

- [Quick Start](#quick-start)
- [Architecture Overview](#architecture-overview)
- [Working with pycparser AST](#working-with-pycparser-ast)
- [Type System](#type-system)
- [Struct Support](#struct-support)
- [Complete Examples](#complete-examples)
- [Code Generation](#code-generation)

## Quick Start

```python
from variables import *

# 1. Set up global context (do this once at compiler startup)
typedef_reg = TypedefRegistry()
struct_reg = StructRegistry()
set_type_context(typedef_reg, struct_reg)

# 2. Create variable table
var_table = VariableTable()

# 3. Parse and process your C code
# ... use the classes to represent types and variables
```

## Architecture Overview

### Core Classes

1. **`TypedefRegistry`** - Manages type aliases (both built-in and user-defined)
2. **`StructRegistry`** - Manages struct definitions
3. **`TypeSpec`** - Represents any C type (scalars, pointers, arrays, structs)
4. **`StructDefinition`** - Represents a struct type with member layout
5. **`Variable`** - Represents a variable with its type and storage location
6. **`VariableTable`** - Manages variable scopes and lookups

### Design Philosophy

- **Global Context**: Set registries once with `set_type_context()`, never pass them again
- **Unified API**: One way to create types - `TypeSpec()` handles everything
- **Automatic Resolution**: Typedefs resolve automatically during type creation
- **Immutable Types**: `TypeSpec` objects are immutable after creation

## Working with pycparser AST

### Understanding pycparser Type Nodes

pycparser represents C types as a tree of nodes:

```
Decl (declaration)
 └── TypeDecl (type declaration)
      └── IdentifierType (base type like 'int', 'char')
```

For complex types, there are wrapper nodes:

```
Decl: int *ptr;
 └── PtrDecl (pointer)
      └── TypeDecl
           └── IdentifierType: ['int']

Decl: char arr[10];
 └── ArrayDecl (array)
      ├── dim: Constant(10)
      └── TypeDecl
           └── IdentifierType: ['char']

Decl: int *arr[5];  // Array of 5 pointers to int
 └── ArrayDecl
      ├── dim: Constant(5)
      └── PtrDecl
           └── TypeDecl
                └── IdentifierType: ['int']
```

### Mapping C Code to AST

#### Example 1: Simple Variable Declaration

**C Code:**
```c
uint8_t x;
```

**pycparser AST:**
```
FileAST
 └── Decl: x
      └── TypeDecl
           └── IdentifierType: ['uint8_t']
```

**Processing:**
```python
def visit_Decl(self, node):
    var_name = node.name
    type_names = node.type.type.names  # ['uint8_t']
    
    # Create TypeSpec (automatically resolves typedef)
    type_spec = TypeSpec(type_names)
    
    # Create Variable
    var = Variable(var_name, type_spec, 'global')
    var_table.add_global(var)
```

#### Example 2: Pointer Declaration

**C Code:**
```c
char *str;
```

**pycparser AST:**
```
Decl: str
 └── PtrDecl
      └── TypeDecl
           └── IdentifierType: ['char']
```

**Processing:**
```python
def extract_type_info(type_node):
    """Walk the type tree to extract complete type information"""
    pointer_level = 0
    array_dims = []
    
    # Unwrap pointer and array layers
    current = type_node
    while True:
        if isinstance(current, c_ast.PtrDecl):
            pointer_level += 1
            current = current.type
        elif isinstance(current, c_ast.ArrayDecl):
            if current.dim:
                dim = int(current.dim.value)
            else:
                dim = 0  # Unsized array
            array_dims.append(dim)
            current = current.type
        elif isinstance(current, c_ast.TypeDecl):
            current = current.type
            break
        else:
            break
    
    # Extract base type
    if isinstance(current, c_ast.IdentifierType):
        type_names = current.names
    elif isinstance(current, c_ast.Struct):
        type_names = ['struct', current.name]
    else:
        raise ValueError(f"Unknown type: {type(current)}")
    
    return type_names, pointer_level, array_dims

# Usage
def visit_Decl(self, node):
    var_name = node.name
    type_names, pointer_level, array_dims = extract_type_info(node.type)
    
    type_spec = TypeSpec(type_names, 
                        pointer_level=pointer_level,
                        array_dims=array_dims)
    
    var = Variable(var_name, type_spec, 'global')
    var_table.add_global(var)
```

#### Example 3: Array Declaration

**C Code:**
```c
int arr[10];
```

**pycparser AST:**
```
Decl: arr
 └── ArrayDecl
      ├── dim: Constant('10')
      └── TypeDecl
           └── IdentifierType: ['int']
```

**Processing:**
```python
type_names, pointer_level, array_dims = extract_type_info(node.type)
# Returns: (['int'], 0, [10])

type_spec = TypeSpec('int', array_dims=[10])
# type_spec.size == 20 (10 elements × 2 bytes each)
```

#### Example 4: Multi-dimensional Array

**C Code:**
```c
char grid[8][16];
```

**pycparser AST:**
```
Decl: grid
 └── ArrayDecl
      ├── dim: Constant('8')
      └── ArrayDecl
           ├── dim: Constant('16')
           └── TypeDecl
                └── IdentifierType: ['char']
```

**Processing:**
```python
type_names, pointer_level, array_dims = extract_type_info(node.type)
# Returns: (['char'], 0, [8, 16])

type_spec = TypeSpec('char', array_dims=[8, 16])
# type_spec.size == 128 (8 × 16 = 128 bytes)
```

## Type System

### Creating TypeSpec Objects

```python
# Simple types (with automatic typedef resolution)
t1 = TypeSpec('uint8_t')           # Resolves to unsigned char
t2 = TypeSpec('int')                # 2 bytes on this architecture
t3 = TypeSpec(['unsigned', 'int'])  # Explicit signedness

# Pointers
ptr = TypeSpec('char', pointer_level=1)              # char *
pptr = TypeSpec('int', pointer_level=2)              # int **

# Arrays
arr = TypeSpec('uint8_t', array_dims=[10])           # uint8_t[10]
matrix = TypeSpec('int', array_dims=[4, 8])          # int[4][8]

# Array of pointers
arr_ptr = TypeSpec('char', pointer_level=1, array_dims=[5])  # char *arr[5]

# Qualifiers
const_int = TypeSpec('int', qualifiers={'const'})
vol_ptr = TypeSpec('uint8_t', qualifiers={'volatile'}, pointer_level=1)
```

### TypeSpec Properties

```python
type_spec = TypeSpec('uint8_t', pointer_level=1)

print(type_spec.base_type)      # 'unsigned char'
print(type_spec.size)           # 2 (pointer is always 2 bytes)
print(type_spec.signed)         # False
print(type_spec.is_pointer)     # True
print(type_spec.is_array)       # False
print(type_spec.is_struct)      # False

# Get element type (for pointers/arrays)
element = type_spec.element_type  # TypeSpec for uint8_t
```

### Built-in Typedefs

The following typedefs are pre-defined:

- `uint8_t` → `unsigned char` (1 byte)
- `int8_t` → `signed char` (1 byte)
- `uint16_t` → `unsigned short` (2 bytes)
- `int16_t` → `signed short` (2 bytes)
- `size_t` → `unsigned short` (2 bytes)
- `byte` → `signed char` (1 byte)
- `word` → `signed short` (2 bytes)

### Adding Custom Typedefs

**C Code:**
```c
typedef unsigned int size_type;
typedef char *string;
```

**pycparser AST:**
```
Typedef: size_type
 └── TypeDecl
      └── IdentifierType: ['unsigned', 'int']

Typedef: string
 └── PtrDecl
      └── TypeDecl
           └── IdentifierType: ['char']
```

**Processing:**
```python
def visit_Typedef(self, node):
    typedef_name = node.name
    type_names, pointer_level, array_dims = extract_type_info(node.type)
    
    # Create the TypeSpec for the underlying type
    type_spec = TypeSpec(type_names, 
                        pointer_level=pointer_level,
                        array_dims=array_dims)
    
    # Register it
    typedef_reg = get_typedef_registry()
    typedef_reg.add_typedef(typedef_name, type_spec)

# Now these typedefs work automatically:
t1 = TypeSpec('size_type')  # Resolves to unsigned int
t2 = TypeSpec('string')     # Resolves to char *
```

## Struct Support

### Defining Structs

**C Code:**
```c
struct Point {
    int x;
    int y;
};
```

**pycparser AST:**
```
Struct: Point
 ├── Decl: x
 │    └── TypeDecl
 │         └── IdentifierType: ['int']
 └── Decl: y
      └── TypeDecl
           └── IdentifierType: ['int']
```

**Processing:**
```python
def visit_Struct(self, node):
    struct_name = node.name
    members = []
    
    for decl in node.decls:
        member_name = decl.name
        type_names, pointer_level, array_dims = extract_type_info(decl.type)
        
        # Create TypeSpec for member
        member_type = TypeSpec(type_names,
                              pointer_level=pointer_level,
                              array_dims=array_dims)
        
        members.append((member_name, member_type))
    
    # Create struct definition
    struct_def = StructDefinition(struct_name, members)
    
    # Register it
    struct_reg = get_struct_registry()
    struct_reg.add_struct(struct_def)
    
    print(f"Struct {struct_name}: size={struct_def.size} bytes")
    for name, _ in members:
        offset = struct_def.get_member_offset(name)
        print(f"  {name} at offset {offset}")
```

### Complex Struct Example

**C Code:**
```c
struct Buffer {
    uint8_t flags;
    char *data;
    uint16_t length;
    char name[16];
};
```

**Processing:**
```python
# This struct would have the following layout:
# flags:  offset 0, size 1  (uint8_t)
# data:   offset 1, size 2  (char *)
# length: offset 3, size 2  (uint16_t)
# name:   offset 5, size 16 (char[16])
# Total:  21 bytes

buffer_struct = StructDefinition('Buffer', [
    ('flags', 'uint8_t'),
    ('data', TypeSpec('char', pointer_level=1)),
    ('length', 'uint16_t'),
    ('name', TypeSpec('char', array_dims=[16]))
])

struct_reg.add_struct(buffer_struct)
```

### Using Struct Types

```python
# Create a variable of struct type
buf_var = Variable('my_buffer',
                  TypeSpec(['struct', 'Buffer']),
                  'global')

print(buf_var.size)  # 21 bytes

# Access struct members in code generation
def emit_struct_member_access(struct_var, member_name, emitter):
    """Generate code to access a struct member"""
    # Load address of member into A register
    struct_var.emit_member_access(member_name, emitter)
    
    # Now A points to the member
    # Load or store as needed...
```

## Complete Examples

### Example 1: Processing Function Parameters

**C Code:**
```c
void process_data(uint8_t *buffer, size_t length) {
    // function body
}
```

**pycparser AST:**
```
FuncDef: process_data
 ├── Decl: return type
 │    └── TypeDecl
 │         └── IdentifierType: ['void']
 └── ParamList
      ├── Decl: buffer
      │    └── PtrDecl
      │         └── TypeDecl
      │              └── IdentifierType: ['uint8_t']
      └── Decl: length
           └── TypeDecl
                └── IdentifierType: ['size_t']
```

**Processing:**
```python
def visit_FuncDef(self, node):
    func_name = node.decl.name
    
    # Enter function scope
    var_table.push_scope()
    
    # Process parameters
    if node.decl.type.args:
        param_offset = 0
        for param in node.decl.type.args.params:
            param_name = param.name
            type_names, pointer_level, array_dims = extract_type_info(param.type)
            
            type_spec = TypeSpec(type_names,
                                pointer_level=pointer_level,
                                array_dims=array_dims)
            
            # Parameters stored on stack
            param_var = Variable(param_name, type_spec, 'param', offset=param_offset)
            var_table.add_local(param_var)
            
            param_offset += type_spec.size
    
    # Process function body...
    self.visit(node.body)
    
    # Exit function scope
    var_table.pop_scope()
```

### Example 2: Processing Local Variables

**C Code:**
```c
void example(void) {
    int x = 5;
    uint8_t arr[10];
    char *str = "hello";
}
```

**Processing:**
```python
def visit_FuncDef(self, node):
    var_table.push_scope()
    
    # Track local variable offsets
    local_offset = 0
    
    # Visit compound statement (function body)
    for item in node.body.block_items:
        if isinstance(item, c_ast.Decl):
            var_name = item.name
            type_names, pointer_level, array_dims = extract_type_info(item.type)
            
            type_spec = TypeSpec(type_names,
                                pointer_level=pointer_level,
                                array_dims=array_dims)
            
            local_var = Variable(var_name, type_spec, 'local', offset=local_offset)
            var_table.add_local(local_var)
            
            local_offset += type_spec.size
            
            # Handle initialization if present
            if item.init:
                self.visit(item.init)
    
    var_table.pop_scope()
```

### Example 3: Complete Compiler Visitor

```python
from pycparser import c_ast, parse_file

class CompilerVisitor(c_ast.NodeVisitor):
    def __init__(self):
        self.var_table = VariableTable()
        self.current_offset = 0
        
    def visit_FileAST(self, node):
        """Process top-level declarations"""
        for ext in node.ext:
            self.visit(ext)
    
    def visit_Typedef(self, node):
        """Process typedef declarations"""
        typedef_name = node.name
        type_names, pointer_level, array_dims = extract_type_info(node.type)
        
        type_spec = TypeSpec(type_names,
                            pointer_level=pointer_level,
                            array_dims=array_dims)
        
        get_typedef_registry().add_typedef(typedef_name, type_spec)
    
    def visit_Struct(self, node):
        """Process struct definitions"""
        if not node.decls:  # Forward declaration
            return
        
        members = []
        for decl in node.decls:
            member_name = decl.name
            type_names, pointer_level, array_dims = extract_type_info(decl.type)
            
            member_type = TypeSpec(type_names,
                                  pointer_level=pointer_level,
                                  array_dims=array_dims)
            members.append((member_name, member_type))
        
        struct_def = StructDefinition(node.name, members)
        get_struct_registry().add_struct(struct_def)
    
    def visit_Decl(self, node):
        """Process variable declarations"""
        if not node.name:  # Anonymous declaration
            return
        
        var_name = node.name
        type_names, pointer_level, array_dims = extract_type_info(node.type)
        
        type_spec = TypeSpec(type_names,
                            pointer_level=pointer_level,
                            array_dims=array_dims)
        
        # Determine scope based on context
        if self.var_table.scopes:
            # Inside a function - local variable
            var = Variable(var_name, type_spec, 'local', offset=self.current_offset)
            self.var_table.add_local(var)
            self.current_offset += type_spec.size
        else:
            # Top-level - global variable
            var = Variable(var_name, type_spec, 'global')
            self.var_table.add_global(var)
    
    def visit_FuncDef(self, node):
        """Process function definitions"""
        self.var_table.push_scope()
        self.current_offset = 0
        
        # Process parameters
        if node.decl.type.args:
            for param in node.decl.type.args.params:
                if param.name:  # Skip void parameters
                    self.visit_Decl(param)
        
        # Process function body
        self.visit(node.body)
        
        self.var_table.pop_scope()

# Usage
def compile_file(filename):
    # Set up context
    typedef_reg = TypedefRegistry()
    struct_reg = StructRegistry()
    set_type_context(typedef_reg, struct_reg)
    
    # Parse C file
    ast = parse_file(filename, use_cpp=True)
    
    # Visit AST
    visitor = CompilerVisitor()
    visitor.visit(ast)
    
    return visitor.var_table
```

## Code Generation

### Emitting Variable Access

The `Variable` class provides methods for generating assembly code:

```python
var = var_table.lookup('x')

# Load variable into A register
var.emit_load(emitter)

# Store A register to variable
var.emit_store(emitter)

# Load address of variable into A register
var.emit_address(emitter)

# Access struct member (loads member address into A)
if var.is_struct:
    var.emit_member_access('field_name', emitter)
```

### Array Access

```python
# For array element access: arr[index]
arr_var = var_table.lookup('arr')

# 1. Emit code to compute index into A register
emit_expression(index_expr)  # Result in A

# 2. Load array element
arr_var.emit_load(emitter, index_expr=True)  # Uses A as index
```

### Static Variable Declaration

```python
# For global/static variables, emit storage allocation
for var in var_table.get_all_globals():
    if var.is_static:
        var.emit_static_declaration(emitter)
```

### Example: Emitting Assignment

**C Code:**
```c
x = 42;
```

**Code Generation:**
```python
def emit_assignment(var_name, value, emitter):
    # Load value into A
    emitter(f"LDI_A {value}")
    
    # Store to variable
    var = var_table.lookup(var_name)
    var.emit_store(emitter)
```

## Type Promotion

The `Variable.promote()` static method implements C's integer promotion rules:

```python
var1 = Variable('a', TypeSpec('char'), 'local', offset=0)
var2 = Variable('b', TypeSpec('int'), 'local', offset=1)

# Determine result type for binary operation
result_type = Variable.promote(var1, var2)
# Returns var2 (int) because it's larger
```

## Testing

```python
import unittest
from variables import *

class TestTypeSystem(unittest.TestCase):
    def setUp(self):
        typedef_reg = TypedefRegistry()
        struct_reg = StructRegistry()
        set_type_context(typedef_reg, struct_reg)
    
    def test_typedef_resolution(self):
        t = TypeSpec('uint8_t')
        self.assertEqual(t.base_type, 'unsigned char')
        self.assertEqual(t.size, 1)
    
    def test_pointer_type(self):
        t = TypeSpec('int', pointer_level=1)
        self.assertTrue(t.is_pointer)
        self.assertEqual(t.size, 2)  # Pointers are 2 bytes
    
    def test_array_type(self):
        t = TypeSpec('char', array_dims=[10])
        self.assertTrue(t.is_array)
        self.assertEqual(t.size, 10)
    
    def test_struct_layout(self):
        s = StructDefinition('Test', [
            ('a', 'uint8_t'),
            ('b', TypeSpec('int', pointer_level=1)),
            ('c', 'uint16_t')
        ])
        
        self.assertEqual(s.size, 5)  # 1 + 2 + 2
        self.assertEqual(s.get_member_offset('a'), 0)
        self.assertEqual(s.get_member_offset('b'), 1)
        self.assertEqual(s.get_member_offset('c'), 3)

if __name__ == '__main__':
    unittest.main()
```

## Reference: pycparser Helper Functions

```python
def extract_type_info(type_node):
    """
    Extract complete type information from pycparser type node.
    
    Returns:
        tuple: (type_names, pointer_level, array_dims)
    """
    pointer_level = 0
    array_dims = []
    
    current = type_node
    while True:
        if isinstance(current, c_ast.PtrDecl):
            pointer_level += 1
            current = current.type
        elif isinstance(current, c_ast.ArrayDecl):
            if current.dim:
                if isinstance(current.dim, c_ast.Constant):
                    dim = int(current.dim.value)
                else:
                    # Complex expression - need to evaluate
                    dim = 0  # Placeholder
            else:
                dim = 0  # Unsized array
            array_dims.append(dim)
            current = current.type
        elif isinstance(current, c_ast.TypeDecl):
            current = current.type
        else:
            break
    
    if isinstance(current, c_ast.IdentifierType):
        type_names = current.names
    elif isinstance(current, c_ast.Struct):
        type_names = ['struct', current.name if current.name else '<anonymous>']
    else:
        raise ValueError(f"Unknown type node: {type(current).__name__}")
    
    return type_names, pointer_level, array_dims
```

