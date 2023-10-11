const std = @import("std");
const readFile = @import("utils.zig").readFile;

fn Calculator(comptime container_type: anytype) type {
    return struct {
        const bit_size = @bitSizeOf(container_type);
        const BitSet = std.StaticBitSet(bit_size);

        fn parseData(allocator: std.mem.Allocator, data: []const u8) ![]const BitSet {
            var tokens = std.mem.tokenizeAny(u8, data, "\n");

            var array = std.ArrayList(BitSet).init(allocator);

            while (tokens.next()) |token| {
                const integer = try std.fmt.parseInt(container_type, token, 2);
                try array.append(@bitCast(integer));
            }

            return array.toOwnedSlice();
        }

        fn calculateGamma(bit_sets: []const BitSet) container_type {
            const length = bit_sets.len;
            const half_length = @divFloor(length, 2);

            var gamma = BitSet.initEmpty();

            for (0..bit_size) |bit| {
                var total: u32 = 0;

                for (bit_sets) |bit_set| {
                    if (bit_set.isSet(bit)) total += 1;
                }

                if (total > half_length) gamma.set(bit);
            }

            return @bitCast(gamma);
        }

        fn calculateEpsilon(gamma: container_type) container_type {
            var bit_set: BitSet = @bitCast(gamma);
            return @bitCast(bit_set.complement());
        }

        fn calculateO2(allocator: std.mem.Allocator, bit_sets: []const BitSet) !container_type {
            var array = std.ArrayList(BitSet).init(allocator);
            defer array.deinit();
            try array.appendSlice(bit_sets);

            for (0..bit_size) |bit| {
                const current_bit = bit_size - bit - 1;

                var total_zeros: u32 = 0;
                var total_ones: u32 = 0;

                for (array.items) |bit_set| {
                    if (bit_set.isSet(current_bit)) {
                        total_ones += 1;
                    } else {
                        total_zeros += 1;
                    }
                }

                var filtered_array = std.ArrayList(BitSet).init(allocator);
                const more_ones = total_ones >= total_zeros;

                for (array.items) |bit_set| {
                    const is_set = bit_set.isSet(current_bit);

                    if (more_ones) {
                        if (is_set) try filtered_array.append(bit_set);
                    } else {
                        if (!is_set) try filtered_array.append(bit_set);
                    }
                }

                array.deinit();
                array = filtered_array;

                if (filtered_array.items.len == 1) break;
            }

            return @bitCast(array.items[0]);
        }

        fn calculateCo2(allocator: std.mem.Allocator, bit_sets: []const BitSet) !container_type {
            var array = std.ArrayList(BitSet).init(allocator);
            defer array.deinit();
            try array.appendSlice(bit_sets);

            for (0..bit_size) |bit| {
                const current_bit = bit_size - bit - 1;

                var total_zeros: u32 = 0;
                var total_ones: u32 = 0;

                for (array.items) |bit_set| {
                    if (bit_set.isSet(current_bit)) {
                        total_ones += 1;
                    } else {
                        total_zeros += 1;
                    }
                }

                var filtered_array = std.ArrayList(BitSet).init(allocator);
                const more_ones = total_ones >= total_zeros;

                for (array.items) |bit_set| {
                    const is_set = bit_set.isSet(current_bit);

                    if (more_ones) {
                        if (!is_set) try filtered_array.append(bit_set);
                    } else {
                        if (is_set) try filtered_array.append(bit_set);
                    }
                }

                array.deinit();
                array = filtered_array;

                if (filtered_array.items.len == 1) break;
            }

            return @bitCast(array.items[0]);
        }
    };
}

pub fn solve(allocator: std.mem.Allocator) !void {
    const file = try readFile(allocator, "day3", "real");
    defer allocator.free(file);

    const CalculatorImpl = Calculator(u12);

    const bit_sets = try CalculatorImpl.parseData(allocator, file);
    defer allocator.free(bit_sets);

    const gamma_one = CalculatorImpl.calculateGamma(bit_sets);
    const epsilon_one = @as(u32, CalculatorImpl.calculateEpsilon(gamma_one));

    const one = gamma_one * epsilon_one;

    const o2 = try CalculatorImpl.calculateO2(allocator, bit_sets);
    const co2 = @as(u32, try CalculatorImpl.calculateCo2(allocator, bit_sets));

    const two = o2 * co2;

    std.log.info("day3 part one: {}", .{one});
    std.log.info("day3 part two: {}", .{two});
}

test "one" {
    const data = try readFile(std.testing.allocator, "day3", "sample");
    defer std.testing.allocator.free(data);

    const CalculatorImpl = Calculator(u5);

    const bit_sets = try CalculatorImpl.parseData(std.testing.allocator, data);
    defer std.testing.allocator.free(bit_sets);

    const gamma = CalculatorImpl.calculateGamma(bit_sets);
    const epsilon = CalculatorImpl.calculateEpsilon(gamma);

    const expected_gamma: u5 = 22;
    const expected_epsilon: u5 = 9;

    try std.testing.expectEqual(expected_gamma, gamma);
    try std.testing.expectEqual(expected_epsilon, epsilon);
}

test "two" {
    const data = try readFile(std.testing.allocator, "day3", "sample");
    defer std.testing.allocator.free(data);

    const CalculatorImpl = Calculator(u5);

    const bit_sets = try CalculatorImpl.parseData(std.testing.allocator, data);
    defer std.testing.allocator.free(bit_sets);

    const o2 = try CalculatorImpl.calculateO2(std.testing.allocator, bit_sets);
    const co2 = try CalculatorImpl.calculateCo2(std.testing.allocator, bit_sets);

    const expected_o2: u5 = 23;
    const expected_co2: u5 = 10;

    try std.testing.expectEqual(expected_o2, o2);
    try std.testing.expectEqual(expected_co2, co2);
}
