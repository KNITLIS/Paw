OUTPUT_FORMAT("binary");

SECTIONS
{
    . = 0x7C00;
    .boot : {
        *bootloader.o(.text.bootentry)
    },

    .boot.text : {
        *bootloader.o(.text)
    },

    . = 0x7DFE;
    .sign : {
        SHORT(0xAA55)
    },

    /* End of bootloader, start of kernel*/

    .text : {
        *(.kernel_entry)
        *(.text)
    },

    .rodata : {
        *(.rodata)
    },

    .data : {
        *(.data)
    }
}