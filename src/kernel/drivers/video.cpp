#include "video.h"
#include "ports.h"

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
//#define VIDEO_MEMORY 0xB8000  

volatile char* video_memory = (char*) VIDEO_MEMORY;
int cursor_x = 0, cursor_y = 0;

// Function to move the cursor
void move_cursor() {
    unsigned short pos = cursor_y * VGA_WIDTH + cursor_x;

    outb(0x3D4, 0x0F);
    outb(0x3D5, (unsigned char)(pos & 0xFF));
    outb(0x3D4, 0x0E);
    outb(0x3D5, (unsigned char)((pos >> 8) & 0xFF));
}

// Function to clear the screen
void clear_screen() {
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        video_memory[i * 2] = ' ';      // Blank space
        video_memory[i * 2 + 1] = 0x07; // White text on black bg
    }
    cursor_x = 0;
    cursor_y = 0;
    move_cursor();
}

// Function to print a single character
void video_print_char(char c) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
    } else if (c == '\b' && cursor_x > 0) {  // Handle backspace
        cursor_x--;
        int pos = (cursor_y * VGA_WIDTH + cursor_x) * 2;
        video_memory[pos] = ' ';
    } else {
        int pos = (cursor_y * VGA_WIDTH + cursor_x) * 2;
        video_memory[pos] = c;
        video_memory[pos + 1] = 0x0F;  // White text on black bg
        cursor_x++;
    }

    if (cursor_x >= VGA_WIDTH) {
        cursor_x = 0;
        cursor_y++;
    }
    
    if (cursor_y >= VGA_HEIGHT) {
        clear_screen();  // Clear screen if overflow
    }

    move_cursor();
}

// Function to print a string
void print(const char* str) {
    while (*str) {
        video_print_char(*str++);
    }
}
