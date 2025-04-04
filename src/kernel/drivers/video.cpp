// #include "video.h"
// #include "ports.h"

// #define VGA_WIDTH 80
// #define VGA_HEIGHT 25
// //#define VIDEO_MEMORY 0xB8000  

// volatile char* video_memory = (char*) VIDEO_MEMORY;
// int cursor_x = 0, cursor_y = 0;

// // Function to move the cursor
// void move_cursor() {
//     unsigned short pos = cursor_y * VGA_WIDTH + cursor_x;

//     outb(0x3D4, 0x0F);
//     outb(0x3D5, (unsigned char)(pos & 0xFF));
//     outb(0x3D4, 0x0E);
//     outb(0x3D5, (unsigned char)((pos >> 8) & 0xFF));
// }

// // Function to clear the screen
// // For video output (writing to 0xB8000, VGA text mode)
// void print(const char* str) {
//     volatile char* video_memory = (char*)0xB8000;
//     while (*str) {
//         *video_memory = *str++;         // Write char to video memory
//         *(video_memory + 1) = 0x07;     // Set color attribute (white on black)
//         video_memory += 2;              // Move to the next character position
//     }
// }

// // For reading input (basic example for keyboard)
// void read_input(char* buffer) {
//     int i = 0;
//     char c;
//     while (true) {
//         c = get_input();    // Assume get_input() returns a single character
//         if (c == '\n' || c == '\r') {
//             buffer[i] = '\0';  // Null-terminate the string
//             break;
//         }
//         buffer[i++] = c;
//     }
// }

// // Compare strings (you need this for command comparison)
// int strcmp(const char* str1, const char* str2) {
//     while (*str1 && (*str1 == *str2)) {
//         str1++;
//         str2++;
//     }
//     return (unsigned char)*str1 - (unsigned char)*str2;
// }

// // Function to clear the screen (reset video memory to blank)
// void clear_screen() {
//     volatile char* video_memory = (char*)0xB8000;
//     for (int i = 0; i < 80 * 25; i++) {
//         video_memory[2*i] = ' ';  // Blank space
//         video_memory[2*i + 1] = 0x07;  // White on black text
//     }
// }


// // Function to print a single character
// void video_print_char(char c) {
//     if (c == '\n') {
//         cursor_x = 0;
//         cursor_y++;
//     } else if (c == '\b' && cursor_x > 0) {  // Handle backspace
//         cursor_x--;
//         int pos = (cursor_y * VGA_WIDTH + cursor_x) * 2;
//         video_memory[pos] = ' ';
//     } else {
//         int pos = (cursor_y * VGA_WIDTH + cursor_x) * 2;
//         video_memory[pos] = c;
//         video_memory[pos + 1] = 0x0F;  // White text on black bg
//         cursor_x++;
//     }

//     if (cursor_x >= VGA_WIDTH) {
//         cursor_x = 0;
//         cursor_y++;
//     }
    
//     if (cursor_y >= VGA_HEIGHT) {
//         clear_screen();  // Clear screen if overflow
//     }

//     move_cursor();
// }

// // Function to print a string
// void print(const char* str) {
//     volatile char* video_memory = (char*)0xB8000;
//     while (*str) {
//         *video_memory = *str++;         // Write char to video memory
//         *(video_memory + 1) = 0x07;     // Set color attribute (white on black)
//         video_memory += 2;              // Move to next character position
//     }
// }

#include "video.h"

void print(const char* str) {
    volatile char* video_memory = (char*)0xB8000;  // Video memory base address
    while (*str) {
        *video_memory = *str++;         // Write character to video memory
        *(video_memory + 1) = 0x07;     // Set text color to white on black (0x07 is default)
        video_memory += 2;              // Move to the next character position
    }
}

void clear_screen() {
    volatile char* video_memory = (char*)0xB8000;  // Video memory base address
    for (int i = 0; i < 80 * 25; i++) {
        video_memory[2 * i] = ' ';    // Blank space for clearing
        video_memory[2 * i + 1] = 0x07;  // Set color to default
    }
}
