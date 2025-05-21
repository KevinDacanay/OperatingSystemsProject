/* 
The bootloader will look at this image and start execution at the symbol 
designated as the entry point
*/
ENTRY(_start)

/*
Tell where the various sections of the object files will be put in the final
kernel image
*/
SECTIONS {
    /* It used to be universally recommended to use 1M as a start offset, as 
       it was effectively guaranteed to be available under BIOS systems. However, 
       UEFI made things more complicated and experimental data strongly suggests 
       that 2M is a safer place to load. 
       A new feature was introduced to multiboot2 spec to inform bootloaders that
       a kernel can be loaded anywhere within a range of addresses and will be able
       to relocate itself to run from such a bootloader-selected address, in order
       to give the loader freedom in selecting a span of memory which is verified
       to be available by the firmware.
    */
    . = 2M;

    /* First put the multiboot header since it's required to be put very early in
       the image or the bootloader won't recognize the file format. 
    */
    .text BLOCK(4K) : ALIGN(4K) 
    {
        *(.multiboot)
        *(.text)
    }
    /* Read-only data */
    .rodata BLOCK(4K) : ALIGN(4K) 
    {
        *(.rodata)
    }
    /* Read-write data (initialized) */
    .data BLOCK(4K) : ALIGN(4K) 
    {
        *(.data)
    }
    /* Read-write data (uninitialized) and stack */
    .bss BLOCK(4K) : ALIGN(4K) 
    {
        *(COMMON)
        *(.bss)
    }
    /* 
    The compiler may produce other sections, by default it will put them in a 
    segment with the same name. 
    !!! ADD STUFF HERE IF NEEDED !!!
    */

}