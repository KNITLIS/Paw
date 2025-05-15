const std = @import("std");

pub fn build(b: *std.Build) void {
    const kernel_target = b.standardTargetOptions(.{ .default_target = .{ .os_tag = .freestanding, .cpu_arch = .x86 } });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = kernel_target,
        .optimize = .Debug,
        // Disable features that are problematic in kernel space.
        .red_zone = false,
        .stack_check = false,
        .stack_protector = false,
    });

    const kernel = b.addExecutable(.{ .name = "kernel", .root_module = exe_mod });
    kernel.pie = false;
    kernel.want_lto = false;
    // Delete unused sections to reduce the kernel size.
    kernel.link_function_sections = true;
    kernel.link_data_sections = true;
    kernel.link_gc_sections = true;
    kernel.link_z_max_page_size = 0x1000;
    kernel.addAssemblyFile(b.path("src/bootloader.s"));
    kernel.setLinkerScript(b.path("src/link_kernel.ld"));
    b.installArtifact(kernel);
}
