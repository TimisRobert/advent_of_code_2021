const std = @import("std");

const days = .{
    @import("day1/main.zig"),
    @import("day2/main.zig"),
    @import("day3/main.zig"),
    @import("day4/main.zig"),
    @import("day5/main.zig"),
    @import("day6/main.zig"),
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer {
        const status = gpa.deinit();
        if (status == .leak) std.log.warn("Allocator leak", .{});
    }

    const allocator = gpa.allocator();

    inline for (days, 1..) |day, i| {
        day.solve(allocator) catch |err| {
            std.log.err("day {d} err: {any}", .{ i, err });
        };
    }
}

test "all" {
    inline for (days) |day| {
        _ = day;
    }
}
