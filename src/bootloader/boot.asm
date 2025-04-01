; When your computer boots up, the BIOS (or UEFI, depending on 
; your system) loads the first 512 bytes of the boot sector from 
; the first bootable device (like a hard drive or USB) into 
; memory, specifically at memory address 0x7C00.

; Bootloader Code
[ORG 0x7C00]          ; BIOS loads the bootloader at 0x7C00

start:
    cli               ; Disable interrupts during setup

    ; Print 'H' and 'i' using BIOS interrupt (real mode)
    mov ah, 0x0E
    mov al, 'H'
    int 0x10

    mov al, 'i'
    int 0x10

    ; Load the kernel from disk (sector 2) into memory at 0x1000
    mov bx, 0x100000    ; Destination address
    mov dh, 1         ; Read 1 sector
    call disk_load

    ; Switch to protected mode
    cli               ; Disable interrupts
    lgdt [gdt_descriptor]  ; Load Global Descriptor Table

    ; Print 'G' to indicate GDT was loaded (real mode)
    mov ah, 0x0E
    mov al, 'G'
    int 0x10

    mov eax, cr0
    or eax, 1         ; Set protected mode bit
    mov cr0, eax

    ; Use far jump to flush pipeline and enter protected mode
    jmp CODE_SEG:init_protected_mode  

disk_load:
    pusha             
    mov ah, 0x02      ; BIOS read sector function
    mov al, dh        ; Number of sectors to read
    mov ch, 0         ; Cylinder
    mov cl, 2         ; Sector (kernel at sector 2)
    mov dh, 0         ; Head
    mov dl, 0x80      ; First hard disk
    int 0x13          ; BIOS disk interrupt
    jc disk_error     ; If error, jump to error handler

    cmp ah, 0         ; Check if read was successful
    jne disk_error    ; If not, jump to error handler

    ; Print debug letters after successful load
    mov ah, 0x0E
    mov al, 'L'       ; Print 'L' (Loaded)
    int 0x10
    mov al, 'D'       ; Print 'D' (Done)
    int 0x10

    popa 
    ret

disk_error:
    mov ah, 0x0E
    mov al, 'E'       ; Print 'E' for error
    int 0x10
    hlt

; Global Descriptor Table
gdt:
    dq 0x0000000000000000   ; Null descriptor

code_segment:
    dq 0x00209A0000000000   ; 64-bit code segment
data_segment:
    dq 0x0000920000000000   ; 64-bit data segment

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt - 1
    dd gdt

CODE_SEG equ code_segment - gdt
DATA_SEG equ data_segment - gdt

init_protected_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Debugging print in protected mode (write 'P' to video memory)
    mov dword [0xB8000], 0x2F50  ; 'P' in green on black

    ; Enable PAE for 64-bit mode
    mov eax, cr4
    or eax, 1 << 5     ; Set PAE (Physical Address Extension)
    mov cr4, eax

    ; Enable long mode
    mov ecx, 0xC0000080  ; Read EFER MSR
    rdmsr
    or eax, 1 << 8      ; Set LME (Long Mode Enable)
    wrmsr

    ; NEED TO SET UP PAGE TABLES!!!
    ; Set up page tables (1:1 mapping for now)
    mov eax, 0x2000    ; Page directory address
    mov cr3, eax

    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31    ; Enable paging
    mov cr0, eax

    ; Far jump to long mode
    jmp CODE_SEG:init_long_mode  

[bits 64]  ; 64-bit mode starts here
init_long_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Debugging print in 64-bit mode (write 'L' to video memory)
    mov qword [0xB8000], 0x2F4C  ; 'L' in green on black

    ; Jump to the 64-bit kernel entry
    mov rdi, 0   ; Kernel entry argument (if needed)
    call 0x100000  ; Jump to the kernel (64-bit)

    hlt

; Correct Padding (Bootloader MUST be exactly 512 bytes)
times 510 - ($ - $$) db 0  
dw 0xAA55  ; Boot signature


; How do we load the kernel into memory at 0x1000?
; When building the OS image (os.img):
;   The bootloader is written first (starting at 0x7C00).
;   The kernel is loaded next, starting at 0x1000.
;   The Makefile uses dd to place the bootloader and 
;   kernel at specific addresses in the os.img
