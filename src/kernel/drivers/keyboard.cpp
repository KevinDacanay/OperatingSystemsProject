#include "drivers/keyboard.h"
#include "drivers/video.h"
#include "drivers/ports.h"


#define BUFFER_SIZE 256
char input_buffer[BUFFER_SIZE];  // Buffer for user input
int buffer_index = 0;

// Scancode to ASCII mapping
const char scancode_to_ascii[] = {
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
    '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\',
    'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' ', 0
};

#define PIC_EOI 0x20  // End of Interrupt command for PIC

extern "C" void keyboard_handler() {
    unsigned char keycode = inb(0x60);  // Read key from keyboard port
    if (keycode & 0x80) return;  // Ignore key releases

    char c = scancode_to_ascii[keycode];  // Convert scancode to ASCII
    if (c) {
        if (c == '\n') {  
            // Enter key pressed -> Null-terminate input buffer
            input_buffer[buffer_index] = '\0';
            buffer_index = 0;
            print("\n");
        } 
        else if (c == '\b') {  
            // Backspace key -> Remove last character
            if (buffer_index > 0) {
                buffer_index--;
                print("\b \b");  // Erase character on screen
            }
        } 
        else {  
            // Regular character -> Store and print
            if (buffer_index < BUFFER_SIZE - 1) {
                input_buffer[buffer_index++] = c;
                video_print_char(c);
            }
        }
    }

    outb(0x20, PIC_EOI);  // Send End of Interrupt (EOI) to PIC
}

// Function to read user input (waits until Enter is pressed)
void read_input(char* buffer) {
    while (true) {
        if (buffer_index > 0 && input_buffer[buffer_index - 1] == '\n') {
            input_buffer[buffer_index - 1] = '\0';  // Replace Enter with null terminator
            buffer_index--;     // FIX: reduce index to prevent newline

            // Copy buffered input into output buffer
            for (int i = 0; i < buffer_index; i++) {
                buffer[i] = input_buffer[i];
            }
            buffer_index = 0;  // Reset buffer index
            return;
        }
    }
}
