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

const isit = @import("isit.zig");
const cartesian = @import("cartesian.zig");

const config = @import("config.zig");
const Config = config.Config;
const CoordinateSystem = config.CoordinateSystem;
const FaceOrientations = config.FaceOrientations;

const util_mod = @import("util");

const enum_table = util_mod.enum_table;
const EnumTable = enum_table.EnumTable;
const PassBy = enum_table.PassBy;

const axis_mod = @import("axis.zig");
const axial_mod = @import("axial.zig");
const face_mod = @import("face.zig");

// ========================================
//              +--------+            ^
//             /|       /|           /
//            / |UP    / |          /
//           +--------+  |       Forward
//           |  +-----|--+      Backward
//     Left  | /      | /Right   /
//           |/       |/        /
//           +--------+        v
//              DOWN
// ========================================

pub fn Rotation(cfg: Config) type {
    // const Axis = axis_mod.Axis(cfg);
    // const Axial = axial_mod.Axial(cfg);
    const Face = face_mod.Face(cfg);
    const util = struct {
        // The discriminants are dependent on the configuration, so this function is used
        // to ensure the correct discriminant is assigned.
        pub fn disc(face: Face, angle: u2) u8 {
            return (@as(u8, @intFromEnum(face)) << 2) | @as(u8, angle);
        }

        pub fn rotateWorldFace(world: Face, up: Face, angle: u2) Face {
            switch (cfg.face_orientations.up) {
                .forward => {
                    return switch (world) {
                        .up => up,
                        .forward => up.getUpAtAngle(angle),
                        .left => up.getLeftAtAngle(angle),
                        .backward => up.getDownAtAngle(angle),
                        .right => up.getRightAtAngle(angle),
                        .down => up.invert(),
                    };
                },
                .left => {
                    return switch (world) {
                        .up => up,
                        .forward => up.getRightAtAngle(angle),
                        .left => up.getUpAtAngle(angle),
                        .backward => up.getLeftAtAngle(angle),
                        .right => up.getDownAtAngle(angle),
                        .down => up.invert(),
                    };
                },
                .backward => {
                    return switch (world) {
                        .up => up,
                        .forward => up.getDownAtAngle(angle),
                        .left => up.getRightAtAngle(angle),
                        .backward => up.getUpAtAngle(angle),
                        .right => up.getLeftAtAngle(angle),
                        .down => up.invert(),
                    };
                },
                .right => {
                    return switch (world) {
                        .up => up,
                        .forward => up.getLeftAtAngle(angle),
                        .left => up.getDownAtAngle(angle),
                        .backward => up.getRightAtAngle(angle),
                        .right => up.getUpAtAngle(angle),
                        .down => up.invert(),
                    };
                },
                else => unreachable,
            }
        }
    };
    return enum(u8) {
        const Self = @This();

        up0 = util.disc(.up, 0),
        up1 = util.disc(.up, 1),
        up2 = util.disc(.up, 2),
        up3 = util.disc(.up, 3),

        forward0 = util.disc(.forward, 0),
        forward1 = util.disc(.forward, 1),
        forward2 = util.disc(.forward, 2),
        forward3 = util.disc(.forward, 3),

        left0 = util.disc(.left, 0),
        left1 = util.disc(.left, 1),
        left2 = util.disc(.left, 2),
        left3 = util.disc(.left, 3),

        backward0 = util.disc(.backward, 0),
        backward1 = util.disc(.backward, 1),
        backward2 = util.disc(.backward, 2),
        backward3 = util.disc(.backward, 3),

        right0 = util.disc(.right, 0),
        right1 = util.disc(.right, 1),
        right2 = util.disc(.right, 2),
        right3 = util.disc(.right, 3),

        down0 = util.disc(.down, 0),
        down1 = util.disc(.down, 1),
        down2 = util.disc(.down, 2),
        down3 = util.disc(.down, 3),

        pub const nx0: Self = .init(.neg_x, 0);
        pub const nx1: Self = .init(.neg_x, 1);
        pub const nx2: Self = .init(.neg_x, 2);
        pub const nx3: Self = .init(.neg_x, 3);

        pub const ny0: Self = .init(.neg_y, 0);
        pub const ny1: Self = .init(.neg_y, 1);
        pub const ny2: Self = .init(.neg_y, 2);
        pub const ny3: Self = .init(.neg_y, 3);

        pub const nz0: Self = .init(.neg_z, 0);
        pub const nz1: Self = .init(.neg_z, 1);
        pub const nz2: Self = .init(.neg_z, 2);
        pub const nz3: Self = .init(.neg_z, 3);

        pub const px0: Self = .init(.pos_x, 0);
        pub const px1: Self = .init(.pos_x, 1);
        pub const px2: Self = .init(.pos_x, 2);
        pub const px3: Self = .init(.pos_x, 3);

        pub const pz0: Self = .init(.pos_z, 0);
        pub const pz1: Self = .init(.pos_z, 1);
        pub const pz2: Self = .init(.pos_z, 2);
        pub const pz3: Self = .init(.pos_z, 3);

        pub inline fn init(up: Face, angle: u2) Self {
            @setRuntimeSafety(false);
            return @enumFromInt((@as(u8, @intFromEnum(up)) << 2) | @as(u8, angle));
        }

        pub const IDENTITY: Self = @enumFromInt(0);
        pub const MIN: Self = @enumFromInt(0);
        pub const MAX: Self = @enumFromInt(23);

        pub const UP: Self = .up0;
        pub const FORWARD: Self = .forward0;
        pub const LEFT: Self = .left0;
        pub const BACKWARD: Self = .backward0;
        pub const RIGHT: Self = .right0;
        pub const DOWN: Self = .down0;

        pub const NEG_X: Self = .init(.neg_x, 0);
        pub const NEG_Y: Self = .init(.neg_y, 0);
        pub const NEG_Z: Self = .init(.neg_z, 0);
        pub const POS_X: Self = .init(.pos_x, 0);
        pub const POS_Y: Self = .init(.pos_y, 0);
        pub const POS_Z: Self = .init(.pos_z, 0);

        pub inline fn Table(comptime T: type, comptime pass_by: PassBy) type {
            return EnumTable(Self, T, pass_by);
        }

        pub const Iter = RotationIter(cfg);
        pub inline fn iter() Iter {
            return .{};
        }

        pub const CartesianIter = cartesian.CartesianEnumIter(Self).Iter;

        pub inline fn cartesianProduct(comptime cols: usize) CartesianIter(cols) {
            return .init();
        }

        pub inline fn getUp(self: Self) Face {
            @setRuntimeSafety(false);
            return @enumFromInt(@intFromEnum(self) >> 2);
        }

        pub inline fn getAngle(self: Self) u2 {
            @setRuntimeSafety(false);
            return @as(u2, @as(u8, @intFromEnum(self)) & 0b11);
        }

        pub inline fn asU8(self: Self) u8 {
            return @intFromEnum(self);
        }

        const FACE_DEST_TABLE: RotationFaceTable(cfg, Face, .value) = blk: {
            var table: RotationFaceTable(cfg, Face, .value) = undefined;
            @setEvalBranchQuota(10000);
            for (0..24) |rot_i| {
                const rot: Self = @enumFromInt(rot_i);
                for (0..6) |face_i| {
                    const face: Face = @enumFromInt(face_i);
                    table.set(rot, face, util.rotateWorldFace(face, rot.getUp(), rot.getAngle()));
                }
            }
            break :blk table;
        };
        pub inline fn faceDest(self: Self, face: Face) Face {
            return FACE_DEST_TABLE.get(self, face);
        }

        const FACE_SOURCE_TABLE: RotationFaceTable(cfg, Face, .value) = blk: {
            var table: RotationFaceTable(cfg, Face, .value) = undefined;
            @setEvalBranchQuota(10000);
            for (0..24) |rot_i| {
                const rot: Self = @enumFromInt(rot_i);
                for (0..6) |face_i| {
                    const face: Face = @enumFromInt(face_i);
                    table.set(rot, util.rotateWorldFace(face, rot.getUp(), rot.getAngle()), face);
                }
            }
            break :blk table;
        };
        pub inline fn faceSrc(self: Self, face: Face) Face {
            return FACE_SOURCE_TABLE.get(self, face);
        }

        
    };
}

