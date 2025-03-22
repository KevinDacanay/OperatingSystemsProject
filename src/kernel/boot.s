.global _start    # Make _start globally accessible
.extern kernel_main  # Declare external function

.section .text
_start:
    # Set up the stack
    cli               # Disable interrupts
    mov $0x10, %ax    # Load data segment selector
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss

    # Call kernel_main() (Assuming it is defined in C++)
    sti               # Enable interrupts
    call kernel_main

    # Infinite loop to prevent returning
    hlt
.loop:
    jmp .loop
