const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, day: []const u8, file_name: []const u8) ![]u8 {
    const path = try std.mem.join(allocator, "/", &.{ "inputs", day, file_name });
    defer allocator.free(path);

    return try std.fs.cwd().readFileAlloc(allocator, path, 1_000_000);
}
