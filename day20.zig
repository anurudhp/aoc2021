const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

fn readInto(arr: []bit, off: usize) !bool {
    var buf: [1000]u8 = undefined;
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
        for (line) |c, i| {
            arr[i + off] = if (c == '.') 0 else 1;
        }
        return true;
    }
    return false;
}

fn ignoreLine() !void {
    var buf: [1000]u8 = undefined;
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {}
}

const N: usize = 210; // > 2 * it + width
const bit = i8;

var conv: [1 << 9]bit = undefined;
var mat: [N][N]bit = undefined;
var tmp: [N][N]bit = undefined;
var boundary: bit = 0;

fn at(i: usize, j: usize) bit {
    if (i < 0 or i >= N or j < 0 or j >= N)
        return boundary;
    return mat[i][j];
}

fn enhanceAt(i: usize, j: usize) bit {
    if (i == 0 or i == N - 1 or j == 0 or j == N - 1)
        return boundary;
    var ix: usize = 0;
    for ([_]usize{ i - 1, i, i + 1 }) |ii| {
        for ([_]usize{ j - 1, j, j + 1 }) |jj| {
            ix <<= 1;
            var cur = at(ii, jj);
            if (cur == 1) ix += 1;
        }
    }
    return conv[ix];
}

fn enhance() void {
    if (boundary == 0) {
        boundary = conv[0];
    } else {
        boundary = conv[511];
    }

    for (mat) |row, i| {
        for (row) |cell, j| {
            tmp[i][j] = enhanceAt(i, j);
        }
    }
    mat = tmp;
}

fn enhanceN(n: u32) void {
    var i: u32 = 0;
    while (i < n) : (i += 1) enhance();
}

fn countLit() i32 {
    var res: i32 = 0;
    for (mat) |row| {
        for (row) |cell| res += cell;
    }
    return res;
}

pub fn main() !void {
    if (try readInto(&conv, 0)) {}
    try ignoreLine();
    const off: usize = 51;
    var i: usize = off;
    while (try readInto(&mat[i], off)) : (i += 1) {}

    // part 1
    enhanceN(2);
    try stdout.print("{}\n", .{countLit()});

    // part 2
    enhanceN(48);
    try stdout.print("{}\n", .{countLit()});
}
