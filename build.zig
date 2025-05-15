const std = @import("std");

pub fn build(b: *std.Build) void {
    const kernel_target = b.standardTargetOptions(.{ .default_target = .{ .os_tag = .freestanding, .cpu_arch = .x86 } });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = kernel_target,
        .optimize = .Debug,
    });

    const kernel = b.addExecutable(.{ .name = "kernel", .root_module = exe_mod });
    kernel.addAssemblyFile(b.path("src/bootloader.s"));
    kernel.setLinkerScript(b.path("src/link_kernel.ld"));
    b.installArtifact(kernel);
}
