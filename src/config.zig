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

// const EnumTable = @import("util/enum_table.zig").EnumTable;
const util = @import("util");
const EnumTable = util.enum_table.EnumTable;

pub const AngleDirection = enum(u8) {
    cw = 0,
    ccw = 1,
};

pub const ProtoAxis = enum(u8) {
    const Self = @This();
    
    x = 0,
    y = 1,
    z = 2,

    const FACES_TABLE: EnumTable(Self, [2]ProtoFace, .value) = .initFields(.{
        .x = .{.neg_x, .pos_x},
        .y = .{.neg_y, .pos_y},
        .z = .{.neg_z, .pos_z},
    });

    pub inline fn faces(self: Self) [2]ProtoFace {
        return FACES_TABLE.get(self);
    }

    pub inline fn isOrthoTo(self: Self, other: Self) Self {
        return self != other;
    }
};

pub const ProtoCardinalAxis = enum(u8) {
    const Self = @This();

    left_right = 0,
    up_down = 1,
    forward_backward = 2,

    pub fn isOrthoTo(self: Self, other: Self) bool {
        return self != other;
    }
};

pub const ProtoFace = enum(u8) {
    const Self = @This();

    up = 0,
    forward = 1,
    left = 2,
    backward = 3,
    right = 4,
    down = 5,

    const INVERT_TABLE: EnumTable(Self, Self, .value) = .initFields(.{
        .up = .down,
        .down = .up,
        .left = .right,
        .right = .left,
        .forward = .backward,
        .backward = .forward,
    });
    pub inline fn invert(self: Self) Self {
        return INVERT_TABLE.get(self);
    }

    const AXIS_TABLE: EnumTable(Self, ProtoCardinalAxis, .value) = .initFields(.{
        .up = .up_down,
        .down = .up_down,
        .left = .left_right,
        .right = .left_right,
        .forward = .forward_backward,
        .backward = .forward_backward,
    });

    pub inline fn axis(self: Self) ProtoCardinalAxis {
        return AXIS_TABLE.get(self);
    }

    pub inline fn isOrthoTo(self: Self, other: Self) bool {
        return self.axis() != other.axis();
    }
};

pub const ProtoAxial = enum(u8) {
    const Self = @This();

    neg_x = 0,
    neg_y = 1,
    neg_z = 2,
    pos_x = 3,
    pos_y = 4,
    pos_z = 5,

    const INVERT_TABLE: EnumTable(Self, Self, .value) = .initFields(.{
        .neg_x = .pos_x,
        .neg_y = .pos_y,
        .neg_z = .pos_z,
        .pos_x = .neg_x,
        .pos_y = .neg_y,
        .pos_z = .neg_z,
    });
    pub inline fn invert(self: Self) Self {
        return INVERT_TABLE.get(self);
    }
    const AXIS_TABLE: EnumTable(Self, ProtoAxis, .value) = .initFields(.{
        .neg_x = .x,
        .neg_y = .y,
        .neg_z = .z,
        .pos_x = .x,
        .pos_y = .y,
        .pos_z = .z,
    });
    pub inline fn axis(self: Self) ProtoAxis {
        return AXIS_TABLE.get(self);
    }
};

