section .data
    clear_screen db 27, "[2J", 27, "[H", 0  ; ANSI escape codes to clear screen
    mut_interval dd 50                      ; Mutation interval
    chars db '@#X'                          ; Characters for grid display

section .bss
    rows resd 1                             ; Terminal rows
    cols resd 1                             ; Terminal columns
    grid resq 1                             ; Pointer to grid (2D array)
    generation resd 1                       ; Current generation

section .text
    global main
    extern malloc, free, srand, rand, time, usleep, printf, ioctl

main:
    push rbp
    mov rbp, rsp

    ; Get terminal size
    sub rsp, 16
    mov rdi, 1          ; STDOUT_FILENO
    mov rsi, 0x5413     ; TIOCGWINSZ
    lea rdx, [rsp]      ; winsize struct pointer
    mov rax, 16         ; SYS_ioctl
    syscall

    movzx eax, word [rsp]      ; Rows
    mov [rows], eax
    movzx eax, word [rsp+2]    ; Columns
    mov [cols], eax
    add rsp, 16

    ; Allocate grid (rows * sizeof(int*))
    mov eax, [rows]
    mov rdi, rax
    shl rdi, 3          ; Multiply by 8 (sizeof(int*))
    call malloc
    mov [grid], rax

    ; Allocate each row (cols * sizeof(int))
    mov rbx, [grid]
    xor r12, r12        ; Row index
.alloc_rows:
    cmp r12, [rows]
    jge .end_alloc
    mov eax, [cols]
    mov rdi, rax
    shl rdi, 2          ; Multiply by 4 (sizeof(int))
    call malloc
    mov [rbx + r12*8], rax
    inc r12
    jmp .alloc_rows
.end_alloc:

    ; Initialize grid
    call initialize_grid
    mov dword [generation], 0

.main_loop:
    ; Clear screen
    mov rdi, clear_screen
    call printf

    ; Print grid
    call print_grid

    ; Update grid
    call update_grid

    ; Mutate grid
    call mutate_grid

    ; Increment generation
    inc dword [generation]

    ; Sleep for 10ms
    mov rdi, 10000
    call usleep

    ; Repeat
    jmp .main_loop

    ; Cleanup (unreachable)
    mov rbx, [grid]
    xor r12, r12
.free_rows:
    cmp r12, [rows]
    jge .end_free
    mov rdi, [rbx + r12*8]
    call free
    inc r12
    jmp .free_rows
.end_free:
    mov rdi, [grid]
    call free

    leave
    ret

initialize_grid:
    push rbp
    mov rbp, rsp
    mov rbx, [grid]
    xor r12, r12        ; Row index
.init_rows:
    cmp r12, [rows]
    jge .end_init
    mov r13, [rbx + r12*8]
    xor r14, r14        ; Column index
.init_cols:
    cmp r14, [cols]
    jge .end_cols
    call rand
    and eax, 1          ; Random 0 or 1
    mov [r13 + r14*4], eax
    inc r14
    jmp .init_cols
.end_cols:
    inc r12
    jmp .init_rows
.end_init:
    leave
    ret

print_grid:
    push rbp
    mov rbp, rsp
    xor edi, edi
    call time
    mov edi, eax
    call srand
    mov rbx, [grid]
    xor r12, r12        ; Row index
.print_rows:
    cmp r12, [rows]
    jge .end_print
    mov r13, [rbx + r12*8]
    xor r14, r14        ; Column index
.print_cols:
    cmp r14, [cols]
    jge .end_row
    mov eax, [r13 + r14*4]
    test eax, eax
    jz .space
    call rand
    mov ecx, 3
    xor edx, edx
    div ecx
    movzx edi, byte [chars + rdx]
    jmp .print
.space:
    mov edi, ' '
.print:
    call putchar
    inc r14
    jmp .print_cols
.end_row:
    mov edi, 0x0A       ; Newline
    call putchar
    inc r12
    jmp .print_rows
.end_print:
    leave
    ret

update_grid:
    push rbp
    mov rbp, rsp
    ; Allocate new grid
    mov eax, [rows]
    mov rdi, rax
    shl rdi, 3
    call malloc
    mov r15, rax        ; new_grid
    xor r12, r12        ; Row index
.alloc_new_rows:
    cmp r12, [rows]
    jge .end_alloc_new
    mov eax, [cols]
    mov rdi, rax
    shl rdi, 2
    call malloc
    mov [r15 + r12*8], rax
    inc r12
    jmp .alloc_new_rows
