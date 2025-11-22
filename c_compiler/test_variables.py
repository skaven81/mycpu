#!/usr/bin/env python3
"""
Test harness for Variable class
Validates variable creation, type parsing, and code generation
"""

import sys
from variables import Variable, VariableTable

class TestEmitter:
    """Mock emitter that captures generated assembly code"""
    def __init__(self):
        self.lines = []
    
    def __call__(self, code, comment=None):
        if comment:
            self.lines.append(f"{code}  # {comment}")
        else:
            self.lines.append(code)
    
    def get_output(self):
        return '\n'.join(self.lines)
    
    def clear(self):
        self.lines = []

class TestRunner:
    """Manages test execution and reporting"""
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.tests = []
    
    def test(self, name, func):
        """Run a test function"""
        try:
            func()
            self.passed += 1
            print(f"✓ {name}")
            return True
        except AssertionError as e:
            self.failed += 1
            print(f"✗ {name}")
            print(f"  {e}")
            return False
        except Exception as e:
            self.failed += 1
            print(f"✗ {name} (EXCEPTION)")
            print(f"  {type(e).__name__}: {e}")
            return False
    
    def summary(self):
        """Print test summary"""
        total = self.passed + self.failed
        print(f"\n{'='*60}")
        print(f"Tests: {total} total, {self.passed} passed, {self.failed} failed")
        if self.failed == 0:
            print("✓ All tests passed!")
        else:
            print(f"✗ {self.failed} test(s) failed")
        print('='*60)
        return self.failed == 0

def test_basic_types():
    """Test basic type parsing"""
    
    # char
    var = Variable('c', ['char'], 'global')
    assert var.type == 'char', f"Expected 'char', got '{var.type}'"
    assert var.size == 1, f"Expected size 1, got {var.size}"
    assert var.signed == True, f"char should be signed"
    
    # unsigned char
    var = Variable('uc', ['unsigned', 'char'], 'global')
    assert var.type == 'char'
    assert var.size == 1
    assert var.signed == False
    
    # int
    var = Variable('i', ['int'], 'global')
    assert var.type == 'int'
    assert var.size == 2
    assert var.signed == True
    
    # unsigned int
    var = Variable('ui', ['unsigned', 'int'], 'global')
    assert var.type == 'int'
    assert var.size == 2
    assert var.signed == False
    
    # short
    var = Variable('s', ['short'], 'global')
    assert var.type == 'short'
    assert var.size == 2
    
    # short int (equivalent to short)
    var = Variable('si', ['short', 'int'], 'global')
    assert var.type == 'short int'
    assert var.size == 2
    
    # Plain unsigned/signed defaults to int
    var = Variable('u', ['unsigned'], 'global')
    assert var.type == 'int'
    assert var.size == 2
    assert var.signed == False

def test_pointer_types():
    """Test pointer type handling"""
    
    var = Variable('ptr', ['int'], 'global', is_pointer=True)
    assert var.is_pointer == True
    assert var.type == 'ptr'
    assert var.size == 2
    
    var = Variable('char_ptr', ['char'], 'global', is_pointer=True)
    assert var.is_pointer == True
    assert var.type == 'ptr'
    assert var.size == 2

def test_qualifiers():
    """Test type qualifiers (const, volatile, restrict)"""
    
    # const int
    var = Variable('ci', ['const', 'int'], 'global')
    assert var.is_const == True
    assert var.is_volatile == False
    assert 'const' in var.qualifiers
    
    # volatile char
    var = Variable('vc', ['volatile', 'char'], 'global')
    assert var.is_volatile == True
    assert var.is_const == False
    assert 'volatile' in var.qualifiers
    
    # const volatile int
    var = Variable('cvi', ['const', 'volatile', 'int'], 'global')
    assert var.is_const == True
    assert var.is_volatile == True

