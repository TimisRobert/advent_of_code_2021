const std = @import("std");

const day = "template";
const sampleData = @embedFile("./sample");
const realData = @embedFile("./real");

fn parseData(allocator: std.mem.Allocator, data: []const u8) ![]const u32 {
    _ = data;
    _ = allocator;
    return .{};
}

pub fn solve(allocator: std.mem.Allocator) !void {
    const data = try parseData(allocator, realData);
    defer allocator.free(data);

    const one = 0;
    const two = 0;

    std.log.info(day ++ " part one: {}, part two: {}", .{ one, two });
}

test "one" {
    const allocator = std.testing.allocator;
    const data = try parseData(allocator, sampleData);
    defer allocator.free(data);

    const expected: u32 = 0;
    const actual = 0;

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const allocator = std.testing.allocator;
    const data = try parseData(allocator, sampleData);
    defer allocator.free(data);

    const expected: u32 = 0;
    const actual = 0;

    try std.testing.expectEqual(expected, actual);
}
