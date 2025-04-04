// #ifndef INTERRUPTS_H
// #define INTERRUPTS_H

// #include <stdint.h>

// struct IDTEntry {
//     uint16_t base_low;
//     uint16_t selector;
//     uint8_t  zero;
//     uint8_t  type_attr;
//     uint16_t base_mid;
//     uint32_t base_high;
//     uint32_t reserved;
// } __attribute__((packed));


// struct IDTPointer {
//     uint16_t limit;
//     uint32_t base;
// } __attribute__((packed));

// #define IDT_SIZE 256
// extern IDTEntry idt[IDT_SIZE];  // Declare global IDT array
// extern IDTPointer idt_ptr;      // Declare global IDT pointer

// void set_idt_gate(int num, uint32_t base, uint16_t sel, uint8_t flags);
// void load_idt();
// void enable_interrupts();
// void disable_interrupts();
// void init_idt();

// #endif  // INTERRUPTS_H
#ifndef INTERRUPTS_H
#define INTERRUPTS_H

void init_idt();
void enable_interrupts();

#endif // INTERRUPTS_H
