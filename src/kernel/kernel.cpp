#include "drivers/video.h"
#include "drivers/keyboard.h"
#include "drivers/string.h"
#include "drivers/ports.h"

// extern "C": tells the compiler to use C linkage for the function
extern "C" void kernel_main() {
    // kernel_main is the entry point of the kernel, it's called by the bootloader
    // This is where the kernel starts executing
    // We'll use this function to initialize the kernel and start the scheduler
 
    const char* message = "Hello World! This is my OS!";    // A constant char pointer that points to the string "Hello World! ..."
    print(message);

    // char* video_memory = (char*)0xB8000;                    // A char pointer that points to the starting address of the text mode video memory
    // (0xB8000): starting address for text mode video memory (this is where the kernel will write characters to be displayed)
    
    // Command Line:
    const char* prompt = "os-shell$";

    char command[256];
    //-------------------------------------------------------------------

    // Keep the CPU running indefinitely:
    while (true) {              // Necessary since the kernel is responsible for managing the CPU and keeping it busy.
        read_input(command);    // Function to read user input
        print(prompt);          // print the shell prompt

        if (strcmp(command, "exit") == 0) {
            break;              // Exit the shell loop (stopping the kernel)
        }
        else if (strcmp(command, "clear") == 0) {
            clear_screen();     // Clear the screen
        }
        
        // FIX THISSSvvvvvvvvvvvvvvvvvvvvvvvvvv
        else if (strcmp(command, "echo") == 0) {
            print(command + 5);  // Print the command after "echo "
        }
        // FIX THISSS^^^^^^^^^^^^^^^^^^^^^^^^^^


        else {
            print("Unknown command: ");  // Print an error message if the command is unknown
        }
    }
}