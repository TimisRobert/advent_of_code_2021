const std = @import("std");

const day = "day6";
const sampleData = @embedFile("./sample");
const realData = @embedFile("./real");

const Data = struct {
    const cycle = 9;

    lanternfish: std.ArrayList(u32),
    day_table: [cycle]u64,

    fn parse(allocator: std.mem.Allocator, data: []const u8) !@This() {
        var array = std.ArrayList(u32).init(allocator);

        var tokens = std.mem.tokenizeAny(u8, data, ",\n");
        while (tokens.next()) |token| {
            const integer = try std.fmt.parseInt(u32, token, 0);
            try array.append(integer);
        }

        return .{ .lanternfish = array, .day_table = std.mem.zeroes([cycle]u64) };
    }

    fn simulate(self: *@This(), days: u32) void {
        @memset(&self.day_table, 0);
        for (self.lanternfish.items) |lanternfish| {
            self.day_table[lanternfish] += 1;
        }

        for (0..days) |_| {
            const new_fish = self.day_table[0];

            for (0..cycle - 1) |x| {
                self.day_table[x] = self.day_table[x + 1];
            }

            self.day_table[6] += new_fish;
            self.day_table[8] = new_fish;
        }
    }

    fn count(self: *@This()) u64 {
        var total: u64 = 0;

        for (self.day_table) |lanternfish| {
            total += lanternfish;
        }

        return total;
    }

    fn deinit(self: *@This()) void {
        self.lanternfish.deinit();
    }
};

pub fn solve(allocator: std.mem.Allocator) !void {
    var data = try Data.parse(allocator, realData);
    defer data.deinit();

    data.simulate(80);
    const one = data.count();

    data.simulate(256);
    const two = data.count();

    std.log.info(day ++ " part one: {}, part two: {}", .{ one, two });
}

test "one" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    data.simulate(80);

    const expected: u64 = 5934;
    const actual = data.count();

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    data.simulate(256);

    const expected: u64 = 26_984_457_539;
    const actual = data.count();

    try std.testing.expectEqual(expected, actual);
}

// initial_count
// rem_days = initial - fish    // remaining days
// count = rem_days / 6                 // number of fish created
// initial_count += count
// again
