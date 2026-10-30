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

const cfg: root.Config = .{.coordinate_system = .RH_Z_UP, .face_orientations = .{
    .up = .left,
    .forward = .left,
    .left = .up,
    .backward = .up,
    .right = .up,
    .down = .forward,
}};

const Face = root.Face(cfg);
const Rot = root.Rotation(cfg);
const CartIter = Rot.CartesianIter;

fn checkFace(comptime rot: Rot, face: Face, expect: Face) !void {
    try std.testing.expectEqual(expect, rot.faceDest(face));
}

// FIXME: This is all kinds of fucked up.
//        [ ]: faceDest/faceSrc is broken.
//             You need to account for not only the orientation of
//             Face.up, but also the orientation of the Up face of
//             the rotation.

pub fn main(_: std.process.Init) !void {
    // const r = Rot.init(.right, 0);
    
    // println("{s}", .{@tagName(Rot.up0.faceDest(.forward))});
    // println("{s}", .{@tagName(r.faceDest(.forward))});
    try checkFace(.forward2, .forward, .up);
    // try checkFace(.up0, .forward, .forward);
    // try checkFace(.up1, .forward, .left);
    // try checkFace(.up2, .forward, .backward);
    // try checkFace(.up3, .forward, .right);
    // try checkFace(.forward0, .forward, .up);
    // try checkFace(.forward0, .left, .right);
    // println("Hello, {s}!", .{"World"});
    // const fields = comptime metaprog.enumDiscriminantSortedFields(Doobie);
    // inline for (fields) |field| {
    //     println("{s} = {d}", .{field.name, field.value});
    // }
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
