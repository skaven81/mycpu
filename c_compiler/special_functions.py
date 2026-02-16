
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

    def custom_FuncCall_halt(self, node, mode, func, dest_reg='A', **kwargs):
        self.emit("HLT", "Halt the system")

    # ---- Memory management (register-based) ----

    def custom_FuncCall_free(self, node, mode, func, dest_reg='A', **kwargs):
        # free() takes address in register A
        arg_nodes = self.visit(node.args, mode='return_nodes')
        rvalue_var = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit(f"CALL {func.asm_name()}", "Free memory at address in A")

    def custom_FuncCall_malloc_blocks(self, node, mode, func, dest_reg='A', **kwargs):
        # malloc_blocks() takes size in AL, returns address in A
        arg_nodes = self.visit(node.args, mode='return_nodes')
        rvalue_var = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit(f"CALL {func.asm_name()}", "Allocate blocks, size in AL, result in A")
        if dest_reg != 'A':
            self.emit(f"CALL :heap_push_A", "Move return value to dest_reg")
            self.emit(f"CALL :heap_pop_{dest_reg}", "Pop return value into dest_reg")

    def custom_FuncCall_calloc_blocks(self, node, mode, func, dest_reg='A', **kwargs):
        # calloc_blocks() takes size in AL, returns address in A
        arg_nodes = self.visit(node.args, mode='return_nodes')
        rvalue_var = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit(f"CALL {func.asm_name()}", "Allocate+zero blocks, size in AL, result in A")
        if dest_reg != 'A':
            self.emit(f"CALL :heap_push_A", "Move return value to dest_reg")
            self.emit(f"CALL :heap_pop_{dest_reg}", "Pop return value into dest_reg")

    # ---- Terminal output (register-based) ----

    def custom_FuncCall_putchar(self, node, mode, func, dest_reg='A', **kwargs):
        # putchar() takes character in AL register
        arg_nodes = self.visit(node.args, mode='return_nodes')
        rvalue_var = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit(f"CALL {func.asm_name()}", "Print character in AL")

    def custom_FuncCall_putchar_direct(self, node, mode, func, dest_reg='A', **kwargs):
        # putchar_direct() takes character in AL register
        arg_nodes = self.visit(node.args, mode='return_nodes')
        rvalue_var = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit(f"CALL {func.asm_name()}", "Print character directly in AL")

    # ---- String functions (register-based) ----

    def custom_FuncCall_strcmp(self, node, mode, func, dest_reg='A', **kwargs):
        # ASM: C=s1, D=s2 → CALL :strcmp → result in AL
        # C: int8_t strcmp(char *s1, char *s2)
        arg_nodes = self.visit(node.args, mode='return_nodes')
        # Evaluate args and stage on heap
        rvalue_s1 = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Stage s1 on heap")
        rvalue_s2 = self.visit(arg_nodes[1], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Stage s2 on heap")
        # Save C and D
        self.emit("PUSH_CH", "Save C before strcmp")
        self.emit("PUSH_CL", "Save C before strcmp")
        self.emit("PUSH_DH", "Save D before strcmp")
        self.emit("PUSH_DL", "Save D before strcmp")
        # Pop staged values into registers (LIFO: s2 into D, s1 into C)
        self.emit("CALL :heap_pop_D", "Load s2 into D")
        self.emit("CALL :heap_pop_C", "Load s1 into C")
        self.emit(f"CALL {func.asm_name()}")
        # Result is in AL; save on CPU stack
        self.emit("ALUOP_PUSH %A%+%AL%", "Save strcmp result")
        # Restore D, C (reverse order of save)
        self.emit("POP_DL", "Restore D after strcmp")
        self.emit("POP_DH", "Restore D after strcmp")
        self.emit("POP_CL", "Restore C after strcmp")
        self.emit("POP_CH", "Restore C after strcmp")
        # Pop result into dest_reg low byte, clear high byte
        self.emit(f"POP_{dest_reg}L", "strcmp result into dest_reg")
        self.emit(f"LDI_{dest_reg}H 0x00", "Clear high byte for int8_t return")

    def custom_FuncCall_strcpy(self, node, mode, func, dest_reg='A', **kwargs):
        # ASM: C=src, D=dest → CALL :strcpy → no return
        # C: void strcpy(char *src, char *dest)
        arg_nodes = self.visit(node.args, mode='return_nodes')
        # Evaluate args and stage on heap
        rvalue_src = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Stage src on heap")
        rvalue_dest = self.visit(arg_nodes[1], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Stage dest on heap")
        # Save C and D
        self.emit("PUSH_CH", "Save C before strcpy")
        self.emit("PUSH_CL", "Save C before strcpy")
        self.emit("PUSH_DH", "Save D before strcpy")
        self.emit("PUSH_DL", "Save D before strcpy")
        # Pop staged values into registers (LIFO: dest into D, src into C)
        self.emit("CALL :heap_pop_D", "Load dest into D")
        self.emit("CALL :heap_pop_C", "Load src into C")
        self.emit(f"CALL {func.asm_name()}")
        # No return value; restore D, C
        self.emit("POP_DL", "Restore D after strcpy")
        self.emit("POP_DH", "Restore D after strcpy")
        self.emit("POP_CL", "Restore C after strcpy")
        self.emit("POP_CH", "Restore C after strcpy")

    def custom_FuncCall_strupper(self, node, mode, func, dest_reg='A', **kwargs):
        # ASM: C=src, D=dest → CALL :strupper → no return
        # C: void strupper(char *src, char *dest)
        arg_nodes = self.visit(node.args, mode='return_nodes')
        # Evaluate args and stage on heap
        rvalue_src = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Stage src on heap")
        rvalue_dest = self.visit(arg_nodes[1], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Stage dest on heap")
        # Save C and D
        self.emit("PUSH_CH", "Save C before strupper")
        self.emit("PUSH_CL", "Save C before strupper")
        self.emit("PUSH_DH", "Save D before strupper")
        self.emit("PUSH_DL", "Save D before strupper")
        # Pop staged values into registers (LIFO: dest into D, src into C)
        self.emit("CALL :heap_pop_D", "Load dest into D")
        self.emit("CALL :heap_pop_C", "Load src into C")
        self.emit(f"CALL {func.asm_name()}")
        # No return value; restore D, C
        self.emit("POP_DL", "Restore D after strupper")
        self.emit("POP_DH", "Restore D after strupper")
        self.emit("POP_CL", "Restore C after strupper")
        self.emit("POP_CH", "Restore C after strupper")

    def custom_FuncCall_strprepend(self, node, mode, func, dest_reg='A', **kwargs):
        # ASM: AL=ch, D=str → CALL :strprepend → no return
        # C: void strprepend(char ch, char *str)
        arg_nodes = self.visit(node.args, mode='return_nodes')
        # Evaluate args and stage on heap
        rvalue_ch = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_AL", "Stage ch on heap (byte)")
        rvalue_str = self.visit(arg_nodes[1], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Stage str on heap (word)")
        # Save D
        self.emit("PUSH_DH", "Save D before strprepend")
        self.emit("PUSH_DL", "Save D before strprepend")
        # Pop staged values into registers (LIFO: str into D, ch into AL)
        self.emit("CALL :heap_pop_D", "Load str into D")
        self.emit("CALL :heap_pop_AL", "Load ch into AL")
        self.emit(f"CALL {func.asm_name()}")
        # No return value; restore D
        self.emit("POP_DL", "Restore D after strprepend")
        self.emit("POP_DH", "Restore D after strprepend")

    def custom_FuncCall_strsplit(self, node, mode, func, dest_reg='A', **kwargs):
        # ASM: AH=split_char, AL=alloc_size, C=str, D=array → CALL :strsplit → result in AH
        # C: uint8_t strsplit(char split_char, uint8_t alloc_size, char *str, uint16_t *array)
        arg_nodes = self.visit(node.args, mode='return_nodes')
        # Evaluate args and stage on heap
        rvalue_split = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_AL", "Stage split_char on heap (byte)")
        rvalue_alloc = self.visit(arg_nodes[1], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_AL", "Stage alloc_size on heap (byte)")
        rvalue_str = self.visit(arg_nodes[2], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Stage str on heap (word)")
        rvalue_arr = self.visit(arg_nodes[3], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Stage array on heap (word)")
        # Save C and D
        self.emit("PUSH_CH", "Save C before strsplit")
        self.emit("PUSH_CL", "Save C before strsplit")
        self.emit("PUSH_DH", "Save D before strsplit")
        self.emit("PUSH_DL", "Save D before strsplit")
        # Pop staged values into registers (LIFO order)
        self.emit("CALL :heap_pop_D", "Load array into D")
        self.emit("CALL :heap_pop_C", "Load str into C")
        self.emit("CALL :heap_pop_AL", "Load alloc_size into AL")
        self.emit("ALUOP_PUSH %A%+%AL%", "Save alloc_size temporarily")
        self.emit("CALL :heap_pop_AH", "Load split_char into AH")
        self.emit("POP_AL", "Restore alloc_size into AL")
        self.emit(f"CALL {func.asm_name()}")
        # Result is in AH; save on CPU stack
        self.emit("ALUOP_PUSH %A%+%AH%", "Save strsplit result")
        # Restore D, C (reverse order of save)
        self.emit("POP_DL", "Restore D after strsplit")
        self.emit("POP_DH", "Restore D after strsplit")
        self.emit("POP_CL", "Restore C after strsplit")
        self.emit("POP_CH", "Restore C after strsplit")
        # Pop result into dest_reg low byte, clear high byte
        self.emit(f"POP_{dest_reg}L", "strsplit result into dest_reg")
        self.emit(f"LDI_{dest_reg}H 0x00", "Clear high byte for uint8_t return")

    # ---- Multi-return FAT16 functions ----

    def custom_FuncCall_fat16_dirent_filesize(self, node, mode, func, dest_reg='A', **kwargs):
        # ASM: push dirent addr → call → pop lo word, pop hi word
        # C: uint16_t fat16_dirent_filesize(struct fat16_dirent *d, uint16_t *size_hi)
        # Returns lo word; writes hi word to *size_hi
        arg_nodes = self.visit(node.args, mode='return_nodes')
        # Save output pointer on heap first (will be below ASM params)
        rvalue_hi = self.visit(arg_nodes[1], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Save size_hi output pointer on heap")
        # Push dirent address (the only ASM param)
        rvalue_d = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Push dirent address param")
        self.emit(f"CALL {func.asm_name()}")
        # Heap now: lo_word(top), hi_word, size_hi_ptr(bottom)
        # Pop lo word (return value), save on CPU stack
        self.emit(f"CALL :heap_pop_{dest_reg}", "Pop lo word of file size (return value)")
        self.emit(f"ALUOP_PUSH %{dest_reg}%+%{dest_reg}H%", "Save return value")
        self.emit(f"ALUOP_PUSH %{dest_reg}%+%{dest_reg}L%", "Save return value")
        # Pop hi word into A
        self.emit("CALL :heap_pop_A", "Pop hi word of file size")
        # Pop output pointer into D (save/restore frame pointer)
        self.emit("PUSH_DH", "Save frame pointer")
        self.emit("PUSH_DL", "Save frame pointer")
        self.emit("CALL :heap_pop_D", "Pop size_hi output pointer")
        # Store hi word at *size_hi (big-endian: high byte first)
        self.emit("ALUOP_ADDR_D %A%+%AH%", "Store hi byte at *size_hi")
        self.emit("INCR_D")
        self.emit("ALUOP_ADDR_D %A%+%AL%", "Store lo byte at *(size_hi+1)")
        self.emit("POP_DL", "Restore frame pointer")
        self.emit("POP_DH", "Restore frame pointer")
        # Restore return value
        self.emit(f"POP_{dest_reg}L", "Restore return value")
        self.emit(f"POP_{dest_reg}H", "Restore return value")

    def custom_FuncCall_fat16_cluster_to_lba(self, node, mode, func, dest_reg='A', **kwargs):
        # ASM: push handle addr, push cluster → call → pop lo LBA, pop hi LBA
        # C: uint16_t fat16_cluster_to_lba(struct fs_handle *h, uint16_t cluster, uint16_t *lba_hi)
        # Returns lo word of LBA; writes hi word to *lba_hi
        arg_nodes = self.visit(node.args, mode='return_nodes')
        # Save output pointer on heap first (below ASM params)
        rvalue_hi = self.visit(arg_nodes[2], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Save lba_hi output pointer on heap")
        # Push ASM params in reverse C order: handle first (bottom), cluster second (top)
        rvalue_h = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Push fs_handle address param")
        rvalue_c = self.visit(arg_nodes[1], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Push cluster param")
        self.emit(f"CALL {func.asm_name()}")
        # Heap now: lo_lba(top), hi_lba, lba_hi_ptr(bottom)
        # Pop lo word (return value), save on CPU stack
        self.emit(f"CALL :heap_pop_{dest_reg}", "Pop lo word of LBA (return value)")
        self.emit(f"ALUOP_PUSH %{dest_reg}%+%{dest_reg}H%", "Save return value")
        self.emit(f"ALUOP_PUSH %{dest_reg}%+%{dest_reg}L%", "Save return value")
        # Pop hi word into A
        self.emit("CALL :heap_pop_A", "Pop hi word of LBA")
        # Pop output pointer into D (save/restore frame pointer)
        self.emit("PUSH_DH", "Save frame pointer")
        self.emit("PUSH_DL", "Save frame pointer")
        self.emit("CALL :heap_pop_D", "Pop lba_hi output pointer")
        # Store hi word at *lba_hi
        self.emit("ALUOP_ADDR_D %A%+%AH%", "Store hi byte at *lba_hi")
        self.emit("INCR_D")
        self.emit("ALUOP_ADDR_D %A%+%AL%", "Store lo byte at *(lba_hi+1)")
        self.emit("POP_DL", "Restore frame pointer")
        self.emit("POP_DH", "Restore frame pointer")
        # Restore return value
        self.emit(f"POP_{dest_reg}L", "Restore return value")
        self.emit(f"POP_{dest_reg}H", "Restore return value")

    # ---- Conditional-return FAT16 functions ----

    def custom_FuncCall_fat16_pathfind(self, node, mode, func, dest_reg='A', **kwargs):
        # ASM: push path → call → conditional return:
        #   Error: pop error_code (hi byte 0x00 or 0x01)
        #   Success: pop dirent_addr (hi byte >= 0x02), then pop fs_handle_addr
        # C: struct fat16_dirent *fat16_pathfind(char *path, struct fs_handle **fs_handle_out)
        # Returns dirent pointer (NULL or error code on failure)
        # Writes fs_handle pointer to *fs_handle_out on success
        arg_nodes = self.visit(node.args, mode='return_nodes')
        error_label = self._get_label("pathfind_err")
        done_label = self._get_label("pathfind_done")
        # Save fs_handle_out pointer on heap (below ASM params)
        rvalue_out = self.visit(arg_nodes[1], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Save fs_handle_out pointer on heap")
        # Push path address to heap (ASM param)
        rvalue_path = self.visit(arg_nodes[0], mode='generate_rvalue', dest_reg='A')
        self.emit("CALL :heap_push_A", "Push path address param")
        self.emit(f"CALL {func.asm_name()}")
        # Heap on success: dirent(top), fs_handle, out_ptr(bottom)
        # Heap on error: error_code(top), out_ptr(bottom)
        # Pop first value (dirent or error code)
        self.emit("CALL :heap_pop_A", "Pop pathfind result")
        # Save result on CPU stack
        self.emit("ALUOP_PUSH %A%+%AH%", "Save result")
        self.emit("ALUOP_PUSH %A%+%AL%", "Save result")
        # Check if error: AH < 0x02 means error
        # Right-shift AH: 0>>1=0, 1>>1=0, 2>>1=1, etc. So JZ = error
        self.emit("ALUOP_FLAGS %A>>1%+%AH%", "Shift AH right: 0 if AH < 2 (error)")
        self.emit(f"JZ {error_label}", "Jump to error path if AH < 0x02")
        # Success: pop fs_handle, pop out_ptr, store fs_handle at *out_ptr
        self.emit("CALL :heap_pop_A", "Pop fs_handle address")
        self.emit("PUSH_DH", "Save frame pointer")
        self.emit("PUSH_DL", "Save frame pointer")
        self.emit("CALL :heap_pop_D", "Pop fs_handle_out pointer")
        self.emit("ALUOP_ADDR_D %A%+%AH%", "Store fs_handle hi at *out")
        self.emit("INCR_D")
        self.emit("ALUOP_ADDR_D %A%+%AL%", "Store fs_handle lo at *(out+1)")
        self.emit("POP_DL", "Restore frame pointer")
        self.emit("POP_DH", "Restore frame pointer")
        self.emit(f"JMP {done_label}")
        # Error: discard saved out_ptr from heap
        self.emit(f"{error_label}")
        self.emit("CALL :heap_pop_word", "Discard saved fs_handle_out pointer")
        # Done: restore result into dest_reg
        self.emit(f"{done_label}")
        self.emit(f"POP_{dest_reg}L", "Restore return value")
        self.emit(f"POP_{dest_reg}H", "Restore return value")
