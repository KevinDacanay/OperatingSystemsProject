// --- printf.cpp ---
#include <stdio.h>
#include <limits.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>  // for setting errno on error

// Helper function to print a string of given length using putchar()
static bool print(const char* data, size_t length) {
    const unsigned char* bytes = (const unsigned char*) data;
    for (size_t i = 0; i < length; i++) {
        if (putchar(bytes[i]) == EOF) {
            return false;
        }
    }
    return true;
}

// printf: supports %s, %c, and %% format specifiers for now
int printf(const char* restrict format, ...) {
    va_list parameters;
    va_start(parameters, format);

    int written = 0;

    while (*format != '\0') {
        size_t maxrem = INT_MAX - written;

        if (format[0] != '%' || format[1] == '%') {
            if (format[0] == '%') {
                format++;
            }
            size_t amount = 1;
            while (format[amount] && format[amount] != '%') {
                amount++;
            }
            if (maxrem < amount) {
                errno = EOVERFLOW; // set errno to indicate error
                return -1;
            }
            if (!print(format, amount)) {
                errno = EIO;
                return -1;
            }
            format += amount;
            written += amount;
            continue;
        }

        const char* format_begun_at = format++;

        if (*format == 'c') {
            format++;
            char c = (char) va_arg(parameters, int);
            if (!maxrem) {
                errno = EOVERFLOW;
                return -1;
            }
            if (!print(&c, sizeof(c))) {
                errno = EIO;
                return -1;
            }
            written++;
        } else if (*format == 's') {
            format++;
            const char* str = va_arg(parameters, const char*);
            size_t len = strlen(str);
            if (maxrem < len) {
                errno = EOVERFLOW;
                return -1;
            }
            if (!print(str, len)) {
                errno = EIO;
                return -1;
            }
            written += len;
        } else {
            // Unknown format specifier, print as is
            format = format_begun_at;
            size_t len = strlen(format);
            if (maxrem < len) {
                errno = EOVERFLOW;
                return -1;
            }
            if (!print(format, len)) {
                errno = EIO;
                return -1;
            }
            written += len;
            format += len;
        }
    }

    va_end(parameters);
    return written;
}
