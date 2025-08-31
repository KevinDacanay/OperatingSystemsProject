// Returns the number of characters in a null-terminated string 'str', excluding the null byte.

#include <string.h>

size_t strlen(const char* str) {
    size_t len = 0;
    while (str[len]) {
        len++;
    }
    return len;
}
