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

pub const isit = @import("isit.zig");
pub const cartesian = @import("cartesian.zig");
pub const config = @import("config.zig");
pub const face = @import("face.zig");
pub const rotation = @import("rotation.zig");
pub const axial = @import("axial.zig");
pub const axis = @import("axis.zig");

pub const Config = config.Config;
pub const AngleDirection = config.AngleDirection;
pub const CoordinateSystem = config.CoordinateSystem;
pub const FaceOrientations = config.FaceOrientations;
pub const ProtoFace = config.ProtoFace;
pub const ProtoAxis = config.ProtoAxis;
pub const ProtoAxial = config.ProtoAxial;
pub const ProtoCardinalAxis = config.ProtoCardinalAxis;
pub const Face = face.Face;
pub const Rotation = rotation.Rotation;
pub const CartesianRotationIter = rotation.CartesianRotationIter;
pub const RotationIter = rotation.RotationIter;
pub const Axial = axial.Axial;
pub const Axis = axis.Axis;

comptime {
    std.testing.refAllDecls(isit);
}
