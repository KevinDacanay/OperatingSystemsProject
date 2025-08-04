/* Declare the entry point symbol.
   The bootloader (e.g., GRUB) will begin execution at this symbol after loading. */
ENTRY(_start)

/* Define the memory layout of the final kernel ELF binary. */
SECTIONS {

    /* Set the starting address of the kernel in memory to 1 MiB (0x100000).
       This is a conventional load address for Multiboot-compliant kernels.
       GRUB typically loads the kernel here. */
    . = 1M;

    /* === .text section ===
       - This will contain code (instructions).
       - The BLOCK(4K) : ALIGN(4K) ensures:
         > Section starts on a 4 KiB page boundary (good for paging and alignment).
         > Useful for MMU or paging-enabled kernels.
    */
    .text BLOCK(4K) : ALIGN(4K) 
    {
        *(.multiboot)   /* Multiboot header must appear early in the image (within 8 KiB). */
        *(.text)        /* All code (.text) from input object files goes here. */
    }

    /* === .rodata section ===
       - Contains read-only data (e.g., C++ string literals, constants).
       - Also aligned to 4 KiB boundaries for potential memory protection (e.g., mark as read-only). */
    .rodata BLOCK(4K) : ALIGN(4K)
    {
        *(.rodata)
    }

    /* === .bss section ===
       - Contains zero-initialized data (e.g., static/global variables set to 0).
       - Includes COMMON symbols (e.g., uninitialized globals).
       - Loader is expected to zero this memory after loading.
       - Also aligned to 4K boundary.
    */
    .bss BLOCK(4K) : ALIGN(4K)
    {
        *(COMMON)
        *(.bss)
    }

    /* === Notes ===
       - Other sections not explicitly mentioned here (like .data or .ctors)
         will be discarded unless you explicitly add them.
       - Can later extend this linker script to include:
         > .data: for initialized global variables
         > .ctors/.dtors: for C++ global constructors/destructors
         > .stack: for the kernel stack if placed in static memory
         > .page_table: for mapping memory manually
    */
}
