#include <stdio.h>
#include <stdlib.h>

__attribute__((__noreturn__))
void abort(void) {
#if defined(__is_libk)
    // TO-DO: add proper kernel panic.
    printf("Kernel: panic: abort()\n");
    asm volatile("hlt");
#else
    // TO-DO: Abnormally terminate the process as if by SIGABRT
    printf("abort()\n");
#endif
    while (1) {}
    __builtin_unreachable();

}