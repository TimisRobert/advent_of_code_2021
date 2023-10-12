const std = @import("std");

const day = "day4";
const sampleData = @embedFile("./sample");
const realData = @embedFile("./real");

const Board = struct { numbers: []const []const u32 };

const WinningBoard = struct {
    arena: std.heap.ArenaAllocator,
    board: Board,
    extractions: []const u32,

    fn getLastExtraction(self: @This()) u32 {
        return self.extractions[self.extractions.len - 1];
    }

    fn getMissingNumbers(self: *@This()) ![]const u32 {
        const allocator = self.arena.allocator();
        var missing_numbers = std.ArrayList(u32).init(allocator);

        for (self.board.numbers) |row| {
            for (row) |x| {
                const found = for (self.extractions) |extraction| {
                    if (x == extraction) break true;
                } else false;

                if (!found) try missing_numbers.append(x);
            }
        }

        return missing_numbers.toOwnedSlice();
    }
};

const Data = struct {
    arena: std.heap.ArenaAllocator,
    boards: []const Board,
    extractions: []const u32,

    const board_size = 5;

    fn init(child_allocator: std.mem.Allocator, data: []const u8) !@This() {
        var arena = std.heap.ArenaAllocator.init(child_allocator);
        errdefer arena.deinit();

        const allocator = arena.allocator();

        var tokens = std.mem.tokenizeAny(u8, data, "\n");

        const extractions_raw = tokens.next().?;
        var extractions = std.ArrayList(u32).init(allocator);
        var extraction_tokens = std.mem.tokenizeAny(u8, extractions_raw, ",");

        while (extraction_tokens.next()) |extraction| {
            const integer = try std.fmt.parseInt(u32, extraction, 10);
            try extractions.append(integer);
        }

        var boards = std.ArrayList(Board).init(allocator);

        while (tokens.peek()) |_| {
            var rows = std.ArrayList([]u32).init(allocator);

            for (0..board_size) |_| {
                var row = std.ArrayList(u32).init(allocator);

                const row_raw = tokens.next().?;

                var number_tokens = std.mem.tokenizeAny(u8, row_raw, " ");
                while (number_tokens.next()) |number| {
                    const integer = try std.fmt.parseInt(u32, number, 10);
                    try row.append(integer);
                }

                try rows.append(try row.toOwnedSlice());
            }

            try boards.append(Board{ .numbers = try rows.toOwnedSlice() });
        }

        return .{
            .arena = arena,
            .boards = try boards.toOwnedSlice(),
            .extractions = try extractions.toOwnedSlice(),
        };
    }

    fn isBingo(numbers: []const u32, extractions: []const u32) bool {
        var all_match = true;

        for (numbers) |number| {
            const found = for (extractions) |extraction| {
                if (number == extraction) break true;
            } else false;

            all_match = all_match and found;

            if (!all_match) break;
        }

        return all_match;
    }

    fn findFirstWinner(self: *@This()) !WinningBoard {
        var window_len: u32 = board_size;
        var extractions_len = self.extractions.len;

        const allocator = self.arena.allocator();

        while (window_len < extractions_len) : (window_len += 1) {
            const extractions = self.extractions[0..window_len];

            for (self.boards) |board| {
                var found = for (0..board_size) |index| {
                    var column_arr = std.ArrayList(u32).init(allocator);
                    defer column_arr.deinit();

                    for (board.numbers) |row| {
                        try column_arr.append(row[index]);
                    }

                    const row = board.numbers[index];
                    const column = try column_arr.toOwnedSlice();

                    if (isBingo(row, extractions) or isBingo(column, extractions)) break true;
                } else false;

                if (found) return .{
                    .arena = self.arena,
                    .board = board,
                    .extractions = extractions,
                };
            }
        } else unreachable;
    }

    fn findLastWinner(self: *@This()) !WinningBoard {
        var window_len: u32 = board_size;
        var extractions_len = self.extractions.len;

        const allocator = self.arena.allocator();
        var boards = std.ArrayList(Board).init(allocator);
        try boards.appendSlice(self.boards);

        while (window_len < extractions_len) : (window_len += 1) {
            const extractions = self.extractions[0..window_len];

            var remaining_boards = std.ArrayList(Board).init(allocator);

            for (boards.items) |board| {
                var found = for (0..board_size) |index| {
                    var column_arr = std.ArrayList(u32).init(allocator);
                    defer column_arr.deinit();

                    for (board.numbers) |row| {
                        try column_arr.append(row[index]);
                    }

                    const row = board.numbers[index];
                    const column = try column_arr.toOwnedSlice();

                    if (isBingo(row, extractions) or isBingo(column, extractions)) break true;
                } else false;

                if (!found) {
                    try remaining_boards.append(board);
                } else if (found and boards.items.len == 1) {
                    return .{
                        .arena = self.arena,
                        .board = boards.items[0],
                        .extractions = extractions,
                    };
                }
            }

            boards = remaining_boards;
        } else unreachable;
    }

    fn deinit(self: @This()) void {
        self.arena.deinit();
    }
};

pub fn solve(allocator: std.mem.Allocator) !void {
    var data = try Data.init(allocator, realData);
    defer data.deinit();

    var first_winner = try data.findFirstWinner();
    const missing_numbers = try first_winner.getMissingNumbers();
    const first_last_extraction = first_winner.getLastExtraction();

    var first_total: u32 = 0;
    for (missing_numbers) |number| first_total += number;

    const one = first_total * first_last_extraction;

    var last_winner = try data.findLastWinner();
    const last_missing_numbers = try last_winner.getMissingNumbers();
    const last_extraction = last_winner.getLastExtraction();

    var last_total: u32 = 0;
    for (last_missing_numbers) |number| last_total += number;

    const two = last_total * last_extraction;

    std.log.info(day ++ " part one: {}, part two: {}", .{ one, two });
}

test "one" {
    const allocator = std.testing.allocator;
    var data = try Data.init(allocator, sampleData);
    defer data.deinit();

    var first_winner = try data.findFirstWinner();
    const missing_numbers = try first_winner.getMissingNumbers();
    const last_extraction = first_winner.getLastExtraction();

    var total: u32 = 0;
    for (missing_numbers) |number| total += number;

    const expected: u32 = 4512;
    const actual = total * last_extraction;

    try std.testing.expectEqual(expected, actual);
}

test "two" {
    const allocator = std.testing.allocator;
    var data = try Data.init(allocator, sampleData);
    defer data.deinit();

    var last_winner = try data.findLastWinner();
    const missing_numbers = try last_winner.getMissingNumbers();
    const last_extraction = last_winner.getLastExtraction();

    var total: u32 = 0;
    for (missing_numbers) |number| total += number;

    const expected: u32 = 1924;
    const actual = total * last_extraction;

    try std.testing.expectEqual(expected, actual);
}
