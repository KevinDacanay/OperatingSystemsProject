// // drivers/keyboard.c
// #include "drivers/keyboard.h"
// #include "drivers/ports.h"
// #include "drivers/video.h"

// // Scancode to ASCII mapping
// const char scancode_to_ascii[] = {
//     0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
//     '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
//     0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\',
//     'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' ', 0
// };

// // Flag to indicate whether there is input available from the keyboard
// bool keyboard_input_available = false;

// // Key code of the next key press
// uint8_t keyboard_key_code = 0;

// // Function to check if there is input available from the keyboard
// bool keyboard_has_input(void) {
//     return keyboard_input_available;
// }

// // Function to get the key code of the next key press
// uint8_t keyboard_get_key_code(void) {
//     keyboard_input_available = false;
//     return keyboard_key_code;
// }

// // Function to convert a key code to a character
// char keyboard_get_character(uint8_t key_code) {
//     return scancode_to_ascii[key_code];
// }

// // Function to handle keyboard interrupts
// void keyboard_handler(void) {
//     // Read the key code from the keyboard port
//     uint8_t key_code = inb(0x60);

//     // Check if the key is a character key
//     if (key_code & 0x80) {
//         // Ignore key releases
//         return;
//     }

//     // Set the flag to indicate that there is input available from the keyboard
//     keyboard_input_available = true;

//     // Store the key code
//     keyboard_key_code = key_code;

//     // Convert the key code to a character and print it
//     char character = keyboard_get_character(key_code);
//     if (character) {
//         video_print_char(character);
//     }
// }

// // Function to initialize the keyboard driver
// void keyboard_init(void) {
//     // Initialize the keyboard driver
//     // This function should be called once during system initialization
// }
#include "keyboard.h"
#include "ports.h"  // To communicate with the hardware ports

#define KEYBOARD_PORT 0x60   // I/O port for keyboard input

void read_input(char* buffer) {
    int i = 0;
    while (1) {
        // Wait for the keyboard input by reading from the keyboard data port
        while ((inb(0x64) & 0x01) == 0);  // Check if data is available
        char scancode = inb(KEYBOARD_PORT);  // Read the scancode

        if (scancode == 0x1C) {  // Enter key (0x1C for standard keyboard)
            buffer[i] = '\0';  // Null-terminate the string
            break;
        } else if (scancode == 0x0E) {  // Backspace key (0x0E for standard keyboard)
            if (i > 0) {
                i--;
            }
        } else {
            buffer[i++] = scancode;  // Store the character
        }
    }
}
