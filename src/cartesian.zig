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

const metaprog = @import("metaprog");
const isit = @import("isit.zig");

fn fieldCount(comptime T: type) usize {
    return std.meta.fieldNames(T).len;
}

fn ensureEnum(comptime T: type) void {
    const type_info = @typeInfo(T);
    if (type_info != .@"enum") {
        @compileError("Not an enum.");
    }
}

const EnumField = std.builtin.Type.EnumField;

fn enumDiscriminantSortedFields(comptime Enum: type) [fieldCount(Enum)]EnumField {
    comptime ensureEnum(Enum);
    const fields = metaprog.enumFields(Enum);
    const sorted_fields = blk: {
        var field_buf: [fields.len]EnumField = undefined;
        for (fields, 0..) |f, i| {
            field_buf[i] = f;
        }
        std.sort.block(EnumField, &field_buf, {}, struct {
            fn sorter(_: void, lhs: EnumField, rhs: EnumField) bool {
                return lhs.value < rhs.value;
            }
        }.sorter);
        break :blk field_buf;
    };
    return sorted_fields;
}

pub fn CartesianEnumIter(comptime Enum: type) type {
    comptime ensureEnum(Enum);
    const fields = enumDiscriminantSortedFields(Enum);
    const enum_type_info = @typeInfo(Enum);
    const tag_type = enum_type_info.@"enum".tag_type;
    const tag_type_info = @typeInfo(tag_type);
    if (tag_type_info != .int) {
        @compileError("Tag type must be integer type.");
    }
    if (fields.len == 0) {
        @compileError("Expected at least one field.");
    }
    const min_val = fields[0].value;
    const max_val = fields[fields.len - 1].value;
    var prev = min_val;
    for (1..fields.len) |i| {
        if (fields[i].value - prev != 1) {
            @compileError("Non-contiguous enum.");
        }
        prev = fields[i].value;
    }
    return struct {
        pub fn Iter(comptime cols: usize) type {
            comptime if (cols == 0) {
                @compileError("Must have at least one column.");
            };
            return extern struct {
                const Self = @This();

                pub const OutputColumns = [cols]Enum;
                const InputColumns = [cols]tag_type;

                const ColUnion = extern union {
                    output: OutputColumns,
                    input: InputColumns,
                };
                comptime {
                    isit.assertSameSize(OutputColumns, InputColumns, null);
                    isit.assertSameSize(OutputColumns, ColUnion, null);
                    isit.assertSameAlign(OutputColumns, InputColumns, null);
                    isit.assertSameAlign(OutputColumns, ColUnion, null);
                }

                columns: ColUnion,

                pub inline fn init() Self {
                    return .{.columns = .{.input = @splat(min_val)}};
                }

                pub inline fn exhausted(self: Self) bool {
                    return self.columns.input[0] > max_val;
                }

                pub inline fn current(self: Self) ?OutputColumns {
                    if (self.exhausted()) return null;
                    return self.columns.output;
                }

                pub inline fn nextInline(self: *Self) ?OutputColumns {
                    if (self.current()) |result| {
                        var i: usize = cols;
                        while (true) {
                            i -= 1;
                            if (i == 0 or self.columns.input[i] < max_val) {
                                self.columns.input[i] += 1;
                                break;
                            }
                            self.columns.input[i] = min_val;
                        }
                        return result;
                    }
                    return null;
                }

                pub fn next(self: *Self) ?OutputColumns {
                    return self.nextInline();
                }
            };
        }
    };
}

const Fred = enum(u8) {
    foo = 1,
    bar = 2,
    baz = 3,

    pub const CartesianIter = CartesianEnumIter(Fred).Iter;
};

pub fn println(comptime fmt: []const u8, args: anytype) void {
    std.debug.print(fmt ++ "\n", args);
}

pub fn main() void {
    // 3 ^ 4
    var cart = Fred.CartesianIter(4).init();
    while (cart.next()) |elems| {
        println("({s}, {s}, {s}, {s})", .{
            @tagName(elems[0]),
            @tagName(elems[1]),
            @tagName(elems[2]),
            @tagName(elems[3]),
        });
    }
}
