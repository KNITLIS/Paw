export fn _kernel_entry() linksection(".kernel_entry") callconv(.naked) noreturn {
    asm volatile (
        \\  movb $'B', %al
        \\  movb $0x0f, %ah
        \\  movw %ax, 0xb8004
    );

    while (true) {
        asm volatile (
            \\cli
            \\hlt
        );
    }
}
