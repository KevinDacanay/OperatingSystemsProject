.global _start  
.extern kernel_main

.section .text
_start:
    cli
    mov $0x10, %ax      
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss

    /* Print 'K' to video memory */
    mov $0xB8000, %rbx
    movw $0x2F4B, (%rbx)  

    mov $0x90000, %rsp  # Set up 64-bit stack

    sti
    call kernel_main

    hlt  
.loop:
    jmp .loop
