#include "drivers/interrupts.h"
#include "drivers/keyboard.h"
#include "drivers/ports.h"

// Define 'idt' and 'idt_ptr':
IDTEntry idt[IDT_SIZE];
IDTPointer idt_ptr;

extern "C" void keyboard_handler();  // Declared in keyboard.cpp

void set_idt_gate(int num, uint32_t base, uint16_t sel, uint8_t flags) {
    idt[num].base_low = (base & 0xFFFF);
    idt[num].selector = sel;
    idt[num].zero = 0;
    idt[num].type_attr = flags;
    idt[num].base_high = (base >> 16) & 0xFFFF;
}

void load_idt() {
    idt_ptr.limit = (sizeof(IDTEntry) * IDT_SIZE) - 1;
    idt_ptr.base = (uint32_t)&idt;  // Set base address of IDT
    asm volatile("lidtl (%0)" : : "r" (&idt_ptr));  // Load IDT
}

void enable_interrupts() {
    asm volatile("sti");  // Enable interrupts
}

void disable_interrupts() {
    asm volatile("cli");  // Disable interrupts
}

void init_idt() {
    set_idt_gate(33, (uint32_t)keyboard_handler, 0x08, 0x8E);  // IRQ1 (keyboard)
    load_idt();
}
