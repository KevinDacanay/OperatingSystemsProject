#include "drivers/keyboard.h"
#include "drivers/video.h"
#include "drivers/ports.h"

// Function to read user input
void read_input(char* buffer) {
    int i = 0;
    char c = 0;

    while (true) {
        c = inb(0x60);      // Read from keyboard I/O port

        if (c == '\n') {    // Enter key pressed
            buffer[i] = '\0'; // Null terminate string
            return;
        } else if (c == '\b' && i > 0) {  // Backspace
            i--;
            print("\b ");  // Remove last character
        } else {
            buffer[i++] = c;
            char str[2] = {c, '\0'};
            print(str);  // Print typed character
        }
    }
}
