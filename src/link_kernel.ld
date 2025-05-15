OUTPUT_FORMAT("binary"); /*binary elf64-x86-64*/

EXTERN(_kernel_entry)

SECTIONS
{
    . = 0x7C00;
    .boot : {
        KEEP(*bootloader.o(.text.bootentry))
    },

    .boot.text : {
        KEEP(*bootloader.o(.text))
    },

    .boot.data : {
        KEEP(*bootloader.o(.data))
        BYTE(sectors_to_load)
    },

    . = 0x7DFE;
    .boot.sign : {
        SHORT(0xAA55)
    },

    /* End of bootloader, start of kernel*/
    HIDDEN(_kernel_start = .);

    . = ALIGN(CONSTANT(MAXPAGESIZE));
    .text : {
        KEEP(*(.kernel_entry))
        *(.text .text.*)
    },

    . = ALIGN(CONSTANT(MAXPAGESIZE));
    .rodata : {
        *(.rodata .rodata.*)
    },

    . = ALIGN(CONSTANT(MAXPAGESIZE));
    .data : {
        *(.data .data.*)
    }

    .bss : {
        *(.bss .bss.*)
    }

    HIDDEN(_kernel_end = .);

    /DISCARD/ : {
        *(.debug_info)
        *(.eh_frame*)
        *(.note .note.*)
    }

    HIDDEN(_kernel_size = _kernel_end - _kernel_start);
    HIDDEN(sectors_to_load = (_kernel_size + 511) / 512);
}