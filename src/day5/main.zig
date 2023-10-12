const std = @import("std");

const day = "day5";
const sampleData = @embedFile("./sample");
const realData = @embedFile("./real");

const Data = struct {
    arena: std.heap.ArenaAllocator,
    grid: []const []const u32,

    const Point = struct {
        x: u32,
        y: u32,

        fn parse(point: []const u8) !@This() {
            var values = std.mem.tokenizeScalar(u8, point, ',');

            const x_raw = values.next().?;
            const x = try std.fmt.parseInt(u32, x_raw, 0);

            const y_raw = values.next().?;
            const y = try std.fmt.parseInt(u32, y_raw, 0);

            return .{ .x = x, .y = y };
        }
    };

    const Range = struct {
        from: Point,
        to: Point,
        current: ?Point,

        fn parse(range: []const u8) !@This() {
            var values = std.mem.tokenizeSequence(u8, range, " -> ");

            const from_raw = values.next().?;
            const from = try Point.parse(from_raw);

            const to_raw = values.next().?;
            const to = try Point.parse(to_raw);

            return .{ .from = from, .to = to, .current = null };
        }

        fn next(self: *@This()) ?Point {
            if (self.current) |*current| {
                if ((current.x == self.to.x) and (current.y == self.to.y)) {
                    return null;
                }

                if (current.x < self.to.x) {
                    current.x += 1;
                } else if (current.x > self.to.x) {
                    current.x -= 1;
                }

                if (current.y < self.to.y) {
                    current.y += 1;
                } else if (current.y > self.to.y) {
                    current.y -= 1;
                }

                return current.*;
            } else {
                self.current = self.from;
                return self.current;
            }
        }
    };

    fn parse(child_allocator: std.mem.Allocator, data: []const u8, diagonal: bool) !@This() {
        var arena = std.heap.ArenaAllocator.init(child_allocator);
        const allocator = arena.allocator();

        var lines = std.mem.tokenizeScalar(u8, data, '\n');

        var ranges = std.ArrayList(Range).init(allocator);
        defer ranges.deinit();

        var max_x: u32 = 0;
        var max_y: u32 = 0;

        while (lines.next()) |line| {
            const range = try Range.parse(line);

            max_x = @max(range.to.x, max_x) + 1;
            max_y = @max(range.to.y, max_y) + 1;

            try ranges.append(range);
        }

        var grid_array = try std.ArrayList([]u32).initCapacity(allocator, max_y);

        for (0..max_y) |_| {
            var line = try std.ArrayList(u32).initCapacity(allocator, max_x);

            for (0..max_x) |_| {
                try line.append(0);
            }

            try grid_array.append(try line.toOwnedSlice());
        }

        var grid = try grid_array.toOwnedSlice();

        for (ranges.items) |*range| {
            if (!diagonal) {
                if ((range.from.x != range.to.x) and (range.from.y != range.to.y)) continue;
            }

            while (range.next()) |point| {
                grid[point.y][point.x] += 1;
            }
        }

        return .{ .grid = grid, .arena = arena };
    }

    fn countOverlapping(self: @This()) u32 {
        var count: u32 = 0;

        for (self.grid) |line| {
            for (line) |point| {
                if (point > 1) count += 1;
            }
        }

        return count;
    }

    fn deinit(self: *@This()) void {
        self.arena.deinit();
    }
};

pub fn solve(allocator: std.mem.Allocator) !void {
    var data_one = try Data.parse(allocator, realData, false);
    defer data_one.deinit();

    const one = data_one.countOverlapping();

    var data_two = try Data.parse(allocator, realData, true);
    defer data_two.deinit();

    const two = data_two.countOverlapping();

    std.log.info(day ++ " part one: {}, part two: {}", .{ one, two });
}

test "one" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData, false);
    defer data.deinit();

    const actual = data.countOverlapping();
    const expected: u32 = 5;

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData, true);
    defer data.deinit();

    const actual = data.countOverlapping();
    const expected: u32 = 12;

    try std.testing.expectEqual(expected, actual);
}
