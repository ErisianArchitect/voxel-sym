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

const config = @import("config.zig");
const util = @import("util");

const Config = config.Config;
const CoordinateSystem = config.CoordinateSystem;
const FaceOrientations = config.FaceOrientations;
const ProtoAxial = config.ProtoAxial;
const ProtoFace = config.ProtoFace;

const Bitmask = util.bitmask.Bitmask;
const EnumTable = util.enum_table.EnumTable;
const PassBy = util.enum_table.PassBy;
const Prototype = util.proto.Prototype;

const isit = @import("isit.zig");
const unimplemented = isit.unimplemented;



const lib_axis = @import("axis.zig");

pub fn Face(cfg: Config) type {
    comptime cfg.verify();
    const Axis = lib_axis.Axis(cfg);
    
    return enum(u8) {
        const Self = @This();
        pub const PROTOTYPE = Prototype.create(.PROTOTYPE, .{@This(), cfg.Marker(.Face), cfg.Marker(.Axial)});
        
        up = 0,
        forward = 1,
        left = 2,
        backward = 3,
        right = 4,
        down = 5,

        pub const neg_x = determineFace(.neg_x);
        pub const neg_y = determineFace(.neg_y);
        pub const neg_z = determineFace(.neg_z);
        pub const pos_x = determineFace(.pos_x);
        pub const pos_y = determineFace(.pos_y);
        pub const pos_z = determineFace(.pos_z);
        
        pub const CFG: Config = cfg;
        pub const CS: CoordinateSystem = cfg.coordinate_system;
        pub const FO: FaceOrientations = cfg.face_orientations;

        pub fn asU8(self: Self) u8 {
            return @intFromEnum(self);
        }

        pub inline fn axis(self: Self) Axis {
            const TABLE: Table(Axis, .value) = comptime .initFields(.{
                .neg_x = .x,
                .neg_y = .y,
                .neg_z = .z,
                .pos_x = .x,
                .pos_y = .y,
                .pos_z = .z,
            });
            return TABLE.get(self);
        }

        pub fn Table(comptime T: type, comptime pass_by: PassBy) type {
            return EnumTable(Self, T, pass_by);
        }

        pub inline fn convert(any: anytype) Self {
            comptime PROTOTYPE.assertPrototypeOf(any);
            @setRuntimeSafety(false);
            return @enumFromInt(@intFromEnum(any));
        }

        pub fn fromProto(proto: ProtoFace) Self {
            return switch (proto) {
                .up => .up,
                .down => .down,
                .left => .left,
                .right => .right,
                .forward => .forward,
                .backward => .backward,
            };
        }

        fn determineFace(comptime proto: ProtoAxial) Self {
            if (CS.right == proto) {
                return .right;
            } else if (CS.right == proto.invert()) {
                return .left;
            } else if (CS.forward == proto) {
                return .forward;
            } else if (CS.forward == proto.invert()) {
                return .backward;
            } else if (CS.up == proto) {
                return .up;
            } else if (CS.up == proto.invert()) {
                return .down;
            } else @compileError("Invalid coordinate system.");
        }

        const AXIAL_NAMES: Table([:0]const u8, .value) = .initPairs(.{
            .{.neg_x, "neg_x"},
            .{.neg_y, "neg_y"},
            .{.neg_z, "neg_z"},
            .{.pos_x, "pos_x"},
            .{.pos_y, "pos_y"},
            .{.pos_z, "pos_z"},
        });
        pub inline fn axialName(self: Self) [:0]const u8 {
            return AXIAL_NAMES.get(self);
        }

        const FACE_NAMES: Table([:0]const u8, .value) = .initPairs(.{
            .{.up, "up"},
            .{.forward, "forward"},
            .{.left, "left"},
            .{.backward, "backward"},
            .{.right, "right"},
            .{.down, "down"},
        });
        pub inline fn faceName(self: Self) [:0]const u8 {
            return FACE_NAMES.get(self);
        }

        const INVERT_TABLE: Table(Self, .value) align(8) = .initPairs(.{
            .{.neg_x, .pos_x},
            .{.neg_y, .pos_y},
            .{.neg_z, .pos_z},
            .{.pos_x, .neg_x},
            .{.pos_y, .neg_y},
            .{.pos_z, .neg_z},
        });
        pub inline fn invert(self: Self) Self {
            return INVERT_TABLE.get(self);
        }

        const UP_FACE_TABLE: Table(Self, .value) = .initFields(.{
            .up = Self.fromProto(FO.getUp(.up)),
            .forward = Self.fromProto(FO.getUp(.forward)),
            .left = Self.fromProto(FO.getUp(.left)),
            .backward = Self.fromProto(FO.getUp(.backward)),
            .right = Self.fromProto(FO.getUp(.right)),
            .down = Self.fromProto(FO.getUp(.down)),
        });
        const DOWN_FACE_TABLE: Table(Self, .value) = UP_FACE_TABLE.map(Self, .value, {}, struct {
            pub inline fn function(_: void, _: Self, face: Self) Self {
                return face.invert();
            }
        }.function);
        const LEFT_FACE_TABLE: Table(Self, .value) = .initFields(.{
            .up = Self.fromProto(FO.getLeft(.up)),
            .left = Self.fromProto(FO.getLeft(.left)),
            .backward = Self.fromProto(FO.getLeft(.backward)),
            .right = Self.fromProto(FO.getLeft(.right)),
            .forward = Self.fromProto(FO.getLeft(.forward)),
            .down = Self.fromProto(FO.getLeft(.down)),
        });
        const RIGHT_FACE_TABLE: Table(Self, .value) = LEFT_FACE_TABLE.map(Self, .value, {}, struct {
            pub inline fn function(_: void, _: Self, face: Self) Self {
                return face.invert();
            }
        }.function);

        const FaceAtAngle = struct {
            up: Table(Self, .value),
            left: Table(Self, .value),
            down: Table(Self, .value),
            right: Table(Self, .value),
        };
        
        fn faceAtAngleTable(table: FaceAtAngle) [4]Table(Self, .value) {
            switch (CFG.coordinate_system.angle_direction) {
                .cw => {
                    return .{
                        table.up,
                        table.right,
                        table.down,
                        table.left,
                    };
                },
                .ccw => {
                    return .{
                        table.up,
                        table.left,
                        table.down,
                        table.right,
                    };
                },
            }
        }

        const UP_AT_ANGLE_TABLE: [4]Table(Self, .value) = faceAtAngleTable(.{
            .up = UP_FACE_TABLE,
            .left = LEFT_FACE_TABLE,
            .down = DOWN_FACE_TABLE,
            .right = RIGHT_FACE_TABLE,
        });
        const LEFT_AT_ANGLE_TABLE: [4]Table(Self, .value) = faceAtAngleTable(.{
            .up = LEFT_FACE_TABLE,
            .left = DOWN_FACE_TABLE,
            .down = RIGHT_FACE_TABLE,
            .right = UP_FACE_TABLE,
        });
        const DOWN_AT_ANGLE_TABLE: [4]Table(Self, .value) = faceAtAngleTable(.{
            .up = DOWN_FACE_TABLE,
            .left = RIGHT_FACE_TABLE,
            .down = UP_FACE_TABLE,
            .right = LEFT_FACE_TABLE,
        });
        const RIGHT_AT_ANGLE_TABLE: [4]Table(Self, .value) = faceAtAngleTable(.{
            .up = RIGHT_FACE_TABLE,
            .left = UP_FACE_TABLE,
            .down = LEFT_FACE_TABLE,
            .right = DOWN_FACE_TABLE,
        });

        pub inline fn getUp(self: Self) Self {
            return UP_FACE_TABLE.get(self);
        }

        pub inline fn getUpAtAngle(self: Self, angle: u2) Self {
            return UP_AT_ANGLE_TABLE[angle].get(self);
        }

        pub inline fn getLeft(self: Self) Self {
            return LEFT_FACE_TABLE.get(self);
        }

        pub inline fn getLeftAtAngle(self: Self, angle: u2) Self {
            return LEFT_AT_ANGLE_TABLE[angle].get(self);
        }

        pub inline fn getDown(self: Self) Self {
            return DOWN_FACE_TABLE.get(self);
        }

        pub inline fn getDownAtAngle(self: Self, angle: u2) Self {
            return DOWN_AT_ANGLE_TABLE[angle].get(self);
        }

        pub inline fn getRight(self: Self) Self {
            return RIGHT_FACE_TABLE.get(self);
        }

        pub inline fn getRightAtAngle(self: Self, angle: u2) Self {
            return RIGHT_AT_ANGLE_TABLE[angle].get(self);
        }

        pub inline fn isNeg(self: Self) bool {
            const MASK: Bitmask(u8) = comptime blk: {
                var mask = Bitmask(u8).init0();
                mask.set(@intFromEnum(Self.neg_x), true);
                mask.set(@intFromEnum(Self.neg_y), true);
                mask.set(@intFromEnum(Self.neg_z), true);
                break :blk mask;
            };
            return MASK.get(@intFromEnum(self));
        }

        pub inline fn isPos(self: Self) bool {
            const MASK: Bitmask(u8) = comptime blk: {
                var mask = Bitmask(u8).init0();
                mask.set(@intFromEnum(Self.pos_x), true);
                mask.set(@intFromEnum(Self.pos_y), true);
                mask.set(@intFromEnum(Self.pos_z), true);
                break :blk mask;
            };
            return MASK.get(@intFromEnum(self));
        }

        pub inline fn invertIf(self: Self, condition: bool) Self {
            const TABLE: [2]Table(Self, .value) = comptime .{
                .initFields(.{
                    .neg_x = .neg_x,
                    .neg_y = .neg_y,
                    .neg_z = .neg_z,
                    .pos_x = .pos_x,
                    .pos_y = .pos_y,
                    .pos_z = .pos_z,
                }),
                .initFields(.{
                    .neg_x = .pos_x,
                    .neg_y = .pos_y,
                    .neg_z = .pos_z,
                    .pos_x = .neg_x,
                    .pos_y = .neg_y,
                    .pos_z = .neg_z,
                }),
            };
            return TABLE[@intFromBool(condition)].get(self);
        }

        pub inline fn toCoord(self: Self, comptime T: type) [3]T {
            const TABLE: Table([3]T, .value) = .initFields(.{
                .neg_x = .{-1, 0, 0},
                .neg_y = .{0, -1, 0},
                .neg_z = .{0, 0, -1},
                .pos_x = .{1, 0, 0},
                .pos_y = .{0, 1, 0},
                .pos_z = .{0, 0, 1},
            });
            return TABLE.get(self);
        }

        pub inline fn isOrthoTo(self: Self, other: Self) bool {
            return self.axis() != other.axis();
        }

        pub const Iter = FaceIter(cfg);

        pub inline fn iter() Iter {
            return .init();
        }
    };
}

pub fn FaceIter(comptime cfg: Config) type {
    return extern struct {
        const Self = @This();

        it: u8 = 0,

        pub inline fn init() Self {
            return .{.it=0};
        }

        pub inline fn exhausted(self: Self) bool {
            return self.it >= 6;
        }

        pub inline fn current(self: Self) ?Face(cfg) {
            if (self.exhausted()) return null;
            @setRuntimeSafety(false);
            return @enumFromInt(self.it);
        }

        pub inline fn next(self: *Self) ?Face(cfg) {
            if (self.current()) |result| {
                self.it += 1;
                return result;
            }
            return null;
        }
    };
}
