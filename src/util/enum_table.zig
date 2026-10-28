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

const Align = metaprog.Align;

// const metaprog = @import("metaprog");


inline fn enumIndex(e: anytype) usize {
    return @as(usize, @intFromEnum(e));
}

const EnumField = std.builtin.Type.EnumField;
const StructField = std.builtin.Type.StructField;

pub const PassBy = enum {
    value,
    ref,

    pub fn Const(comptime self: PassBy, comptime T: type) type {
        return switch (self) {
            .value => T,
            .ref => *const T,
        };
    }

    pub fn Mut(comptime self: PassBy, comptime T: type) type {
        return switch (self) {
            .value => T,
            .ref => *T,
        };
    }
};

pub const EnumTableConfig = struct {
    pass_by: PassBy,
    alignment: ?usize = null,
};

pub fn EnumTable(comptime Enum: type, comptime T: type, comptime pass_by: PassBy) type {
    comptime metaprog.ensureEnum(Enum);
    const fields = metaprog.enumDiscriminantSortedFields(Enum);
    const first_disc = fields[0].value;
    var current = first_disc;
    @setEvalBranchQuota(std.math.maxInt(u32));
    for (fields[1..]) |field| {
        if (field.value != current + 1) {
            @compileError("Enum discriminants must be contiguous.");
        }
        current = field.value;
    }
    return extern struct {
        const Self = @This();

        table: [fields.len]T,

        const GetSelf = pass_by.Const(Self);
        const GetMutSelf = pass_by.Mut(Self);
        const GetReturn = pass_by.Const(T);
        const GetMutReturn = pass_by.Mut(T);
        
        pub inline fn init(table: [fields.len]T) Self {
            return .{.table = table};
        }

        pub inline fn undef() Self {
            return Self.init(@splat(undefined));
        }

        pub fn initWith(comptime builder: fn(Enum) T) Self {
            var table = Self.init(undefined);
            @setEvalBranchQuota(std.math.maxInt(u32));
            inline for (std.meta.fieldNames(Enum)) |field_name| {
                const value = @field(Enum, field_name);
                table.set(value, builder(value));
            }
            return table;
        }

        pub const TablePair = struct { Enum, T, };

        pub fn initPairs(pairs: [fields.len]TablePair) Self {
            var table = Self.undef();
            for (pairs) |pair| {
                table.set(pair.@"0", pair.@"1");
            }
            return table;
        }

        pub fn initFields(fields_table: anytype) Self {
            var table = Self.undef();
            @setEvalBranchQuota(std.math.maxInt(u32));
            inline for(std.meta.fieldNames(@TypeOf(fields_table))) |field_name| {
                comptime if (!@hasDecl(Enum, field_name) and !@hasField(Enum, field_name)) {
                    @compileError("initFields: Missing field/decl " ++ field_name ++ " in `" ++ @typeName(Enum) ++ "`.");
                } else if (@TypeOf(@field(Enum, field_name)) != Enum) {
                    @compileError("The " ++ field_name ++ " field is not the correct type.");
                };
                const enum_value = @field(Enum, field_name);
                const field_value = @field(fields_table, field_name);
                table.set(enum_value, field_value);
            }
            return table;
        }

        pub fn map(self: Self, comptime R: type, comptime map_pass_by: PassBy, context: anytype, mapper: anytype) EnumTable(Enum, R, map_pass_by) {
            var table: EnumTable(Enum, R, map_pass_by) = .undef();
            @setEvalBranchQuota(std.math.maxInt(u32));
            inline for (std.meta.fieldNames(Enum)) |field_name| {
                comptime if (@TypeOf(@field(Enum, field_name)) != Enum) {
                    @compileError("The " ++ field_name ++ " field is not the correct type.");
                };
                const enum_value = @field(Enum, field_name);
                table.set(enum_value, mapper(context, enum_value, self.get(enum_value)));
            }
            return table;
        }

        pub inline fn set(self: *Self, item: Enum, value: T) void {
            @setRuntimeSafety(false);
            self.table[enumIndex(item) - first_disc] = value;
        }

        pub inline fn get(self: GetSelf, item: Enum) GetReturn {
            switch (pass_by) {
                .value => {
                    @setRuntimeSafety(false);
                    return self.table[enumIndex(item) - first_disc];
                },
                .ref => {
                    @setRuntimeSafety(false);
                    return &self.table[enumIndex(item) - first_disc];
                },
            }
        }

        pub inline fn getMut(self: GetMutSelf, item: Enum) GetMutReturn {
            switch (pass_by) {
                .value => {
                    @setRuntimeSafety(false);
                    return self.table[enumIndex(item) - first_disc];
                },
                .ref => {
                    @setRuntimeSafety(false);
                    return &self.table[enumIndex(item) - first_disc];
                },
            }
        }
    };
}
