const std = @import("std");
const c = @import("c");

pub fn main(init: std.process.Init) !void {
    _ = init;
    var char:u8 = 0x00;
    while(c.read(c.STDIN_FILENO, &char, 1) == 1){}
}

