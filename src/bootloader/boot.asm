; When your computer boots up, the BIOS (or UEFI, depending on 
; your system) loads the first 512 bytes of the boot sector from 
; the first bootable device (like a hard drive or USB) into 
; memory, specifically at memory address 0x7C00.

; boot.asm - Basic bootloader
[ORG 0x7C00]          ; BIOS loads the bootloader at 0x7C00

; Bootloader Code
; the bootloader needs to load the kernel. In our case, we are 
; hardcoding the assumption that the kernel will be loaded at 
; memory address 0x1000.
start:
    mov ah, 0x0E      ; Teletype output function
    mov al, 'H'       ; Print 'H'
    int 0x10          ; Call BIOS interrupt to print char

    mov al, 'i'       ; Print 'i'
    int 0x10

    ; Jump to the kernel (load kernel at 0x1000)
    jmp 0x1000

times 510 - ($ - $$) db 0  ; Fill the rest with zeros
dw 0xAA55                ; Boot signature

; How do we load the kernel into memory at 0x1000?
; When building the OS image (os.img):
;   The bootloader is written first (starting at 0x7C00).
;   The kernel is loaded next, starting at 0x1000.
;   The Makefile uses dd to place the bootloader and 
;   kernel at specific addresses in the os.img