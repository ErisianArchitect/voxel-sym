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
const isit = @import("voxel_symmetry").isit;

const root = @import("voxel_symmetry");

const ProtoFace = root.ProtoFace;

const cfg: root.Config = .{.coordinate_system = .RH_Z_UP, .face_orientations = .{
    .up = .right,
    .forward = .right,
    .left = .backward,
    .backward = .down,
    .right = .forward,
    .down = .right,
}};

const Face = root.Face(cfg);
const Rot = root.Rotation(cfg);
const CartIter = Rot.CartesianIter;

const print = std.debug.print;

pub inline fn println(comptime fmt: []const u8, comptime args: anytype) void {
    print(fmt ++ "\n", args);
}

// const TestExternStruct = extern struct {
//     foo: u32,
//     bar: u64,
//     baz: u8,
// };

// comptime {
//     isit.checks.assertOffsetOfEq(TestExternStruct, .bar, 8, null);
//     // isit.checks.assertOffsetOfEq(TestExternStruct, .bar, 4, null);
// }


comptime {
    std.testing.refAllDecls(root);
}

const Doobie = enum(u8) {
    foo = 2,
    bar = 1,
    baz = 0,
};

const metaprog = @import("metaprog");

pub const RotationCycleCount = packed struct {
    count: u2,
};
comptime {
    isit.assertSameSize(RotationCycleCount, u8, null);
}

pub const Symmetry = packed struct {
    angle: u2,
    up: u5,
    flip: bool,
};
comptime {
    isit.assertSameSize(Symmetry, u8, null);
}

pub fn main(_: std.process.Init) !void {
    // const r = Rot.init(.left, 2);
    // println("{s}", .{@tagName(r.faceDest(.forward))});
    // println("Hello, {s}!", .{"World"});
    const fields = comptime metaprog.enumDiscriminantSortedFields(Doobie);
    inline for (fields) |field| {
        println("{s} = {d}", .{field.name, field.value});
    }
}

test "Quick" {
    const r = Rot.left2;
    try std.testing.expectEqual(r.faceDest(.forward), .forward);
}

test "Rotation Face Associativity" {
    var rot_it = Rot.iter();
    while (rot_it.next()) |rot| {
        var face_it = Face.iter();
        while (face_it.next()) |face| {
            const dest = rot.faceDest(face);
            const src = rot.faceSrc(dest);
            try std.testing.expectEqual(src, face);
        }
    }
}
