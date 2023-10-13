const std = @import("std");

const day = "day7";
const sampleData = @embedFile("./sample");
const realData = @embedFile("./real");

const Data = struct {
    positions: std.ArrayList(u32),

    fn parse(allocator: std.mem.Allocator, data: []const u8) !@This() {
        var tokens = std.mem.tokenizeAny(u8, data, ",\n");

        var positions = std.ArrayList(u32).init(allocator);

        while (tokens.next()) |token| {
            const integer = try std.fmt.parseInt(u32, token, 0);
            try positions.append(integer);
        }

        return .{ .positions = positions };
    }

    fn findMinFuel(self: @This()) u32 {
        var min_fuel: u32 = std.math.maxInt(u32);

        var min_pos: u32 = std.math.maxInt(u32);
        for (self.positions.items) |position| {
            if (position < min_pos) min_pos = position;
        }

        var max_pos: u32 = std.math.minInt(u32);
        for (self.positions.items) |position| {
            if (position > max_pos) max_pos = position;
        }

        for (min_pos..max_pos) |curr_position| {
            var fuel: u64 = 0;

            for (self.positions.items) |position| {
                fuel += @abs(@as(i64, @intCast(curr_position)) - @as(i64, @intCast(position)));
            }

            min_fuel = @min(fuel, min_fuel);
        }

        return min_fuel;
    }

    fn findMinFuelStep(self: @This()) u32 {
        var min_fuel: u32 = std.math.maxInt(u32);

        var min_pos: u32 = std.math.maxInt(u32);
        for (self.positions.items) |position| {
            if (position < min_pos) min_pos = position;
        }

        var max_pos: u32 = std.math.minInt(u32);
        for (self.positions.items) |position| {
            if (position > max_pos) max_pos = position;
        }

        for (min_pos..max_pos) |curr_position| {
            var fuel: u64 = 0;

            for (self.positions.items) |position| {
                const steps = @abs(@as(i64, @intCast(curr_position)) - @as(i64, @intCast(position)));

                var total_fuel: u64 = @divExact((steps * (steps + 1)), 2);

                fuel += total_fuel;
            }

            min_fuel = @min(fuel, min_fuel);
        }

        return min_fuel;
    }

    fn deinit(self: *@This()) void {
        self.positions.deinit();
    }
};

pub fn solve(allocator: std.mem.Allocator) !void {
    var data = try Data.parse(allocator, realData);
    defer data.deinit();

    const one = data.findMinFuel();
    const two = data.findMinFuelStep();

    std.log.info(day ++ " part one: {}, part two: {}", .{ one, two });
}

test "one" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    const expected: u64 = 37;
    const actual = data.findMinFuel();

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    const expected: u64 = 168;
    const actual = data.findMinFuelStep();

    try std.testing.expectEqual(expected, actual);
}
