const std = @import("std");

const day = "day10";
const sampleData = @embedFile("./sample");
const realData = @embedFile("./real");

const Direction = union(enum) { open, close };
const tableSize = std.math.pow(u32, 2, @sizeOf(u8) * 8);

const errorPointTable = brk: {
    var table = [_]u16{undefined} ** tableSize;
    table[')'] = 3;
    table[']'] = 57;
    table['}'] = 1197;
    table['>'] = 25137;
    break :brk table;
};

const missingPointTable = brk: {
    var table = [_]u16{undefined} ** tableSize;
    table['('] = 1;
    table['['] = 2;
    table['{'] = 3;
    table['<'] = 4;
    break :brk table;
};

const matchTable = brk: {
    var table = [_]?u8{null} ** tableSize;
    table['('] = ')';
    table['['] = ']';
    table['{'] = '}';
    table['<'] = '>';
    break :brk table;
};

const Data = struct {
    arena: std.heap.ArenaAllocator,
    lines: []const []const u8,

    fn parse(child_allocator: std.mem.Allocator, data: []const u8) !@This() {
        var arena = std.heap.ArenaAllocator.init(child_allocator);
        const allocator = arena.allocator();

        var lines = std.ArrayList([]const u8).init(allocator);

        var iterator = std.mem.tokenizeAny(u8, data, "\n");
        while (iterator.next()) |line| {
            try lines.append(line);
        }

        return .{ .arena = arena, .lines = try lines.toOwnedSlice() };
    }

    fn calculateIncorrectScore(self: *@This()) !u32 {
        var total: u32 = 0;
        const allocator = self.arena.allocator();

        for (self.lines) |line| {
            var queue = std.ArrayList(u8).init(allocator);
            defer queue.deinit();

            for (line) |char| {
                if (matchTable[char]) |_| {
                    try queue.append(char);
                } else {
                    const head = queue.popOrNull();
                    if (head) |last| {
                        if (matchTable[last] != char) {
                            total += errorPointTable[char];
                            break;
                        }
                    } else {
                        total += errorPointTable[char];
                        break;
                    }
                }
            }
        }

        return total;
    }

    fn calculateMissingScore(self: *@This()) !u64 {
        const allocator = self.arena.allocator();
        var totals = std.ArrayList(u64).init(allocator);

        blk: for (self.lines) |line| {
            var total: u64 = 0;
            var queue = std.ArrayList(u8).init(allocator);
            defer queue.deinit();

            for (line) |char| {
                if (matchTable[char]) |_| {
                    try queue.append(char);
                } else {
                    const head = queue.popOrNull();
                    if (head) |last| {
                        if (matchTable[last] != char) {
                            continue :blk;
                        }
                    } else {
                        continue :blk;
                    }
                }
            }

            var iterator = std.mem.reverseIterator(queue.items);
            while (iterator.next()) |char| {
                total *= 5;
                total += missingPointTable[char];
            }
            try totals.append(total);
        }

        std.mem.sort(u64, totals.items, {}, std.sort.desc(u64));

        const middle = try std.math.divFloor(u32, @intCast(totals.items.len), 2);
        return totals.items[@intCast(middle)];
    }

    fn deinit(self: *@This()) void {
        self.arena.deinit();
    }
};

pub fn solve(allocator: std.mem.Allocator) !void {
    var data = try Data.parse(allocator, realData);
    defer data.deinit();

    const one = try data.calculateIncorrectScore();
    const two = try data.calculateMissingScore();

    std.log.info(day ++ " part one: {}, part two: {}", .{ one, two });
}

test "one" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    const expected: u32 = 26397;
    const actual = try data.calculateIncorrectScore();

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    const expected: u32 = 288957;
    const actual = try data.calculateMissingScore();

    try std.testing.expectEqual(expected, actual);
}
