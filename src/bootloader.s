.section .text.bootentry # section name referenced by linker script (src/link_kernel.ld)
.code16

_start:
    movb %dl, bootDisk

    # clear screen
    movw $0x184F, %dx
    xor  %cx, %cx
    movb  $0x07, %bh
    movw  $0x0700, %ax
    int  $0x10

    # hide cursor
    movb $32, %ch
    movb $1, %ah
    int $0x10

    read_kernel:    #load kernel from disk
        movb $2, %ah
        movb sectors_to_load, %al
        movb $0, %ch
        movb $2, %cl
        movb $0, %dh
        movb bootDisk, %dl
        movw $0, %bx
        movw %bx, %es
        movw $0x7e00, %bx
        int $0x13

    jnc read_success

    movb $0x0e, %ah
    lea readErrorMessage, %si
    write_error:
        movb (%si), %al
        testb %al, %al
        jz error_written

        movb $0x0E, %ah
        int $0x10

        inc %si
        jmp write_error
    error_written:

    jmp read_kernel

    read_success:

    # go to 32 bit protected mode
    cli
    lgdt GDT_Descriptor

    movl %cr0, %eax
    orl $1, %eax
    movl %eax, %cr0

    ljmp $CODE_SEG, $start_protected_mode



.text
.code32

.extern _kernel_entry

start_protected_mode:
    jmp _kernel_entry



.data

bootDisk: 
    .byte 0
readErrorMessage: 
    .asciz "Disk read error"

# Segment descriptor https://wiki.osdev.org/Global_Descriptor_Table
# info ||     Limit     |         Base         |            Access byte            |     Limit     |         Flags         |     Base      ||
# size ||     0-15      |         0-23         | P |   DPL   | S | E | DC | RW | A |     16-19     | G | DB | L | Reserved |     24-31     ||
#                                                                                  |  Written as a single byte with Limit  |
#                                                                                  |       being a lower part of it        |

GDT_Start:
    Null_Descriptor:
        .long 0
        .long 0
    Code_descriptor:
        .word 0xFFFF      # limit
        .word 0           # base
        .byte 0
        .byte 0b10011010  # access byte
        .byte 0b11001111  # limit + flags
        .byte 0           # base
    Data_Descriptor:
        .word 0xFFFF      # limit
        .word 0           # base
        .byte 0
        .byte 0b10010010  # access byte
        .byte 0b11001111  # limit + flags
        .byte 0           # base
GDT_End:

GDT_Descriptor:
    .word GDT_End - GDT_Start - 1
    .long GDT_Start

CODE_SEG = Code_descriptor - GDT_Start
DATA_SEG = Data_Descriptor - GDT_Start

sectors_to_load:    #last byte of data segment is filled by linker 
                    #TODO: can overflow byte if kernel grow too big, fix somehow