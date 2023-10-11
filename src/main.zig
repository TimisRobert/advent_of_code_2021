const std = @import("std");

const days = .{
    @import("day1.zig"),
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
