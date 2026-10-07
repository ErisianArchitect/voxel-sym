const std = @import("std");

const root = @import("root.zig");

// const TestExternStruct = extern struct {
//     foo: u32,
//     bar: u64,
//     baz: u8,
// };

// comptime {
//     isit.checks.assertOffsetOfEq(TestExternStruct, .bar, 8, null);
//     // isit.checks.assertOffsetOfEq(TestExternStruct, .bar, 4, null);
// }


comptime {
    std.testing.refAllDecls(root);
}

pub fn main(_: std.process.Init) !void {
    
}
