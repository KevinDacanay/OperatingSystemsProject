ENTRY(kernel_main)

SECTIONS {
    . = 0x10000;  /* Kernel starts at this address */
    .text : {
        *(.text)   /* Include all .text sections here */
    }
    .data : {
        *(.data)
    }
    .bss : {
        *(.bss)
    }
}