pub const CoordinateSystem = extern struct {
    const Self = @This();

    right: ProtoAxial = .pos_x,
    up: ProtoAxial = .pos_y,
    forward: ProtoAxial = .pos_z,
    angle_direction: AngleDirection = .cw,

    pub const LH_Y_UP: Self = .{
        .right = .pos_x,
        .up = .pos_y,
        .forward = .pos_z,
        .angle_direction = .cw,
    };
    comptime { Self.verify(LH_Y_UP); }

    pub const LH_Z_UP: Self = .{
        .right = .pos_x,
        .up = .pos_z,
        .forward = .neg_y,
        .angle_direction = .cw,
    };
    comptime { Self.verify(LH_Z_UP); }

    pub const RH_Y_UP: Self = .{
        .right = .pos_x,
        .up = .pos_y,
        .forward = .neg_z,
        .angle_direction = .ccw,
    };
    comptime { Self.verify(RH_Y_UP); }

    pub const RH_Z_UP: Self = .{
        .right = .pos_x,
        .up = .pos_z,
        .forward = .pos_y,
        .angle_direction = .ccw,
    };
    comptime { Self.verify(RH_Z_UP); }

    // # https://learnopengl.com/Getting-started/Coordinate-Systems
    pub const OPENGL: Self = Self.RH_Y_UP;
    // # https://learn.microsoft.com/en-us/windows/win32/direct3d9/coordinate-systems
    pub const DIRECTX: Self = Self.LH_Y_UP;
    // # https://docs.unity3d.com/6000.3/Documentation/ScriptReference/Vector3.html
    pub const UNITY: Self = Self.LH_Y_UP;
    // # https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/model_export_considerations.html
    // # https://docs.godotengine.org/en/4.4/classes/class_vector3.html
    pub const GODOT: Self = Self.RH_Y_UP;
    
    // # https://dev.epicgames.com/documentation/unreal-engine/coordinate-system-and-spaces-in-unreal-engine
    pub const UNREAL: Self = .{
        .right = .pos_y,
        .up = .pos_z,
        .forward = .pos_x,
        .angle_direction = .cw,
    };
    comptime { Self.verify(UNREAL); }

    // # https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#coordinate-system-and-units
    pub const GLTF: Self = .{
        .right = .neg_x,
        .up = .pos_y,
        .forward = .pos_z,
        .angle_direction = .ccw,
    };
    comptime { Self.verify(GLTF); }


    pub fn verify(self: Self) void {
        const right_up = "Coordinate system's right vector's axis conflicts with the up vector's axis.";
        const right_forward = "Coordinate system's right vector's axis conflicts with the forward vector's axis.";
        const up_forward = "Coordinate system's up vector's axis conflicts with the forward vector's axis.";
        if (@inComptime()) {
            if (self.right.axis() == self.up.axis()) {
                @compileError(right_up);
            }
            if (self.right.axis() == self.forward.axis()) {
                @compileError(right_forward);
            }
            if (self.up.axis() == self.forward.axis()) {
                @compileError(up_forward);
            }
        } else {
            if (self.right.axis() == self.up.axis()) {
                @panic(right_up);
            }
            if (self.right.axis() == self.forward.axis()) {
                @panic(right_forward);
            }
            if (self.up.axis() == self.forward.axis()) {
                @panic(up_forward);
            }
        }
    }

    pub fn verified(self: Self) Self {
        self.verify();
        return self;
    }
};

