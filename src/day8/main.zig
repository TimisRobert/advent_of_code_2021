const std = @import("std");

const day = "day8";
const sampleData = @embedFile("./sample");
const realData = @embedFile("./real");

const Entry = struct {
    patterns: []const []const u8,
    outputs: []const []const u8,
};

const Data = struct {
    arena: std.heap.ArenaAllocator,
    entries: []const Entry,

    fn parse(child_allocator: std.mem.Allocator, data: []const u8) !@This() {
        var arena = std.heap.ArenaAllocator.init(child_allocator);
        const allocator = arena.allocator();

        var entries = std.ArrayList(Entry).init(allocator);

        var tokens = std.mem.tokenizeAny(u8, data, "\n");

        while (tokens.next()) |token| {
            var patterns = std.ArrayList([]const u8).init(allocator);
            var outputs = std.ArrayList([]const u8).init(allocator);

            var entry_tokens = std.mem.tokenizeSequence(u8, token, " | ");

            const patterns_raw = entry_tokens.next().?;

            var patterns_tokens = std.mem.tokenizeAny(u8, patterns_raw, " ");
            while (patterns_tokens.next()) |pattern| {
                try patterns.append(pattern);
            }

            const outputs_raw = entry_tokens.next().?;

            var outputs_tokens = std.mem.tokenizeAny(u8, outputs_raw, " ");
            while (outputs_tokens.next()) |output| {
                try outputs.append(output);
            }

            try entries.append(.{
                .patterns = try patterns.toOwnedSlice(),
                .outputs = try outputs.toOwnedSlice(),
            });
        }

        return .{
            .entries = try entries.toOwnedSlice(),
            .arena = arena,
        };
    }

    // 1 => []
    // 2 => [1]
    // 3 => [7]
    // 4 => [4]
    // 5 => [2, 3, 5]
    // 6 => [0, 6, 9]
    // 7 => [8]

    fn countDigits(self: *@This()) u32 {
        var table = std.mem.zeroes([10]u32);

        for (self.entries) |entry| {
            for (entry.outputs) |value| {
                switch (value.len) {
                    2 => table[0] += 1,
                    3 => table[6] += 1,
                    4 => table[3] += 1,
                    7 => table[7] += 1,
                    else => {},
                }
            }
        }

        var total: u32 = 0;
        for (table) |value| {
            total += value;
        }

        return total;
    }

    // * 0 *
    // 5   1
    // * 6 *
    // 4   2
    // * 3 *
    //
    const BitSet = std.bit_set.IntegerBitSet(7);

    fn intoMask(sequence: []const u8) BitSet {
        var mask = BitSet.initEmpty();
        for (sequence) |value| {
            const idx = value - 'a';
            mask.set(idx);
        }

        return mask;
    }

    fn decode(self: *@This()) !u64 {
        var total: u64 = 0;

        for (self.entries) |entry| {
            var digits = std.mem.zeroes([10]BitSet);

            var two_three_five = try std.BoundedArray(BitSet, 3).init(0);
            var zero_six_nine = try std.BoundedArray(BitSet, 3).init(0);

            for (entry.patterns) |pattern| {
                switch (pattern.len) {
                    2 => digits[1] = intoMask(pattern),
                    3 => digits[7] = intoMask(pattern),
                    4 => digits[4] = intoMask(pattern),
                    5 => try two_three_five.append(intoMask(pattern)),
                    6 => try zero_six_nine.append(intoMask(pattern)),
                    7 => digits[8] = intoMask(pattern),
                    else => {},
                }
            }

            const diff = digits[4].xorWith(digits[1]);
            const ttf_slice = two_three_five.slice();

            var rem_idx: u8 = 0;

            for (ttf_slice, 0..) |value, i| {
                if (digits[1].subsetOf(value)) {
                    digits[3] = value;
                } else if (diff.subsetOf(value)) {
                    digits[5] = value;
                } else {
                    rem_idx = @truncate(i);
                }
            }

            digits[2] = ttf_slice[rem_idx];

            const zsn_slice = zero_six_nine.slice();
            for (zsn_slice, 0..) |value, i| {
                if (digits[4].subsetOf(value)) {
                    digits[9] = value;
                } else if (digits[5].subsetOf(value)) {
                    digits[6] = value;
                } else {
                    rem_idx = @truncate(i);
                }
            }

            digits[0] = ttf_slice[rem_idx];

            for (entry.outputs, 0..) |output, i| {
                const mask = intoMask(output);

                for (digits, 0..) |digit, j| {
                    if (digit.eql(mask)) total += std.math.pow(u64, 10, 3 - i) * j;
                }
            }
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

    const one = data.countDigits();
    const two = try data.decode();

    std.log.info(day ++ " part one: {}, part two: {}", .{ one, two });
}

test "one" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    const expected: u32 = 26;
    const actual = data.countDigits();

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const allocator = std.testing.allocator;

    var data = try Data.parse(allocator, sampleData);
    defer data.deinit();

    const expected: u64 = 61229;
    const actual = try data.decode();

    try std.testing.expectEqual(expected, actual);
}
