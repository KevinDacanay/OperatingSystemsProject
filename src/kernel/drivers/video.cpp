#include "video.h"

// Pointer to the VGA text memory (starting at 0xB8000)
volatile char* video_memory = (char*)VIDEO_MEMORY;

// Function to print a string to the screen
void print(const char* str) {
    int i = 0;

    // Iterate over the characters in 'message' variable until it reaches the null terminator '\0'
    while (str[i] != '\0') {
        video_memory[i * 2] = str[i];        // [i * 2]: since each char is two bytes in the video memory 
        // One byte for character code and another for the attribute(color)
        video_memory[i * 2 + 1] = 0x0F;          // 0x0F: sets the attribute byte, representing white color on black background
        i++;
    }
}

// Function to clear the screen
void clear_screen() {
    for (int i = 0; i < 80 * 25; i++) {
        video_memory[i * 2] = ' ';      // set the value at the memory address as a blank space
        video_memory[i * 2 + 1] = 0x07; // set white text on black bg
    }
}