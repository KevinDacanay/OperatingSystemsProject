#include <stdio.h>

#include <kernel/tty.h>

extern "C" void kernel_main() {
    terminal_initialize();
    printf("Hello, kernel!\n");
    
}