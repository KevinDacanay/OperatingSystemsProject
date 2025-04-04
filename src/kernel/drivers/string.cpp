// # include "drivers/string.h"

// int strcmp(const char* str1, const char* str2) {
//     while (*str1 && (*str1 == *str2)) {
//         str1++;
//         str2++;
//     }
//     return (unsigned char)*str1 - (unsigned char)*str2;
// }

// int strncmp(const char* str1, const char* str2, size_t n) {
//     while (n-- && *str1 && (*str1 == *str2)) {
//         str1++;
//         str2++;
//     }
//     return (n == (size_t)-1) ? 0 : (unsigned char)*str1 - (unsigned char)*str2;
// }

#include "string.h"

// Compare two strings (case-sensitive)
int strcmp(const char* str1, const char* str2) {
    while (*str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return (unsigned char)*str1 - (unsigned char)*str2;
}

// Compare first n characters of two strings
int strncmp(const char* str1, const char* str2, size_t n) {
    while (n-- && *str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return (n == (size_t)-1) ? 0 : (unsigned char)*str1 - (unsigned char)*str2;
}
