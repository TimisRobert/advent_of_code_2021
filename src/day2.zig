const std = @import("std");
const readFile = @import("utils.zig").readFile;

const Instruction = union(enum) { up: i32, down: i32, forward: i32 };

const State = struct {
    x: i32,
    y: i32,

    fn init() @This() {
        return .{ .x = 0, .y = 0 };
    }

    fn executeInstructions(self: *@This(), instructions: []const Instruction) void {
        for (instructions) |instruction| {
            switch (instruction) {
                .up => |value| {
                    self.y -= value;
                },
                .down => |value| {
                    self.y += value;
                },
                .forward => |value| {
                    self.x += value;
                },
            }
        }
    }
};

const AimState = struct {
    x: i32,
    y: i32,
    aim: i32,

    fn init() @This() {
        return .{
            .x = 0,
            .y = 0,
            .aim = 0,
        };
    }

    fn executeInstructions(self: *@This(), instructions: []const Instruction) void {
        for (instructions) |instruction| {
            switch (instruction) {
                .up => |value| {
                    self.aim -= value;
                },
                .down => |value| {
                    self.aim += value;
                },
                .forward => |value| {
                    self.x += value;
                    self.y += self.aim * value;
                },
            }
        }
    }
};

fn parseData(allocator: std.mem.Allocator, data: []const u8) ![]const Instruction {
    var tokens = std.mem.tokenizeAny(u8, data, " \n");

    var array = std.ArrayList(Instruction).init(allocator);

    while (tokens.peek()) |_| {
        const direction = tokens.next() orelse break;
        const value = tokens.next() orelse break;

        const integer = try std.fmt.parseInt(i32, value, 10);

        if (std.mem.eql(u8, direction, "up")) {
            try array.append(Instruction{ .up = integer });
        } else if (std.mem.eql(u8, direction, "down")) {
            try array.append(Instruction{ .down = integer });
        } else if (std.mem.eql(u8, direction, "forward")) {
            try array.append(Instruction{ .forward = integer });
        }
    }

    return array.toOwnedSlice();
}

pub fn solve(allocator: std.mem.Allocator) !void {
    const file = try readFile(allocator, "day2", "real");
    defer allocator.free(file);

    const instructions = try parseData(allocator, file);
    defer allocator.free(instructions);

    var state = State.init();
    state.executeInstructions(instructions);

    const one = state.x * state.y;

    var aim_state = AimState.init();
    aim_state.executeInstructions(instructions);

    const two = aim_state.x * aim_state.y;

    std.log.info("day2 part one: {}", .{one});
    std.log.info("day2 part two: {}", .{two});
}

test "one" {
    const data = try readFile(std.testing.allocator, "day2", "sample");
    defer std.testing.allocator.free(data);

    const instructions = try parseData(std.testing.allocator, data);
    defer std.testing.allocator.free(instructions);

    var state = State.init();
    state.executeInstructions(instructions);

    const expected: i32 = 150;
    const actual: i32 = state.x * state.y;

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const data = try readFile(std.testing.allocator, "day2", "sample");
    defer std.testing.allocator.free(data);

    const instructions = try parseData(std.testing.allocator, data);
    defer std.testing.allocator.free(instructions);

    var aim_state = AimState.init();
    aim_state.executeInstructions(instructions);

    const expected: i32 = 900;
    const actual = aim_state.x * aim_state.y;

    try std.testing.expectEqual(expected, actual);
}
