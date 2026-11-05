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

const cfg: root.Config = .{.coordinate_system = .LH_Y_UP, .face_orientations = .{
    .up = .left,
    .forward = .left,
    .left = .forward,
    .backward = .left,
    .right = .forward,
    .down = .left,
}};

const Face = root.Face(cfg);
const Rot = root.Rotation(cfg);
const CartIter = Rot.CartesianIter;
const Axis = root.Axis(cfg);

fn checkFace(rot: Rot, face: Face, expect: Face) !void {
    try std.testing.expectEqual(expect, rot.faceDest(face));
}

pub fn main(_: std.process.Init) !void {
    const turn: Rot = .right1;
    var rot = Rot.up3;
    try checkFace(rot, .up, .up);
    rot = rot.compose(turn);
    try checkFace(rot, .up, .right);
    rot = rot.compose(turn);
    try checkFace(rot, .up, .down);
    rot = rot.compose(turn);
    try checkFace(rot, .up, .left);
    rot = rot.compose(turn);
    try checkFace(rot, .up, .up);
    try std.testing.expectEqual(Axis.x, Face.neg_x.axis());
    // rot = rot.compose(left_turn);
    // try checkFace(rot, .forward, .left);
    // rot = rot.compose(left_turn);
    // try checkFace(rot, .forward, .backward);
    // rot = rot.compose(left_turn);
    // try checkFace(rot, .forward, .right);
    // rot = rot.compose(left_turn);
    // try checkFace(rot, .forward, .forward);
    
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
