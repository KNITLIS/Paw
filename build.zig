const std = @import("std");

pub fn build(b: *std.Build) void {
    const kernel_target = b.standardTargetOptions(.{ .default_target = .{ .os_tag = .freestanding, .cpu_arch = .x86_64 } });
    const optimize = b.standardOptimizeOption(.{});

    const boot_object = b.addObject(.{ .name = "bootloader", .target = kernel_target });
    boot_object.addAssemblyFile(b.path("src/bootloader.s"));
    boot_object.entry = .disabled;

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = kernel_target,
        .optimize = optimize,
    });

    exe_mod.addObject(boot_object);

    const kernel = b.addExecutable(.{ .name = "kernel", .root_module = exe_mod });
    kernel.linker_script = b.path("src/link_kernel.ld");
    b.installArtifact(kernel);
}
