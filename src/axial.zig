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

const isit = @import("isit.zig");
const config = @import("config.zig");
const face_mod = @import("face.zig");
const axis_mod = @import("axis.zig");
const util = @import("util");

const Config = config.Config;
const CoordinateSystem = config.CoordinateSystem;
const FaceOrientations = config.FaceOrientations;
const ProtoFace = config.ProtoFace;


const Prototype = util.proto.ProtoType;
const EnumTable = util.enum_table.EnumTable;

const unimplemented = isit.unimplemented;

pub fn Axial(comptime cfg: Config) type {
    const Face = face_mod.Face(cfg);
    const Axis = axis_mod.Axis(cfg);
    return enum(u8) {
        const Self = @This();
        pub const PROTOTYPE: Prototype = Prototype.create(.PROTOTYPE, .{@This(), cfg.Marker(.Axial), cfg.Marker(.Face)});
        
        neg_x = @intFromEnum(Face.neg_x),
        neg_y = @intFromEnum(Face.neg_y),
        neg_z = @intFromEnum(Face.neg_z),
        pos_x = @intFromEnum(Face.pos_x),
        pos_y = @intFromEnum(Face.pos_y),
        pos_z = @intFromEnum(Face.pos_z),

        pub inline fn convert(value: anytype) Self {
            comptime PROTOTYPE.assertPrototype(@TypeOf(value));
            @setRuntimeSafety(false);
            return @enumFromInt(@intFromEnum(value));
        }

        pub inline fn axis(self: Self) Axis {
            const TABLE: EnumTable(Self, Axis, .value) = comptime.initFields(.{
                .neg_x = .x,
                .neg_y = .y,
                .neg_z = .z,
                .pos_x = .x,
                .pos_y = .y,
                .pos_z = .z,
            });
            return TABLE.get(self);
        }
    };
}
