/*
	VGA in text mode works by having a dedicated memory region, usually at 
	physical address 0xB8000, that the VGA hardware directly reads from to 
	display characters on the screen. This memory region is known as the VGA 
	text buffer.
*/

#ifndef ARCH_I386_VGA_H
#define ARCH_I386_VGA_H

#include <stdint.h>

/*
	Each character entry is 2 bytes (16 bits):
		- Byte 0 (bits 0-7): The ASCII code point. This byte specifies the actual character to be displayed (e.g., 'A', 'b', '1', etc.).
		- Byte 1 (bits 8-15): The attribute byte. This byte defines the character's display properties, such as:
			Foreground color (bits 8-11): The color of the character itself.
			Background color (bits 12-14): The color behind the character.
			Blink bit (bit 15): Whether the character should blink. (In some modes, this bit can be repurposed as a fourth background color bit).
*/

// VGA color constants (foreground and background)
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

// Combines foreground and background color into a single byte:
// Lower 4 bits = foreground, upper 4 bits = background.
static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) {
    return fg | bg << 4;
}

// Encodes a character and its color into a 16-bit VGA entry.
static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
	/*
	By combining these two bytes into a single 16-bit word, the 
	CPU can read and write a complete character entry (character 
	and its attributes) to the VGA text buffer in a single operation. 
	This makes drawing text on the screen efficient, especially in 
	the 16-bit real mode environment
	*/
    return (uint16_t) uc | (uint16_t) color << 8;
}

#endif