def test_storage_classes():
    """Test storage class specifiers"""
    
    # static int
    var = Variable('si', ['static', 'int'], 'global')
    assert var.storage_class == 'static'
    assert var.is_static == True
    
    # extern int
    var = Variable('ei', ['extern', 'int'], 'global')
    assert var.storage_class == 'extern'
    
    # register int (local)
    var = Variable('ri', ['register', 'int'], 'local', offset=2)
    assert var.storage_class == 'register'

def test_scope_validation():
    """Test scope and offset validation"""
    
    # Global should not have offset
    try:
        var = Variable('g', ['int'], 'global', offset=10)
        assert False, "Should have raised ValueError for global with offset"
    except ValueError as e:
        assert "should not have offset" in str(e)
    
    # Local/param must have offset
    try:
        var = Variable('l', ['int'], 'local')
        assert False, "Should have raised ValueError for local without offset"
    except ValueError as e:
        assert "requires offset" in str(e)
    
    # Valid local
    var = Variable('l', ['int'], 'local', offset=4)
    assert var.offset == 4

def test_asm_name_generation():
    """Test assembly name generation for static variables"""
    
    # Regular global with asm_var
    var = Variable('global_var', ['int'], 'global', static_type='asm_var')
    assert var.asm_name == '$global_var'
    
    # Static local with inline
    var = Variable('static_local', ['static', 'int'], 'local', offset=2, static_type='inline')
    assert var.asm_name == '.static_local'
    
    # Static local with asm_var
    var = Variable('static_local2', ['static', 'int'], 'local', offset=4, static_type='asm_var')
    assert var.asm_name == '$static_local2'

def test_static_declaration():
    """Test emit_static_declaration"""
    
    emitter = TestEmitter()
    
    # Byte variable
    var = Variable('byte_var', ['char'], 'global', static_type='asm_var')
    var.emit_static_declaration(emitter)
    output = emitter.get_output()
    assert 'VAR global byte $byte_var' in output
    
    emitter.clear()
    
    # Word variable
    var = Variable('word_var', ['int'], 'global', static_type='asm_var')
    var.emit_static_declaration(emitter)
    output = emitter.get_output()
    assert 'VAR global word $word_var' in output
    
    emitter.clear()
    
    # Inline static
    var = Variable('inline_var', ['static', 'int'], 'local', offset=2, static_type='inline')
    var.emit_static_declaration(emitter)
    output = emitter.get_output()
    assert '.inline_var' in output
    assert '\\0\\0' in output  # Two null bytes for 16-bit

def test_load_global():
    """Test emit_load for global variables"""
    
    emitter = TestEmitter()
    
    # Load 16-bit global
    var = Variable('global_int', ['int'], 'global', static_type='asm_var')
    var.emit_load(emitter)
    output = emitter.get_output()
    assert 'LD16_A $global_int' in output
    
    emitter.clear()
    
    # Load 8-bit signed global (should sign-extend)
    var = Variable('global_char', ['char'], 'global', static_type='asm_var')
    var.emit_load(emitter)
    output = emitter.get_output()
    assert 'LD_AL $global_char' in output
    assert 'Sign-extend' in output or 'sext' in output
    
    emitter.clear()
    
    # Load 8-bit unsigned global (should zero-extend)
    var = Variable('global_uchar', ['unsigned', 'char'], 'global', static_type='asm_var')
    var.emit_load(emitter)
    output = emitter.get_output()
    assert 'LD_AL $global_uchar' in output
    assert 'Zero-extend' in output or 'LDI_AH 0x00' in output

def test_load_local():
    """Test emit_load for local/param variables"""
    
    emitter = TestEmitter()
    
    # Load 16-bit local
    var = Variable('local_int', ['int'], 'local', offset=4)
    var.emit_load(emitter)
    output = emitter.get_output()
    assert 'LDI_BL 4' in output
    assert 'frame_load_BL_A' in output
    
    emitter.clear()
    
    # Load 8-bit param with negative offset
    var = Variable('param_char', ['char'], 'param', offset=2)
    var.emit_load(emitter)
    output = emitter.get_output()
    assert 'LDI_BL 2' in output
    assert 'frame_load_BL_AL' in output

