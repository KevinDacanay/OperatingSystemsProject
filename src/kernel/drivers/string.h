// #ifndef STRING_H
// #define STRING_H

// typedef unsigned int size_t;

// int strcmp(const char* str1, const char* str2);
// int strncmp(const char* str1, const char* str2, size_t n);

// #endif
#ifndef STRING_H
#define STRING_H

// Define size_t as unsigned long if not already defined
typedef unsigned long size_t;

int strcmp(const char* str1, const char* str2);
int strncmp(const char* str1, const char* str2, size_t n);

#endif // STRING_H
