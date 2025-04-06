[BITS 64]   ; Use 64-bit mode, not 32-bit

global _start

section .text
_start:
    xor rax, rax            ; Clear RAX register (use as zero)
    mov ds, rax             ; Set DS = 0
    mov es, rax             ; Set ES = 0
    mov ss, rax             ; Set SS = 0
    mov rsp, 0x7C00         ; Set the stack pointer to 0x7C00

    ; Instead of using `int 0x10` for printing, we will skip that for now.
    ; If you want to print, consider using VGA buffer or serial output.
    ; Remove `cli` since it is unnecessary in 64-bit mode.

    ; Load the kernel from disk (sector 2) into memory at 0x10000
    mov rax, 0x1000          ; Load the kernel at address 0x10000
    mov rbx, rax             ; Use rbx to hold the segment value
    mov es, rbx              ; Set ES register (segment)
    xor bx, bx               ; BX = 0 (low part of address 0x10000)
    mov dh, 20               ; Read 20 sectors (adjust as needed)
    call disk_load

    ; Print 'K' to indicate that the kernel is loaded
    ; Again, replace the print method (VGA, serial, etc.)

    ; Set up the Global Descriptor Table (GDT), transition to protected mode
    ; Then setup paging
    call setup_gdt
    call setup_paging

    ; Jump to kernel entry point in 64-bit mode
    jmp 0x10000   ; Correct jump to kernel_main in 64-bit mode

; Disk loading routine: Read sectors from disk to memory
disk_load:
    ; pusha                   ; Save all registers
        ; Replace `pusha` with saving the necessary registers manually
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov ah, 0x02            ; BIOS read sector function
    mov al, dh              ; Number of sectors to read
    mov ch, 0               ; Cylinder
    mov cl, 2               ; Sector (kernel is at sector 2)
    mov dh, 0               ; Head
    mov dl, 0x80            ; Hard disk drive 0x80 (first disk)
    int 0x13                ; BIOS disk interrupt
    jc disk_error           ; Jump to error if there's a failure

    ; popa                    ; Restore registers
        ; Replace `popa` with restoring the registers manually
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx

    ret

; Error handler for disk load
disk_error:
    ; Add error handling code (VGA, serial, etc.)
    hlt                      ; Halt the system

; GDT Setup
setup_gdt:
    ; Set up the Global Descriptor Table (GDT) for 64-bit mode
    ; Assume the GDT is already loaded in memory and has valid entries
    ret

; Paging Setup
setup_paging:
    ; Set up the Page Table for 64-bit long mode (basic identity mapping)

    ; PML4 Table (Level 4)
    lea rbx, [pdpt_table]    ; Load address of PDPT (Page Directory Pointer Table)
    mov [pml4_table], rbx    ; PML4 entry points to PDPT

    lea rbx, [pd_table]      ; Load address of PD (Page Directory)
    mov [pdpt_table], rbx    ; PDPT entry points to PD

    lea rbx, [pt_table]      ; Load address of PT (Page Table)
    mov [pd_table], rbx      ; PD entry points to PT

    ; Set up PT entries for identity mapping
    mov rbx, 0               ; Start from 0 for identity mapping
    mov rcx, 512             ; Loop counter, 512 entries to fill

pt_loop:
    mov [pt_table + rbx*8], rbx     ; Each PT entry maps to 4KB page
    add rbx, 1                    ; Increment to the next physical address
    loop pt_loop                  ; Loop until rcx is 0

    ; Set up CR3 (Page Directory Base Register) to point to PML4 Table
    lea rbx, [pml4_table]     ; Load PML4 table address
    mov cr3, rbx              ; Load CR3 with PML4 table address

    ; Enable Paging (set PG bit in CR0)
    mov rax, cr0
    or rax, 0x8000000000000000   ; Set the PG (paging) bit (64-bit value)
    mov cr0, rax

    ; Enable 64-bit Long Mode (LME in MSR 0xC0000080)
    mov ecx, 0xC0000080       ; MSR address for EFER (Extended Feature Enable Register)
    rdmsr                     ; Read MSR
    or eax, 1 << 8            ; Set the LME (Long Mode Enable) bit
    wrmsr                     ; Write MSR

    ret

