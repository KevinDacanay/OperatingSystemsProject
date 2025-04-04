; Stage 1 Bootloader (boot.asm)
[ORG 0x7C00]          ; BIOS loads the bootloader at 0x7C00
[BITS 16]             ; Start in 16-bit real mode

start:
    cli               ; Disable interrupts during setup
    xor ax, ax        ; Clear AX register
    mov ds, ax        ; Set DS to 0
    mov es, ax        ; Set ES to 0
    mov ss, ax        ; Set SS to 0
    mov sp, 0x7C00    ; Set up stack pointer

    ; Print "Hi my name is Kevin!" using BIOS interrupt (real mode)
    mov ah, 0x0E
    mov al, 'H'
    int 0x10
    mov al, 'i'
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'm'
    int 0x10
    mov al, 'y'
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'n'
    int 0x10
    mov al, 'a'
    int 0x10
    mov al, 'm'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'i'
    int 0x10
    mov al, 's'
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'K'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'v'
    int 0x10
    mov al, 'i'
    int 0x10
    mov al, 'n'
    int 0x10
    mov al, '!'
    int 0x10

    ; Load Stage 2 bootloader from disk (sector 2) into memory at 0x10000
    mov ax, 0x1000    ; Use ES:BX for the destination address
    mov es, ax
    xor bx, bx        ; BX = 0
    mov dh, 1         ; Read 1 sector (stage 2)
    call disk_load

    ; Jump to Stage 2
    jmp 0x1000         ; Jump to the loaded Stage 2

; Disk loading routine
disk_load:
    pusha              ; Save registers
    mov ah, 0x02      ; BIOS read sector function
    mov al, dh        ; Number of sectors to read
    mov ch, 0         ; Cylinder
    mov cl, 2         ; Sector (stage 2 is at sector 2)
    mov dh, 0         ; Head
    mov dl, 0x80      ; First hard disk
    int 0x13          ; BIOS disk interrupt
    jc disk_error     ; If error, jump to error handler

    cmp ah, 0         ; Check if read was successful
    jne disk_error    ; If not, jump to error handler

    popa              ; Restore registers
    ret

disk_error:
    mov ah, 0x0E
    mov al, 'E'       ; Print 'E' for error
    int 0x10
    hlt

; Correct padding to make the bootloader exactly 512 bytes
times 510 - ($ - $$) db 0  
dw 0xAA55  ; Boot signature
