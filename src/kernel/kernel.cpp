#include "drivers/video.h"
#include "drivers/keyboard.h"
#include "drivers/string.h"
#include "drivers/ports.h"
#include "drivers/interrupts.h"

#include <stdint.h>  // Use correct fixed-width integer types

// extern "C": tells the compiler to use C linkage for the function
extern "C" void kernel_main() {
    // kernel_main is the entry point of the kernel, it's called by the bootloader
    // This is where the kernel starts executing
    // We'll use this function to initialize the kernel and start the scheduler

    const char* message = "Hello World! This is my 64-bit OS!";  // Updated message for 64-bit verification
    print(message);

    // ---------------- VVV For interrupt VVV ---------------- 
    init_idt();             // Initialize the 64-bit IDT
    enable_interrupts();    // Enable CPU interrupts (std instructions)
    // -------------------------------------------------------

    // char* video_memory = (char*)0xB8000;                    
    // (0xB8000): starting address for text mode video memory (this is where the kernel will write characters to be displayed)
    
    // Command Line:
    const char* prompt = "os-shell$ ";
    char command[256];

    //-------------------------------------------------------------------

    // Keep the CPU running indefinitely:
    while (true) {              // Necessary since the kernel is responsible for managing the CPU and keeping it busy.
        print(prompt);          // print the shell prompt
        read_input(command);    // Function to read user input

        print("\nYou typed: ");
        print(command);
        print("\n");

        if (strcmp(command, "exit") == 0) {
            break;              // Exit the shell loop (stopping the kernel)
        }
        else if (strcmp(command, "clear") == 0) {
            clear_screen();     // Clear the screen
        }
        else if (strncmp(command, "echo ", 5) == 0) {  
            if (command[5] == '\0') {
                print("Error: No text provided for echo command.");
            } else {
                print(command + 5);
            }
        }

        else {
            print("Unknown command: ");     // Print an error message if the command is unknown
            print(command);                 // Print the command that was entered
        }
    }

    // After exiting shell loop, prevent execution of unintended memory
    while (true) { 
        __asm__("hlt");  // Halt the CPU to prevent crashes when kernel exits
    }
}
