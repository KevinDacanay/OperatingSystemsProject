// Include necessary header files for interrupt handling, keyboard input, and port operations
#include "drivers/interrupts.h"
#include "drivers/keyboard.h"
#include "drivers/ports.h"

// Define the IDT (Interrupt Descriptor Table) and IDT pointer
IDTEntry idt[IDT_SIZE];  // Array of IDT entries
IDTPointer idt_ptr;      // Pointer to the IDT

// Declare an external function 'keyboard_handler' that will be linked later
// This function will handle keyboard interrupts
extern "C" void keyboard_handler();  // Declared in keyboard.cpp

/**
 * Set up an IDT gate for a specific interrupt.
 * 
 * @param num   The index of the IDT entry to set up.
 * @param base  The base address of the interrupt handler function.
 * @param sel   The selector (segment register) to use for the interrupt handler.
 * @param flags The flags to set for the IDT entry.
 */
void set_idt_gate(int num, uint64_t base, uint16_t sel, uint8_t flags) {
    // Set up the IDT entry
    idt[num].base_low = (base & 0xFFFF);  // Low 16 bits of the base address
    idt[num].selector = sel;              // Selector (segment register)
    idt[num].zero = 0;                    // Reserved field (must be 0)
    idt[num].type_attr = flags;           // Type and attributes of the IDT entry
    idt[num].base_mid = (base >> 16) & 0xFFFF;  // Middle 16 bits of the base address
    idt[num].base_high = (base >> 32) & 0xFFFFFFFF;  // High 32 bits of the base address
    idt[num].reserved = 0;               // Reserved field (must be 0)
}

/**
 * Load the IDT into the CPU.
 */
void load_idt() {
    // Set up the IDT pointer
    idt_ptr.limit = (sizeof(IDTEntry) * IDT_SIZE) - 1;  // Limit of the IDT (size - 1)
    idt_ptr.base = (uint64_t)&idt;  // Base address of the IDT

    // Load the IDT into the CPU using the 'lidt' instruction
    asm volatile("lidt %0" : : "m" (idt_ptr));  // Use "m" for memory operand in 64-bit
}

/**
 * Enable interrupts on the CPU.
 */
void enable_interrupts() {
    // Enable interrupts using the 'sti' instruction
    asm volatile("sti");  // Enable interrupts
}

/**
 * Disable interrupts on the CPU.
 */
void disable_interrupts() {
    // Disable interrupts using the 'cli' instruction
    asm volatile("cli");  // Disable interrupts
}

/**
 * Initialize the IDT and set up the keyboard interrupt handler.
 */
void init_idt() {
    // Set up the IDT gate for the keyboard interrupt handler
    set_idt_gate(33, (uint64_t)keyboard_handler, 0x08, 0x8E);  // IRQ1 (keyboard)

    // Load the IDT into the CPU
    load_idt();
}