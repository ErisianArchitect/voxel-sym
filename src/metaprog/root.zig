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
const meta = std.meta;
const builtin = std.builtin;
const coreo = @import("coreo");

const root = @import("voxel_symmetry");

const isit = root.isit;

pub fn fieldCount(comptime T: type) usize {
    return std.meta.fieldNames(T).len;
}

pub fn ensureEnum(comptime T: type) void {
    const type_info = @typeInfo(T);
    if (type_info != .@"enum") @compileError("Not an enum.");
}

pub const EnumField = struct {
    name: []const u8,
    value: comptime_int,
};

pub fn enumFields(comptime Enum: type) []const EnumField {
    return comptime blk: {
        const field_count = fieldCount(Enum);
        const names = @typeInfo(Enum).@"enum".field_names;
        const values = @typeInfo(Enum).@"enum".field_values;
        var fields: [field_count]EnumField = undefined;
        for (0..field_count) |i| {
            fields[i] = .{.name = names[i], .value = values[i]};
        }
        break :blk struct {
            const storage = fields;
            const result = &storage;
        }.result;
    };
}

pub fn enumDiscriminantSortedFields(comptime Enum: type) [fieldCount(Enum)]EnumField {
    comptime ensureEnum(Enum);
    const fields: []const EnumField = enumFields(Enum);
    const sorted_fields: [fields.len]EnumField = blk: {
        var field_buf: [fields.len]EnumField = undefined;
        for (fields, 0..) |f, i| {
            field_buf[i] = f;
        }
        @setEvalBranchQuota(fields.len * fields.len * 4);
        std.sort.block(EnumField, &field_buf, {}, struct {
            fn sorter(_: void, lhs: EnumField, rhs: EnumField) bool {
                return lhs.value < rhs.value;
            }
        }.sorter);
        break :blk field_buf;
    };
    return sorted_fields;
}

pub const Align = enum(usize) {
    const Self = @This();

    _1 = 1,
    _2 = 2,
    _4 = 4,
    _8 = 8,
    _16 = 16,
    _32 = 32,
    _64 = 64,
    _128 = 128,
    _256 = 256,
    _512 = 512,
    _1024 = 1024,
    _2048 = 2048,
    _4096 = 4096,
    _8192 = 8192,
    _16384 = 16384,
    _32768 = 32768,
    _65536 = 65536,
    _131072 = 131072,
    _262144 = 262144,
    _524288 = 524288,
    _1048576 = 1048576,
    _2097152 = 2097152,
    _4194304 = 4194304,
    _8388608 = 8388608,
    _16777216 = 16777216,
    _33554432 = 33554432,
    _67108864 = 67108864,
    _134217728 = 134217728,
    _268435456 = 268435456,
    _536870912 = 536870912,
    _1073741824 = 1073741824,
    _2147483648 = 2147483648,

    pub inline fn alignment(self: Self) usize {
        return @intFromEnum(self);
    }
};
