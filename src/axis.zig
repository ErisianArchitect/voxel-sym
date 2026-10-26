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
const lib_face = @import("face.zig");
const util = @import("util");

const Config = config.Config;
const CoordinateSystem = config.CoordinateSystem;
const FaceOrientations = config.FaceOrientations;
const ProtoFace = config.ProtoFace;

const Prototype = util.proto.Prototype;
const EnumTable = util.enum_table.EnumTable;

const unimplemented = isit.unimplemented;

pub fn Axis(comptime cfg: Config) type {
    return enum(u8) {
        const Self = @This();
        
        x = 0,
        y = 1,
        z = 2,

        pub const CFG: Config = cfg;

        pub fn isOrthoTo(self: Self, other: Self) bool {
            return self != other;
        }
    };
}
