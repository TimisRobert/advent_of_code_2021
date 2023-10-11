const std = @import("std");
const readFile = @import("utils.zig").readFile;

fn parseData(allocator: std.mem.Allocator, data: []const u8) ![]const u32 {
    var tokens = std.mem.tokenizeAny(u8, data, "\n");

    var arr = std.ArrayList(u32).init(allocator);

    while (tokens.next()) |token| {
        const integer = try std.fmt.parseInt(u32, token, 10);
        try arr.append(integer);
    }

    return arr.toOwnedSlice();
}

fn countIncreases(numbers: []const u32) u32 {
    var last_value = numbers[0];
    var count: u32 = 0;

    for (numbers[1..]) |number| {
        if (number > last_value) count += 1;
        last_value = number;
    }

    return count;
}

fn sum(numbers: []const u32) u32 {
    var total: u32 = 0;

    for (numbers) |number| {
        total += number;
    }

    return total;
}

fn countIncreasesWindow(numbers: []const u32) u32 {
    var windows = std.mem.window(u32, numbers, 3, 1);

    var last_value = sum(windows.next() orelse return 0);
    var count: u32 = 0;

    while (windows.next()) |window| {
        const total = sum(window);

        if (total > last_value) count += 1;
        last_value = total;
    }

    return count;
}

pub fn solve(allocator: std.mem.Allocator) !void {
    const file = try readFile(allocator, "day1", "real");
    defer allocator.free(file);

    const data = try parseData(allocator, file);
    defer allocator.free(data);

    const one = countIncreases(data);
    const two = countIncreasesWindow(data);

    std.log.info("day1 part one: {}", .{one});
    std.log.info("day1 part two: {}", .{two});
}

test "one" {
    const data = try readFile(std.testing.allocator, "day1", "sample");
    defer std.testing.allocator.free(data);

    const numbers = try parseData(std.testing.allocator, data);
    defer std.testing.allocator.free(numbers);

    const expected: u32 = 7;
    const actual = countIncreases(numbers);

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const data = try readFile(std.testing.allocator, "day1", "sample");
    defer std.testing.allocator.free(data);

    const numbers = try parseData(std.testing.allocator, data);
    defer std.testing.allocator.free(numbers);

    const expected: u32 = 5;
    const actual = countIncreasesWindow(numbers);

    try std.testing.expectEqual(expected, actual);
}
