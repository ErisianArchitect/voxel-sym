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
const coreo = @import("coreo");

const root = @import("voxel_symmetry");
const metaprog = @import("metaprog");

const isit = root.isit;

const ProtoFace = root.ProtoFace;

const print = coreo.debug.print;
const println = coreo.debug.println;
const qprint = coreo.debug.qprint;
const qprintln = coreo.debug.qprintln;

const testing = std.testing;

const expectEq = testing.expectEqual;
const expect = testing.expect;

const cfg: root.Config = .{.coordinate_system = .LH_Y_UP, .face_orientations = .{
    .up = .right,
    .forward = .up,
    .left = .up,
    .backward = .up,
    .right = .forward,
    .down = .backward,
}};

const Face = root.Face(cfg);
const Rot = root.Rotation(cfg);
const CartIter = Rot.CartesianIter;
const Axis = root.Axis(cfg);

fn checkFace(rot: Rot, face: Face, expected: Face) !void {
    try std.testing.expectEqual(expected, rot.faceDest(face));
}

pub fn main(_: std.process.Init) !void {
    const rot: Rot = .right0;
    println("Angle: {d}", .{rot.srcAngle(.right)});
}

test "Face Angle" {
    var rot_it = Rot.iter();
    while (rot_it.next()) |rot| {
        var face_it = Face.iter();
        while (face_it.next()) |face| {
            const src_angle = rot.srcAngle(face);
            const src_face = rot.faceSrc(face);
            const dest_angle = rot.destAngle(src_face);
            try expectEq(src_angle, dest_angle);
        }
    }
}

test "Rotation Compose Associativity" {
    var cart = Rot.cartesianProduct(2);
    while (cart.next()) |r| {
        const lhs = r[0];
        const rhs = r[1];
        {
            const rotated = lhs.compose(rhs);
            const unrotated = rotated.inverseCompose(rhs);
            try expectEq(lhs, unrotated);
        }
    }
}

test "Rotation Face Associativity" {
    var rot_it = Rot.iter();
    while (rot_it.next()) |rot| {
        var face_it = Face.iter();
        while (face_it.next()) |face| {
            const dest = rot.faceDest(face);
            const src = rot.faceSrc(dest);
            try std.testing.expectEqual(face, src);
        }
    }
}
