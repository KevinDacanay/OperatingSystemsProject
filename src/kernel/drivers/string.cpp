# include "drivers/string.h"

// Function to compare two strings
int strcmp(const char* str1, const char* str2) {
    // If they are equal, it continues iterating 
    // until it finds a mismatch or reaches the null terminator 
    while (*str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return *(unsigned char*)str1 - *(unsigned char*)str2;
}