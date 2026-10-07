
const std = @import("std");

const isit = @import("../isit.zig");

pub const BitRange = extern struct {
    const Self = @This();

    _align: void align(8) = {},
    start: u32 = 0,
    end: u32 = 0,

    pub inline fn init(start: u32, end: u32) Self {
        return .{.start = start, .end = end};
    }

    pub inline fn initCount(start: u32, count: u32) Self {
        return Self.init(start, start + count);
    }

    pub inline fn initOne(start: u32) Self {
        return Self.initCount(start, 1);
    }

    pub inline fn len(self: Self) u32 {
        return self.end - self.start;
    }

    pub inline fn isForward(self: Self) bool {
        return self.start <= self.end;
    }

    pub inline fn asInt(self: Self, comptime T: type) T {
        comptime isit.assertSignednessEq(T, .unsigned, null);
        const MAX: T = std.math.maxInt(T);
        const BITLEN: u32 = @bitSizeOf(T);
        return (MAX >> (BITLEN - self.end)) & (MAX << self.start);
    }
};

comptime {
    isit.assertSizeEq(BitRange, 8, null);
    isit.assertAlignEq(BitRange, 8, null);
}

pub fn Bitmask(comptime MaskType: type) type {
    comptime isit.assertSignedness(MaskType, .unsigned, null);

    const Mask = extern struct {
        const Self = @This();
        
        mask: MaskType,

        pub inline fn init(mask: MaskType) Self {
            return .{.mask = mask};
        }

        pub inline fn init_all(all: bool) Self {
            if (all) {
                return Self.init(std.math.maxInt(all));
            } else {
                return Self.init(0);
            }
        }

        pub inline fn init0() Self {
            return Self.init_all(false);
        }

        pub inline fn init1() Self {
            return Self.init_all(false);
        }

        pub inline fn get(self: Self, index: u32) bool {
            return self.mask & (1 << index) != 0;
        }

        pub fn get_range(self: Self, comptime shift: bool, range: BitRange) MaskType {
            if (shift) {
                return (self.mask & range.asInt(MaskType)) >> range.start;
            } else {
                return self.mask & range.asInt(MaskType);
            }
        }

        pub inline fn set(self: *Self, index: u32, value: bool) void {
            if (value) {
                self.mask |= (1 << index);
            } else {
                self.mask &= !(1 << index);
            }
        }
    };
    return Mask;
}