def test_store_global():
    """Test emit_store for global variables"""
    
    emitter = TestEmitter()
    
    # Store 16-bit global
    var = Variable('global_int', ['int'], 'global')
    var.emit_store(emitter)
    output = emitter.get_output()
    assert 'ST_AH $global_int' in output
    assert 'ST_AL $global_int+1' in output
    
    emitter.clear()
    
    # Store 8-bit global
    var = Variable('global_char', ['char'], 'global')
    var.emit_store(emitter)
    output = emitter.get_output()
    assert 'ST_AL $global_char' in output

def test_store_local():
    """Test emit_store for local/param variables"""
    
    emitter = TestEmitter()
    
    # Store 16-bit local
    var = Variable('local_int', ['int'], 'local', offset=6)
    var.emit_store(emitter)
    output = emitter.get_output()
    assert 'LDI_BL 6' in output
    assert 'frame_store_BL_A' in output
    
    emitter.clear()
    
    # Store 8-bit local
    var = Variable('local_char', ['char'], 'local', offset=8)
    var.emit_store(emitter)
    output = emitter.get_output()
    assert 'LDI_BL 8' in output
    assert 'frame_store_BL_AL' in output

def test_emit_address():
    """Test emit_address (& operator)"""
    
    emitter = TestEmitter()
    
    # Address of global
    var = Variable('global_int', ['int'], 'global')
    var.emit_address(emitter)
    output = emitter.get_output()
    assert 'LDI_A $global_int' in output
    
    emitter.clear()
    
    # Address of local (D + offset)
    var = Variable('local_int', ['int'], 'local', offset=10)
    var.emit_address(emitter)
    output = emitter.get_output()
    assert 'ALUOP_AH %A%+%DH%' in output
    assert 'ALUOP_AL %A%+%DL%' in output
    assert 'LDI_B 10' in output
    assert 'add16_to_a' in output

def test_variable_promotion():
    """Test type promotion rules"""
    
    # Larger size wins
    char_var = Variable('c', ['char'], 'local', offset=2)
    int_var = Variable('i', ['int'], 'local', offset=4)
    
    promoted = Variable.promote(char_var, int_var)
    assert promoted.size == 2, "Should promote to larger size"
    
    promoted = Variable.promote(int_var, char_var)
    assert promoted.size == 2, "Order shouldn't matter"
    
    # Unsigned wins with same size
    signed_int = Variable('si', ['int'], 'local', offset=2)
    unsigned_int = Variable('ui', ['unsigned', 'int'], 'local', offset=4)
    
    promoted = Variable.promote(signed_int, unsigned_int)
    assert promoted.signed == False, "Should promote to unsigned"
    
    # Pointer wins
    int_var = Variable('i', ['int'], 'local', offset=2)
    ptr_var = Variable('p', ['int'], 'local', offset=4, is_pointer=True)
    
    promoted = Variable.promote(int_var, ptr_var)
    assert promoted.is_pointer == True, "Should promote to pointer"

def test_variable_table_basic():
    """Test VariableTable basic operations"""
    
    table = VariableTable()
    
    # Add global
    global_var = Variable('g', ['int'], 'global')
    table.add_global(global_var)
    
    # Lookup global
    found = table.lookup('g')
    assert found is not None
    assert found.name == 'g'
    
    # Lookup non-existent
    found = table.lookup('nonexistent')
    assert found is None

def test_variable_table_scopes():
    """Test VariableTable scope management"""
    
    table = VariableTable()
    
    # Add global
    global_var = Variable('x', ['int'], 'global')
    table.add_global(global_var)
    
    # Push scope and add local
    table.push_scope()
    local_var = Variable('x', ['int'], 'local', offset=2)
    table.add_local(local_var)
    
    # Local should shadow global
    found = table.lookup('x')
    assert found.scope == 'local', "Local should shadow global"
    
    # Pop scope
    table.pop_scope()
    
    # Should find global again
    found = table.lookup('x')
    assert found.scope == 'global', "Should find global after pop"