// =============================================================================================
// ==== OTHER STUFF ============================================================================
// =============================================================================================

pub const RotCycleCount = enum(u8) {
    const Self = @This();

    c1 = 1,
    c2 = 2,
    c3 = 3,
    c4 = 4,

    pub inline fn count(self: Self) u8 {
        return @intFromEnum(self);
    }
};

pub const RotAnglesKind = enum(u8) {
    identity = 0,
    binary = 1,
    ternary = 2,
    quaternary = 3,
};

pub fn RotAngles(comptime cfg: Config) type {
    const Rot = Rotation(cfg);
    const Values = extern union {
        identity: Rot,
        binary: [1]Rot,
        ternary: [2]Rot,
        Quaternary: [3]Rot,
    };
    return extern struct {
        values: Values,
        tag: RotAnglesKind,
    };
}

fn RotationCayleyInner(comptime cfg: Config, comptime T: type, comptime pass_by: PassBy) type {
    const Rot = Rotation(cfg);
    return extern struct {
        const Self = @This();

        table: EnumTable(Rot, T, pass_by) align(
            // aligned is more slightly more performant, but takes up more memory.
            std.math.ceilPowerOfTwo(usize, @alignOf(T) * 24)
        ),
    };
}

pub fn RotationCayley(comptime cfg: Config, comptime T: type, comptime pass_by: PassBy) type {
    const Rot = Rotation(cfg);
    // EnumTable(Rot, RotationCayleyInner(cfg, T, pass_by), .ref);
    return extern struct {
        const Self = @This();
        
        table: EnumTable(Rot, RotationCayleyInner(cfg, T, pass_by), .ref),

        pub inline fn get(self: *Self, lhs: Rot, rhs: Rot) pass_by.Const(T) {
            return self.table.get(lhs).table.get(rhs);
        }

        pub inline fn set(self: *Self, lhs: Rot, rhs: Rot, value: T) void {
            self.table.getMut(lhs).table.set(rhs, value);
        }
    };
}

