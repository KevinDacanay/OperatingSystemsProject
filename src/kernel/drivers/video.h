#ifndef VIDEO_H
#define VIDEO_H

// Video memory address for text mode:
#define VIDEO_MEMORY (char*)0xB8000  // Correctly define VIDEO_MEMORY here         
// VIDEO_MEMORY: the address where text output in VGA mode is stored (0xB8000)
//               each character is two bytes - the first stores the ASCII value,
//               and the second stores the color (0x07 = whhite text on black bg)

// Function to print a string to the screen:
void print(const char *str);

// Function to clear the screen:
void clear_screen();

void video_print_char(char c);

// Function to read user input 
// extern "C" void read_input(char* buffer);

#endif // VIDEO_H