const std = @import("std");

const day = "day9";
const sampleData = @embedFile("./sample");
const realData = @embedFile("./real");

const Data = struct {
    const Point = struct { x: u32, y: u32 };

    arena: std.heap.ArenaAllocator,
    map: []const []const u8,

    fn parse(child_allocator: std.mem.Allocator, data: []const u8) !@This() {
        var arena = std.heap.ArenaAllocator.init(child_allocator);
        const allocator = arena.allocator();

        var rows = std.ArrayList([]const u8).init(allocator);
        var row_tokens = std.mem.tokenizeAny(u8, data, "\n");

        while (row_tokens.next()) |row_token| {
            var row = std.ArrayList(u8).init(allocator);
            for (row_token) |value| {
                const integer = try std.fmt.parseInt(u8, &[_]u8{value}, 0);
                try row.append(integer);
            }

            try rows.append(try row.toOwnedSlice());
        }

        return .{
            .arena = arena,
            .map = try rows.toOwnedSlice(),
        };
    }

    fn findMinimums(self: *@This()) ![]const Point {
        const rows = self.map.len;
        const cols = self.map[0].len;

        const directions = [2]i8{ -1, 1 };

        const allocator = self.arena.allocator();
        var minimums = std.ArrayList(Point).init(allocator);

        for (0..rows) |i| {
            col: for (0..cols) |j| {
                const point = self.map[i][j];

                for (directions) |x_dir| {
                    var x = @as(i64, @intCast(j)) + x_dir;
                    if (x < 0 or x > cols - 1) continue;

                    if (self.map[i][@intCast(x)] <= point) continue :col;
                }
                for (directions) |y_dir| {
                    var y = @as(i64, @intCast(i)) + y_dir;
                    if (y < 0 or y > rows - 1) continue;

                    if (self.map[@intCast(y)][j] <= point) continue :col;
                }

                try minimums.append(.{ .x = @intCast(j), .y = @intCast(i) });
            }
        }

        return try minimums.toOwnedSlice();
    }

    fn calculateRiskLevel(self: *@This(), minimums: []const Point) u32 {
        var total: u32 = 0;
        for (minimums) |minimum| {
            total += self.map[minimum.y][minimum.x] + 1;
        }

        return total;
    }

    fn calculateBasins(self: *@This(), minimums: []const Point) !u32 {
        const allocator = self.arena.allocator();
        const directions = [2]i8{ -1, 1 };
        const rows = self.map.len;
        const cols = self.map[0].len;

        var totals = std.ArrayList(u32).init(allocator);
        defer totals.deinit();

        for (minimums) |minimum| {
            var queue = std.ArrayList(Point).init(allocator);
            defer queue.deinit();
            var seen = std.AutoHashMap(Point, void).init(allocator);
            defer seen.deinit();

            try queue.append(minimum);
            try seen.put(minimum, {});

            var total: u32 = 0;

            while (queue.popOrNull()) |next| {
                total += 1;

                for (directions) |x_dir| {
                    var x = @as(i64, @intCast(next.x)) + x_dir;

                    if (x < 0 or x > cols - 1) continue;
                    if (self.map[next.y][@intCast(x)] == 9) continue;

                    const point = Point{ .x = @intCast(x), .y = next.y };
                    if (seen.contains(point)) continue;

                    try seen.put(point, {});
                    try queue.append(point);
                }
                for (directions) |y_dir| {
                    var y = @as(i64, @intCast(next.y)) + y_dir;

                    if (y < 0 or y > rows - 1) continue;
                    if (self.map[@intCast(y)][next.x] == 9) continue;

                    const point = Point{ .x = next.x, .y = @intCast(y) };
                    if (seen.contains(point)) continue;

                    try seen.put(point, {});
                    try queue.append(point);
                }
            }

            try totals.append(total);
        }

        std.sort.pdq(u32, totals.items, {}, std.sort.desc(u32));

        var total: u32 = 1;
        for (totals.items[0..3]) |value| {
            total *= value;
        }

        return total;
    }

    fn deinit(self: *@This()) void {
        self.arena.deinit();
    }
};

pub fn solve(allocator: std.mem.Allocator) !void {
    var data = try Data.parse(allocator, realData);
    defer data.deinit();

    const minimums = try data.findMinimums();

    const one = data.calculateRiskLevel(minimums);
    const two = try data.calculateBasins(minimums);

    std.log.info(day ++ " part one: {}, part two: {}", .{ one, two });
}

test "one" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    const minimums = try data.findMinimums();
    const actual = data.calculateRiskLevel(minimums);
    const expected: u32 = 15;

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    const minimums = try data.findMinimums();
    const actual = try data.calculateBasins(minimums);
    const expected: u32 = 1134;

    try std.testing.expectEqual(expected, actual);
}