def test_variable_table_nested_scopes():
    """Test nested scope handling"""
    
    table = VariableTable()
    
    # Outer scope
    table.push_scope()
    outer_var = Variable('y', ['int'], 'local', offset=2)
    table.add_local(outer_var)
    
    # Inner scope
    table.push_scope()
    inner_var = Variable('y', ['char'], 'local', offset=4)
    table.add_local(inner_var)
    
    # Should find inner
    found = table.lookup('y')
    assert found.type == 'char', "Should find inner scope variable"
    
    # Pop inner
    table.pop_scope()
    
    # Should find outer
    found = table.lookup('y')
    assert found.type == 'int', "Should find outer scope variable"

def test_variable_table_duplicate_detection():
    """Test duplicate variable detection"""
    
    table = VariableTable()
    
    # Duplicate global
    var1 = Variable('dup', ['int'], 'global')
    table.add_global(var1)
    
    try:
        var2 = Variable('dup', ['int'], 'global')
        table.add_global(var2)
        assert False, "Should have raised ValueError for duplicate global"
    except ValueError as e:
        assert "already defined" in str(e)
    
    # Duplicate in same scope
    table.push_scope()
    var3 = Variable('dup2', ['int'], 'local', offset=2)
    table.add_local(var3)
    
    try:
        var4 = Variable('dup2', ['int'], 'local', offset=4)
        table.add_local(var4)
        assert False, "Should have raised ValueError for duplicate in scope"
    except ValueError as e:
        assert "already defined" in str(e)

def test_bool_type():
    """Test _Bool type handling"""
    
    var = Variable('flag', ['_Bool'], 'global')
    assert var.type == 'bool'
    assert var.size == 1
    assert var.signed == False  # _Bool is unsigned

def test_repr():
    """Test __repr__ output"""
    
    var = Variable('test', ['int'], 'global')
    repr_str = repr(var)
    assert 'test' in repr_str
    assert 'int' in repr_str
    assert 'global' in repr_str
    
    var = Variable('local', ['unsigned', 'char'], 'local', offset=4)
    repr_str = repr(var)
    assert 'local' in repr_str
    assert 'unsigned' in repr_str
    assert 'char' in repr_str
    assert 'D+4' in repr_str

def main():
    """Run all tests"""
    runner = TestRunner()
    
    print("Testing Variable Class")
    print("="*60)
    
    # Type parsing tests
    runner.test("Basic type parsing", test_basic_types)
    runner.test("Pointer types", test_pointer_types)
    runner.test("Type qualifiers", test_qualifiers)
    runner.test("Storage classes", test_storage_classes)
    runner.test("_Bool type", test_bool_type)
    
    # Validation tests
    runner.test("Scope validation", test_scope_validation)
    runner.test("Assembly name generation", test_asm_name_generation)
    
    # Code generation tests
    runner.test("Static declaration", test_static_declaration)
    runner.test("Load global variables", test_load_global)
    runner.test("Load local variables", test_load_local)
    runner.test("Store global variables", test_store_global)
    runner.test("Store local variables", test_store_local)
    runner.test("Emit address", test_emit_address)
    
    # Type promotion tests
    runner.test("Variable promotion", test_variable_promotion)
    
    # VariableTable tests
    runner.test("VariableTable basic operations", test_variable_table_basic)
    runner.test("VariableTable scopes", test_variable_table_scopes)
    runner.test("VariableTable nested scopes", test_variable_table_nested_scopes)
    runner.test("VariableTable duplicate detection", test_variable_table_duplicate_detection)
    
    # Misc tests
    runner.test("__repr__ output", test_repr)
    
    # Print summary
    success = runner.summary()
    
    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main())
