// SPDX-License-Identifier: Apache-2.0
// Copyright © 2026-present Ada F. <https://github.com/ErisianArchitect>
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const std = @import("std");

const Build = std.Build;

const build_tools = @import("build_tools/root.zig");

const project = build_tools.project;

const Project = project.Project;
const Import = project.Import;
const Module = project.Module;
const Imports = project.Imports;
const CheckImports = project.BuildCheckImports;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const proj = Project.init(b);

    var imports = CheckImports(16).init();

    const coreo_dep = b.dependency("coreo", .{});
    const coreo_mod = coreo_dep.module("coreo");

    const voxel_sym_options: Module.CreateOptions = .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    };

    const voxsym_mod = b.addModule("voxel_symmetry", voxel_sym_options);
    const check_voxsym_mod = b.addModule("voxel_symmetry_check", voxel_sym_options);

    imports.connect("voxel_symmetry", voxsym_mod, check_voxsym_mod);

    imports.connectDuped("metaprog", proj.dupedCreateModule(2, .{
        .root_source_file = b.path("src/metaprog/root.zig"),
        .target = target,
        .optimize = optimize,
    }));

    imports.connectDuped("util", proj.dupedCreateModule(2, .{
        .root_source_file = b.path("src/util/root.zig"),
        .target = target,
        .optimize = optimize,
    }));

    const build_opts = b.addOptions();
    const check_opts = b.addOptions();

    build_opts.addOption(bool, "CHECK", false);
    check_opts.addOption(bool, "CHECK", false);
    build_opts.addOption([]const u8, "REPO", "https://github.com/ErisianArchitect/voxel-sym");
    check_opts.addOption([]const u8, "REPO", "https://github.com/ErisianArchitect/voxel-sym");

    imports.addOptions("CFG", build_opts, check_opts);

    imports.addDependency("coreo", coreo_mod, null);

    const exe = b.addExecutable(.{
        .name = "voxel_symmetry",
        .use_lld = true,
        .use_llvm = true,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = imports.build.slice(),
        }),
    });
    b.installArtifact(exe);

    const lib = b.addLibrary(.{
        .name = "voxel_symmetry",
        .use_lld = true,
        .use_llvm = true,
        .root_module = voxsym_mod,
    });
    b.installArtifact(lib);

    const check = b.addLibrary(.{
        .name = "voxel_symmetry_check",
        .use_lld = true,
        .use_llvm = true,
        .root_module = check_voxsym_mod,
    });

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addPassthruArgs();

    const check_step = b.step("check", "Checking without build.");
    check_step.dependOn(&check.step);

    const mod_tests = b.addTest(.{
        .root_module = voxsym_mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);
    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });
    const run_exe_tests = b.addRunArtifact(exe_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
