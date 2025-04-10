ENTRY(start_stage2)

SECTIONS {
    . = 0x10000;  /* Load address of stage 2 */

    .text : {
        *(.text)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss COMMON)
    }
}
