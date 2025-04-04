#include "drivers/video.h"
#include "drivers/keyboard.h"
#include "drivers/string.h"
#include "drivers/interrupts.h"
#include "drivers/ports.h"


extern "C" void kernel_main() {
    const char* message = "Hello World! This is my 64-bit OS!";
    print(message);

    init_idt();
    enable_interrupts();

    const char* prompt = "os-shell$ ";
    char command[256];

    while (true) {
        print(prompt);
        read_input(command);
        print("\nYou typed: ");
        print(command);
        print("\n");

        if (strcmp(command, "exit") == 0) {
            break;
        } else if (strcmp(command, "clear") == 0) {
            clear_screen();
        } else {
            print("Unknown command: ");
            print(command);
        }
    }

    while (1) {
        __asm__ __volatile__("hlt");  // Halt instruction
    }
}
