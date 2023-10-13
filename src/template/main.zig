const std = @import("std");

const day = "template";
const sampleData = @embedFile("./sample");
const realData = @embedFile("./real");

const Data = struct {
    fn parse(allocator: std.mem.Allocator, data: []const u8) !@This() {
        _ = data;
        _ = allocator;

        return .{};
    }

    fn deinit(self: *@This()) void {
        _ = self;
    }
};

pub fn solve(allocator: std.mem.Allocator) !void {
    var data = try Data.parse(allocator, realData);
    defer data.deinit();

    const one = 0;
    const two = 0;

    std.log.info(day ++ " part one: {}, part two: {}", .{ one, two });
}

test "one" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    const expected: u32 = 0;
    const actual = 0;

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    const expected: u32 = 0;
    const actual = 0;

    try std.testing.expectEqual(expected, actual);
}