section .data
    ; PML4 Table (Level 4)
    pml4_table:
        times 512 dq 0         ; 512 entries, each 8 bytes (64-bit)

    ; PDPT Table (Level 3)
    pdpt_table:
        times 512 dq 0         ; 512 entries, each 8 bytes (64-bit)

    ; PD Table (Level 2)
    pd_table:
        times 512 dq 0         ; 512 entries, each 8 bytes (64-bit)

    ; PT Table (Level 1)
    pt_table:
        times 512 dq 0         ; 512 entries, each 8 bytes (64-bit)

; Correct padding to 512 bytes
times 510 db 0     ; Pad to ensure the bootloader is 512 bytes
dw 0xAA55          ; Boot signature

; [ORG 0x10000]
; BITS 16

; start:
;     cli                     ; Disable interrupts
;     xor ax, ax
;     mov ds, ax
;     mov es, ax
;     mov ss, ax
;     mov sp, 0x9000

;     ; Enable A20 line (real mode)
;     in al, 0x92
;     or al, 0x02
;     out 0x92, al

;     ; Load GDT
;     lgdt [gdt_descriptor]

;     ; Enter protected mode
;     mov eax, cr0
;     or eax, 1
;     mov cr0, eax

;     jmp CODE_SEG:init_pm    ; Far jump to flush pipeline

; [BITS 32]
; init_pm:
;     ; Set up segment registers
;     mov ax, DATA_SEG
;     mov ds, ax
;     mov es, ax
;     mov fs, ax
;     mov gs, ax
;     mov ss, ax

;     ; Enable PAE
;     mov eax, cr4
;     or eax, 1 << 5
;     mov cr4, eax

;     ; Load PML4 address into CR3
;     mov eax, pml4_table
;     mov cr3, eax

;     ; Enable long mode via EFER MSR
;     mov ecx, 0xC0000080     ; IA32_EFER MSR
;     rdmsr
;     or eax, 1 << 8          ; Set LME (Long Mode Enable)
;     wrmsr

;     ; Enable paging
;     mov eax, cr0
;     or eax, 0x80000000      ; Set PG (Paging) bit
;     mov cr0, eax

;     ; Far jump to 64-bit code
;     jmp 0x08:long_mode_entry

; [BITS 64]
; long_mode_entry:
;     ; Now in long mode!
;     mov ax, 0x10
;     mov ds, ax
;     mov ss, ax

;     ; Now you can call your C++ kernel at a higher half address if mapped
;     hlt

; ; ----------------------------
; ; GDT Setup (for protected/long mode)
; gdt_start:
; gdt_null:
;     dq 0x0000000000000000

; gdt_code:
;     dq 0x00AF9A000000FFFF   ; Code segment

; gdt_data:
;     dq 0x00AF92000000FFFF   ; Data segment

; gdt_end:

; gdt_descriptor:
;     dw gdt_end - gdt_start - 1
;     dd gdt_start

; CODE_SEG equ gdt_code - gdt_start
; DATA_SEG equ gdt_data - gdt_start

; ; ----------------------------
; ; Paging Setup (Identity-mapped, simple 2M paging)

; PML4_ENTRY equ pdpt_table + 0x03
; PDPT_ENTRY equ pd_table + 0x03

; align 4096
; pml4_table:
;     dq PML4_ENTRY

; align 4096
; pdpt_table:
;     dq PDPT_ENTRY

; align 4096
; pd_table:
;     ; One 2MB identity-mapped page
;     dq 0x0000000000000083    ; Present, Read/Write, 2MB Page
