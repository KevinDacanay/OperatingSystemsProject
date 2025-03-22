; When your computer boots up, the BIOS (or UEFI, depending on 
; your system) loads the first 512 bytes of the boot sector from 
; the first bootable device (like a hard drive or USB) into 
; memory, specifically at memory address 0x7C00.

; Bootloader Code
[ORG 0x7C00]          ; BIOS loads the bootloader at 0x7C00

start:
    cli               ; Disable interrupts during setup

    ; Print 'Hi' to the screen
    mov ah, 0x0E      ; Teletype output function
    mov al, 'H'       ; Print 'H'
    int 0x10

    mov al, 'i'       ; Print 'i'
    int 0x10

    ; Load the kernel from disk (sector 2) into memory at 0x1000
    mov bx, 0x1000    ; Destination address (where kernel loads)
    mov dh, 1         ; Read 1 sector
    call disk_load

    ; Now switch to protected mode
    cli               ; Disable interrupts
    lgdt [gdt_descriptor] ; Load Global Descriptor Table

    mov eax, cr0
    or eax, 1         ; Set protected mode bit
    mov cr0, eax

    jmp CODE_SEG:init_protected_mode  ; Far jump to update CS

; Disk Load function:
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

    ; Print success indicator
    mov ah, 0x0E
    mov al, 'S'       ; Print 'S' for success
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
    dw 0xFFFF       ; Limit (4GB)
    dw 0x0000       ; Base address (low)
    db 0x00         ; Base address (middle)
    db 0x9A         ; Code segment: Execute, Read, Present
    db 0xCF         ; Granularity, 32-bit
    db 0x00         ; Base address (high)

data_segment:
    dw 0xFFFF       ; Limit (4GB)
    dw 0x0000       ; Base address (low)
    db 0x00         ; Base address (middle)
    db 0x92         ; Data segment: Read/Write, Present
    db 0xCF         ; Granularity, 32-bit
    db 0x00         ; Base address (high)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt - 1
    dd gdt          ; Address of GDT

CODE_SEG equ code_segment - gdt
DATA_SEG equ data_segment - gdt

init_protected_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Jump to the kernel in protected mode
    jmp CODE_SEG:0x1000  

; Correct Padding to ensure bootloader is **EXACTLY** 512 bytes
times 510 - ($ - $$) db 0  ; Fill with zeros
dw 0xAA55                  ; Boot signature

; How do we load the kernel into memory at 0x1000?
; When building the OS image (os.img):
;   The bootloader is written first (starting at 0x7C00).
;   The kernel is loaded next, starting at 0x1000.
;   The Makefile uses dd to place the bootloader and 
;   kernel at specific addresses in the os.img