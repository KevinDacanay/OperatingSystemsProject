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
    jmp 0x08:kernel_main   ; Correct jump to kernel_main in 64-bit mode

; Disk loading routine: Read sectors from disk to memory
disk_load:
    pusha                   ; Save all registers
    mov ah, 0x02            ; BIOS read sector function
    mov al, dh              ; Number of sectors to read
    mov ch, 0               ; Cylinder
    mov cl, 2               ; Sector (kernel is at sector 2)
    mov dh, 0               ; Head
    mov dl, 0x80            ; Hard disk drive 0x80 (first disk)
    int 0x13                ; BIOS disk interrupt
    jc disk_error           ; Jump to error if there's a failure

    popa                    ; Restore registers
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
    or rax, 0x80000000        ; Set PG (paging) bit in CR0
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
