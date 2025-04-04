// #ifndef DRIVERS_KEYBOARD_H
// #define DRIVERS_KEYBOARD_H

// #include <stdbool.h>
// #include <stdint.h>

// // Function to check if there is input available from the keyboard
// bool keyboard_has_input(void);

// // Function to get the key code of the next key press
// uint8_t keyboard_get_key_code(void);

// // Function to convert a key code to a character
// char keyboard_get_character(uint8_t key_code);

// // Function to handle keyboard interrupts
// void keyboard_handler(void);

// #endif  // DRIVERS_KEYBOARD_H

#ifndef KEYBOARD_H
#define KEYBOARD_H

void read_input(char* buffer);

#endif // KEYBOARD_H
