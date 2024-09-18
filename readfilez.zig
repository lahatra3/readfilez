const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const params = args[1..];

    if (params.len < 1) {
        return;
    }

    const file = try fs.cwd().openFile(params[0], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    const writer = line.writer();

    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        defer line.clearRetainingCapacity();
        print("{s}\n", .{line.items});
    } else |err| switch (err) {
        error.EndOfStream => {
            if (line.items.len > 0) {
                print("{s}\n", .{line.items});
            }
        },
        else => return err,
    }
}