.end_alloc_new:

    ; Update logic
    xor r12, r12        ; Row index
.update_rows:
    cmp r12, [rows]
    jge .end_update
    mov r13, [r15 + r12*8]
    mov r14, [grid]
    mov r14, [r14 + r12*8]
    xor rbx, rbx        ; Column index
.update_cols:
    cmp rbx, [cols]
    jge .end_update_cols
    mov rdi, [grid]
    mov rsi, [rows]
    mov rdx, [cols]
    mov rcx, r12
    mov r8, rbx
    call count_neighbors
    mov r9d, eax        ; neighbors count
    mov eax, [r14 + rbx*4]
    test eax, eax
    jz .dead_cell
    ; Alive cell
    cmp r9d, 2
    je .alive
    cmp r9d, 3
    je .alive
    jmp .dead
.dead_cell:
    ; Dead cell
    cmp r9d, 3
    je .alive
.dead:
    xor eax, eax
    jmp .set_cell
.alive:
    mov eax, 1
.set_cell:
    mov [r13 + rbx*4], eax
    inc rbx
    jmp .update_cols
.end_update_cols:
    inc r12
    jmp .update_rows
.end_update:

    ; Copy new grid to old grid
    mov rbx, [grid]
    xor r12, r12        ; Row index
.copy_rows:
    cmp r12, [rows]
    jge .end_copy
    mov r13, [rbx + r12*8]
    mov r14, [r15 + r12*8]
    xor rbx, rbx        ; Column index
.copy_cols:
    cmp rbx, [cols]
    jge .end_copy_cols
    mov eax, [r14 + rbx*4]
    mov [r13 + rbx*4], eax
    inc rbx
    jmp .copy_cols
.end_copy_cols:
    inc r12
    jmp .copy_rows
.end_copy:

    ; Free new grid
    xor r12, r12        ; Row index
.free_new_rows:
    cmp r12, [rows]
    jge .end_free_new
    mov rdi, [r15 + r12*8]
    call free
    inc r12
    jmp .free_new_rows
.end_free_new:
    mov rdi, r15
    call free

    leave
    ret

count_neighbors:
    push rbp
    mov rbp, rsp
    ; rdi = grid, rsi = rows, rdx = cols, rcx = x, r8 = y
    xor r9, r9          ; count = 0
    mov r10, rcx        ; x
    mov r11, r8         ; y
    mov r12, -1         ; i = -1
.neighbor_loop_i:
    cmp r12, 1
    jg .end_neighbors
    mov r13, -1         ; j = -1
.neighbor_loop_j:
    cmp r13, 1
    jg .end_j
    ; Skip center cell
    test r12, r12
    jnz .not_center
    test r13, r13
    jz .skip_cell
.not_center:
    ; Calculate nx = (x + i + rows) % rows
    mov rax, r10
    add rax, r12
    add rax, rsi
    xor rdx, rdx
    div rsi
    mov r14, rdx        ; nx
    ; Calculate ny = (y + j + cols) % cols
    mov rax, r11
    add rax, r13
    add rax, rdx
    xor rdx, rdx
    div rdx
    mov r15, rdx        ; ny
    ; Get grid[nx][ny]
    mov rax, [rdi + r14*8]
    movzx eax, byte [rax + r15]
    add r9d, eax
.skip_cell:
    inc r13
    jmp .neighbor_loop_j
.end_j:
    inc r12
    jmp .neighbor_loop_i
.end_neighbors:
    mov eax, r9d
    leave
    ret

mutate_grid:
    push rbp
    mov rbp, rsp
    ; Check if generation % MUTATION_INTERVAL == 0
    mov eax, [generation]
    xor edx, edx
    div dword [mut_interval]
    test edx, edx
    jnz .end_mutate
    ; Mutate logic
    mov eax, [rows]
    mov ecx, 5
    xor edx, edx
    div ecx
    mov ecx, eax        ; rows / 5
    xor r12, r12        ; i = 0
.mutate_loop:
    cmp r12, rcx
    jge .end_mutate
    call rand
    xor edx, edx
    div dword [rows]
    mov r13d, edx       ; x = rand() % rows
    call rand
    xor edx, edx
    div dword [cols]
    mov r14d, edx       ; y = rand() % cols
    ; Flip cell state
    mov rbx, [grid]
    mov rbx, [rbx + r13*8]
    mov eax, [rbx + r14*4]
    not eax
    and eax, 1
    mov [rbx + r14*4], eax
    inc r12
    jmp .mutate_loop
.end_mutate:
    leave
    ret
