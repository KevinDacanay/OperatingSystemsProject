#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include <kernel/tty.h>
#include "vga.h"

// Constants for VGA screen dimensions and memory base.
static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;
static uint16_t* const VGA_MEMORY = (uint16_t*) 0xB8000;    // memory address of VGA text buffer

// Current cursor position and color state.
static size_t terminal_row;
static size_t terminal_column;
static uint8_t terminal_color;
static uint16_t* terminal_buffer;

// Initializes the terminal buffer and fills it with blank spaces.
void terminal_initialize(void) {
    terminal_row = 0;
    terminal_column = 0;
    terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    terminal_buffer = VGA_MEMORY;

    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            const size_t index = y * VGA_WIDTH + x;
            terminal_buffer[index] = vga_entry(' ', terminal_color);
        }
    }
}

// Changes the current color used for characters.
void terminal_setcolor(uint8_t color) {
    terminal_color = color;
}

// Writes a single character with color to position (x, y).
void terminal_putentryat(unsigned char c, uint8_t color, size_t x, size_t y) {
    const size_t index = y * VGA_WIDTH + x;
    terminal_buffer[index] = vga_entry(c, color);
}

// BROKEN: The original terminal_scroll was invalid — undefined pointer behavior.
// FIXED: Scrolls screen up by one line.
void terminal_scroll() {
    for (size_t y = 1; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            const size_t from = y * VGA_WIDTH + x;
            const size_t to = (y - 1) * VGA_WIDTH + x;
            terminal_buffer[to] = terminal_buffer[from];
        }
    }

    // Clear last line.
    for (size_t x = 0; x < VGA_WIDTH; x++) {
        terminal_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = vga_entry(' ', terminal_color);
    }
}

// BROKEN: Bad pointer math.
// FIXED: Clears the last line using terminal_putentryat.
void terminal_delete_last_line() {
    size_t y = VGA_HEIGHT - 1;
    for (size_t x = 0; x < VGA_WIDTH; x++) {
        terminal_putentryat(' ', terminal_color, x, y);
    }
}

// Puts a character at the current location, handles line wrapping and scrolling.
void terminal_putchar(char c) {
    // Handle special characters like newline (you can expand this to handle more).
    if (c == '\n') {
        terminal_column = 0;
        if (++terminal_row == VGA_HEIGHT) {
            terminal_scroll();
            terminal_row = VGA_HEIGHT - 1;
        }
        return;
    }

    terminal_putentryat((unsigned char)c, terminal_color, terminal_column, terminal_row);
    // Line wrap:
    if (++terminal_column == VGA_WIDTH) {
        terminal_column = 0;
        if (++terminal_row == VGA_HEIGHT) {
            terminal_scroll();
            terminal_row = VGA_HEIGHT - 1;
        }
    }
}

// Writes a block of data to the terminal.
void terminal_write(const char* data, size_t size) {
    for (size_t i = 0; i < size; i++) {
        terminal_putchar(data[i]);
    }
}

// Writes a null-terminated string to the terminal.
void terminal_writestring(const char* data) {
    terminal_write(data, strlen(data));
}

/*
Next Steps:
    - Add support for more control characters: like \r, \t, \b.
    - Implement a hardware cursor update: using VGA I/O ports (0x3D4/0x3D5).
    - Create printf() using variadic arguments.
    - Encapsulate terminal into a class later: when you move toward a C++-style kernel.
    - Implement virtual terminal support: for multitasking/multiprocessing.
*/