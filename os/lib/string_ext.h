// Concatenate null-terminated strings referenced on the heap into the
// buffer at a destination address.
//
// NOT a normal C-callable function -- there is no custom_FuncCall_strcat
// handler in c_compiler/special_functions.py, so this is deliberately NOT
// declared `extern` here. Its calling convention is a hybrid that a plain
// heap-arg C signature cannot express:
//   AL: count of source string pointers to pop from the heap
//   D:  destination address, passed directly in register D (not on the
//       heap, and not expressible as a C pointer parameter)
//   heap: AL string pointer words, pushed by the caller before the call
//
// After execution, D points at the beginning of the concatenated string
// and AL is zero. See os/lib/string_ext.asm for the full contract and
// implementation.
//
// To call :strcat from assembly:
//  1. Load the destination address into D
//  2. Push each source string pointer to the heap (heap_push_C, etc.)
//  3. Load the pointer count into AL
//  4. CALL :strcat
//
// If this is ever needed from C, add a custom_FuncCall_strcat handler to
// special_functions.py that adapts a normal C argument list (e.g. a
// destination pointer plus a NULL-terminated array of source pointers)
// into this register/heap convention, then declare the adapted signature
// here.