fn InnerFaceTable(comptime cfg: Config, comptime T: type, comptime pass_by: PassBy) type {
    const Face = face_mod.Face(cfg);
    return extern struct {
        const Self = @This();

        faces: EnumTable(Face, T, pass_by) align(
            std.math.ceilPowerOfTwo(usize, @alignOf(T) * 6) catch unreachable
        ),
    };
}

pub fn RotationFaceTable(comptime cfg: Config, comptime T: type, comptime pass_by: PassBy) type {
    const Rot = Rotation(cfg);
    const Face = face_mod.Face(cfg);
    return extern struct {
        const Self = @This();
        
        table: EnumTable(Rot, InnerFaceTable(cfg, T, pass_by), .ref),

        pub inline fn get(self: *const Self, rot: Rot, face: Face) pass_by.Const(T) {
            return self.table.get(rot).faces.get(face);
        }

        pub inline fn set(self: *Self, rot: Rot, face: Face, value: T) void {
            self.table.getMut(rot).faces.set(face, value);
        }
    };
}

pub fn RotationIter(comptime cfg: Config) type {
    const Rot = Rotation(cfg);
    return extern struct {
        const Self = @This();
        index: u8 = 0,

        pub inline fn init() Self {
            return .{};
        }

        pub inline fn exhausted(self: Self) bool {
            return self.index >= 24;
        }

        pub inline fn current(self: *Self) ?Rot {
            if (self.exhausted()) return null;
            @setRuntimeSafety(false);
            return @enumFromInt(self.index);
        }

        pub inline fn next(self: *Self) ?Rot {
            if (self.current()) |rot| {
                self.index += 1;
                return rot;
            }
            return null;
        }
    };
}

pub fn CartesianRotationIter(comptime cfg: Config, comptime cols: comptime_int) type {
    comptime if (cols == 0) {
        @compileError("Must have 1 or more columns.");
    };
    const Rot = Rotation(cfg);
    return extern struct {
        const Self = @This();
        
        pub const Columns = [cols]Rot;
        const InnerColumns = [cols]u8;

        const ColUnion = extern union {
            rots: Columns,
            inner: InnerColumns,
        };
        comptime {
            isit.assertSameSize(Columns, InnerColumns, null);
            isit.assertSameAlign(Columns, InnerColumns, null);
            isit.assertSameSize(Columns, ColUnion, null);
            isit.assertSameAlign(Columns, ColUnion, null);
        }
        
        columns: InnerColumns = @splat(0),

        pub inline fn init() Self {
            return .{};
        }

        pub inline fn exhausted(self: Self) bool {
            return self.columns[0] > 23;
        }

        pub inline fn current(self: Self) ?[cols]Rot {
            if (self.exhausted()) return null;
            const conv: ColUnion = .{.inner = self.columns};
            return conv.rots;
        }

        pub inline fn next(self: *Self) ?[cols]Rot {
            if (self.current()) |result| {
                var i: usize = cols;
                while(true) {
                    i -= 1;
                    if (i == 0 or self.columns[i] < 23) {
                        self.columns[i] += 1;
                        break;
                    }
                    self.columns[i] = 0;
                }
                return result;
            }
            return null;
        }
    };
}