pub const FaceOrientations = extern struct {
    const Self = @This();

    up: ProtoFace = .forward,
    forward: ProtoFace = .up,
    left: ProtoFace = .up,
    backward: ProtoFace = .up,
    right: ProtoFace = .up,
    down: ProtoFace = .forward,

    // The following getter functions don't need to be optimized
    // since they are intended to be used for comptime config.

    pub fn getUp(self: Self, face: ProtoFace) ProtoFace {
        return switch (face) {
            .up => self.up,
            .forward => self.forward,
            .left => self.left,
            .backward => self.backward,
            .right => self.right,
            .down => self.down,
        };
    }

    pub fn getUpAtAngle(
        self: Self,
        comptime angle_dir: AngleDirection,
        face: ProtoFace,
        angle: u2,
    ) ProtoFace {
        return switch (angle_dir) {
            .cw => switch (angle) {
                0 => self.getUp(face),
                1 => self.getRight(face),
                2 => self.getDown(face),
                3 => self.getLeft(face),
            },
            .ccw => switch (angle) {
                0 => self.getUp(face),
                1 => self.getLeft(face),
                2 => self.getDown(face),
                3 => self.getRight(face),
            },
        };
    }

    pub fn getDown(self: Self, face: ProtoFace) ProtoFace {
        self.getUp(face).invert();
    }

    pub fn getDownAtAngle(
        self: Self,
        comptime angle_dir: AngleDirection,
        face: ProtoFace,
        angle: u2,
    ) ProtoFace {
        return self.getUpAtAngle(angle_dir, face, angle).invert();
    }

    fn panicNotOrtho() noreturn {
        @panic("Not orthograpic.");
    }

    pub fn getLeft(self: Self, face: ProtoFace) ProtoFace {
        return switch (face) {
            .up => switch (self.up) {
                .forward => .left,
                .left => .backward,
                .backward => .right,
                .right => .forward,
                else => panicNotOrtho(),
            },
            .forward => switch (self.forward) {
                .up => .right,
                .right => .down,
                .down => .left,
                .left => .up,
                else => panicNotOrtho(),
            },
            .left => switch (self.left) {
                .up => .forward,
                .forward => .down,
                .down => .backward,
                .backward => .up,
                else => panicNotOrtho(),
            },
            .backward => switch (self.backward) {
                .up => .left,
                .left => .down,
                .down => .right,
                .right => .up,
                else => panicNotOrtho(),
            },
            .right => switch (self.right) {
                .up => .backward,
                .backward => .down,
                .down => .forward,
                .forward => .up,
                else => panicNotOrtho(),
            },
            .down => switch (self.down) {
                .forward => .right,
                .right => .backward,
                .backward => .left,
                .left => .forward,
                else => panicNotOrtho(),
            },
        };
    }

    pub fn getLeftAtAngle(
        self: Self,
        comptime angle_dir: AngleDirection,
        face: ProtoFace,
        angle: u2,
    ) ProtoFace {
        return switch (angle_dir) {
            .cw => switch (angle) {
                0 => self.getLeft(face),
                1 => self.getUp(face),
                2 => self.getRight(face),
                3 => self.getDown(face),
            },
            .ccw => switch (angle) {
                0 => self.getLeft(face),
                1 => self.getDown(face),
                2 => self.getRight(face),
                3 => self.getUp(face),
            },
        };
    }

    pub fn getRight(self: Self, face: ProtoFace) ProtoFace {
        return self.getLeft(face).invert();
    }

    pub fn getRightAtAngle(self: Self, comptime angle_dir: AngleDirection, face: ProtoFace, angle: u2) ProtoFace {
        return self.getLeftAtAngle(angle_dir, face, angle).invert();
    }

    fn expectOrtho(lhs: ProtoFace, rhs: ProtoFace, comptime msg: []const u8) void {
        if (lhs.isOrthoTo(rhs))
            return;
        const errmsg = "Axes were not orthogonal: " ++ msg;
        if (@inComptime()) {
            @compileError(errmsg);
        } else {
            @panic(errmsg);
        }
    }

    /// Determines if all of the orientations are orthographic to their axis.
    pub fn isOrtho(self: Self) bool {
        return self.up.isOrthoTo(.up)
        and self.forward.isOrthoTo(.forward)
        and self.left.isOrthoTo(.left)
        and self.backward.isOrthoTo(.backward)
        and self.right.isOrthoTo(.right)
        and self.down.isOrthoTo(.down);
    }

    pub fn verify(self: Self) void {
        comptime {
            expectOrtho(self.up, .up, "up");
            expectOrtho(self.forward, .forward, "forward");
            expectOrtho(self.left, .left, "left");
            expectOrtho(self.backward, .backward, "backward");
            expectOrtho(self.right, .right, "right");
            expectOrtho(self.down, .down, "down");
        }
    }

    pub fn verified(self: Self) Self {
        self.verify();
        return self;
    }
};

pub const Config = struct {
    const Self = @This();

    coordinate_system: CoordinateSystem = .{},
    face_orientations: FaceOrientations = .{},

    pub fn verify(self: Self) void {
        self.coordinate_system.verify();
        self.face_orientations.verify();
    }

    pub fn verified(self: Self) Self {
        self.verify();
        return self;
    }

    pub fn Marker(comptime self: Self, comptime tag: anytype) type {
        return struct {
            pub const COORDINATE_SYSTEM: Self = self;
            pub const TAG = tag;
        };
    }
};
