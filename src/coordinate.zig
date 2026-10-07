
const EnumTable = @import("util/enum_table.zig").EnumTable;

pub const AngleDirection = enum(u8) {
    cw = 0,
    ccw = 1,
};

pub const ProtoAxis = enum(u8) {
    const Self = @This();
    
    x = 0,
    y = 1,
    z = 2,

    const FACES_TABLE: EnumTable(Self, [2]ProtoFace, .value) = .initFields(.{
        .x = .{.neg_x, .pos_x},
        .y = .{.neg_y, .pos_y},
        .z = .{.neg_z, .pos_z},
    });

    pub inline fn faces(self: Self) [2]ProtoFace {
        return FACES_TABLE.get(self);
    }

    pub inline fn isOrthoTo(self: Self, other: Self) Self {
        return self != other;
    }
};

pub const ProtoCardinalAxis = enum(u8) {
    const Self = @This();

    left_right = 0,
    up_down = 1,
    forward_backward = 2,

    pub fn isOrthoTo(self: Self, other: Self) bool {
        return self != other;
    }
};

pub const ProtoFace = enum(u8) {
    const Self = @This();

    up = 0,
    forward = 1,
    left = 2,
    backward = 3,
    right = 4,
    down = 5,

    const INVERT_TABLE: EnumTable(Self, Self, .value) = .initFields(.{
        .up = .down,
        .down = .up,
        .left = .right,
        .right = .left,
        .forward = .backward,
        .backward = .forward,
    });
    pub inline fn invert(self: Self) Self {
        return INVERT_TABLE.get(self);
    }

    const AXIS_TABLE: EnumTable(Self, ProtoCardinalAxis, .value) = .initFields(.{
        .up = .up_down,
        .down = .up_down,
        .left = .left_right,
        .right = .left_right,
        .forward = .forward_backward,
        .backward = .forward_backward,
    });

    pub inline fn axis(self: Self) ProtoCardinalAxis {
        return AXIS_TABLE.get(self);
    }

    pub inline fn isOrthoTo(self: Self, other: Self) bool {
        return self.axis() != other.axis();
    }
};

pub const ProtoAxial = enum(u8) {
    const Self = @This();

    neg_x = 0,
    neg_y = 1,
    neg_z = 2,
    pos_x = 3,
    pos_y = 4,
    pos_z = 5,

    const INVERT_TABLE: EnumTable(Self, Self) = .initFields(.{
        .neg_x = .pos_x,
        .neg_y = .pos_y,
        .neg_z = .pos_z,
        .pos_x = .neg_x,
        .pos_y = .neg_y,
        .pos_z = .neg_z,
    });
    pub inline fn invert(self: Self) Self {
        return INVERT_TABLE.get(self);
    }
};

pub const CoordinateSystem = extern struct {
    right: ProtoAxial = .pos_x,
    up: ProtoAxial = .pos_y,
    forward: ProtoAxial = .pos_z,
    angle_dir: AngleDirection = .cw,
};
