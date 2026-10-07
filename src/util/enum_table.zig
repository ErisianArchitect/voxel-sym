
const std = @import("std");

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

pub fn EnumTable(comptime Enum: type, comptime T: type, comptime pass_by: PassBy) type {
    const type_info = @typeInfo(Enum);
    var first_disc: comptime_int = undefined;
    switch (type_info) {
        .@"enum" => {
            const fields = std.meta.fields(Enum);
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
            first_disc = sorted_fields[0].value;
            var current = first_disc;
            for (sorted_fields[1..]) |field| {
                if (field.value != current + 1) {
                    @compileError("Enum discriminants must be contiguous.");
                }
                current = field.value;
            }
            
            const GenericEnumTable = struct {
                const Self = @This();

                table: [fields.len]T,

                const GetSelf = pass_by.Const(Self);
                const GetReturn = pass_by.Const(T);
                
                pub inline fn init(table: [fields.len]T) Self {
                    return .{.table = table};
                }

                pub inline fn undef() Self {
                    return Self.init(@splat(undefined));
                }

                pub fn initWith(comptime builder: fn(Enum) T) Self {
                    var table = Self.init(undefined);
                    inline for (std.meta.fields(Enum)) |field| {
                        table.set(field.value, builder(field.value));
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
                    inline for(std.meta.fields(@TypeOf(fields_table))) |field| {
                        comptime if (!@hasDecl(Enum, field.name) and !@hasField(Enum, field.name)) {
                            @compileError("initFields: Missing field/decl " ++ field.name ++ " in `" ++ @typeName(Enum) ++ "`.");
                        } else if (@TypeOf(@field(Enum, field.name)) != Enum) {
                            @compileError("The " ++ field.name ++ " field is not the correct type.");
                        };
                        const enum_value = @field(Enum, field.name);
                        const field_value = @field(fields_table, field.name);
                        table.set(enum_value, field_value);
                    }
                    return table;
                }

                pub fn map(self: Self, comptime R: type, comptime map_pass_by: PassBy, mapper: *const fn(Enum, GetReturn) R) EnumTable(Enum, R, map_pass_by) {
                    var table: EnumTable(Enum, R, map_pass_by) = .undef();
                    inline for (std.meta.fields(Enum)) |field| {
                        comptime if (@TypeOf(@field(Enum, field.name)) != Enum) {
                            @compileError("The " ++ field.name ++ " field is not the correct type.");
                        };
                        const enum_value = @field(Enum, field.name);
                        table.set(enum_value, mapper(enum_value, self.get(enum_value)));
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
            };
            return GenericEnumTable;
        },
        else => @compileError("Expected enum."),
    }
}
