/*We are doing a Freestanding version of CPP, meaning there is no C standard library,
only what we provide ourselves. But some header files aren't actually part of the C stdlib
but rather the compiler; such as <stdbool.h>, <stddef.h>, <stdint.h>, <float.h>, etc...
*/

/*
This kernel uses VGA text mode buffer (0xB8000) as output. It sets up a simple driver that 
remembers the location of the next character in this buffer and provides a primitive for 
adding a new character. 
... there is no support for line breaks ('\n) and writing the character will show some VGA-
    specific character instead. 
    !!! IMPLEMENT THIS
... there is no support for scrolling when the screen is filled up.   
    !!! IMPLEMENT THIS
(NOTE: VGA text mode is deprecated on newer machines and UEFI only supports pixel buffer)
*/

/*
For forward compatibility you might want to start with that. Ask GRUB to set up a framebuffer 
using appropriate Multiboot flags or call VESA VBE yourself. Unlike VGA text mode, a framebuffer 
has pixels, so you have to draw each glyph yourself. This means you'll need a different 
terminal_putchar, and you'll need a font (bitmap images for each character).
*/

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// Check if the compiler thinks we're targeting the wrong OS
#if defined(__linuux__)
#error "You are not using a cross-compiler, error ahead."
#endif

// This kernel will only work for 32-bit ix86 targets.
#if !defined(__i386__)
#error "This kernel needs to be compiled with an ix86-elf compiler."
#endif

// Hardware text mode color coonstants:
enum vga_color {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
};

static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) {
    return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
    return (uint16_t) uc | (uint16_t) color << 8;
}

size_t strlen(const char *str) {
    size_t len = 0;
    while (str[len]) {
        len++;
    }
    return len;
}

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_MEMORY 0xB8000

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer = (uint16_t*)VGA_MEMORY;

void terminal_initialize(void) {
    terminal_row = 0;
    terminal_column = 0;
    terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);

    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            const size_t index = y * VGA_WIDTH + x;
            terminal_buffer[index] = vga_entry(' ', terminal_color);
        }
    }
}

void terminal_setcolor(uint8_t color) {
    terminal_color = color;
}

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) {
    const size_t index = y * VGA_WIDTH + x;
    terminal_buffer[index] = vga_entry(c, color);
}

void terminal_putchar(char c) {
    terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
    if (++terminal_column == VGA_WIDTH) {
        terminal_column = 0;
        if (++terminal_row == VGA_HEIGHT) {
            terminal_row = 0;
        }
    }
}

void terminal_write(const char* data, size_t size) {
    for (size_t i = 0; i < size; i++) {
        terminal_putchar(data[i]);
    }
}

void terminal_writestring(const char* data) {
    terminal_write(data, strlen(data));
}

extern "C" void kernel_main() {
    // Initialize terminal interface:
    terminal_initialize();
    
    // !!! DO NEWLINE FUNCTION !!!
    terminal_writestring("Hello, kernel World!!!\n");
}