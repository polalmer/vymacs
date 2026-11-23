const std = @import("std");
const c = @import("c");

//original termianl state
var orig_termios = c.termios{};

pub fn main(init: std.process.Init) !void {
    _ = init;

    enableRawMode();

    var char:u8 = 0x00;
    //maybe does the read exist in zig native
    while(c.read(c.STDIN_FILENO, &char, 1) == 1 and char != 'q'){}
}

fn disableRawMode() callconv(.c) void{
    _ = c.tcsetattr(c.STDIN_FILENO, c.TCSAFLUSH, &orig_termios);
}

fn enableRawMode() void{
    _ = c.tcgetattr(c.STDIN_FILENO, &orig_termios);
    _ = c.atexit(disableRawMode);
    var raw:c.termios = orig_termios;
    //disable 
    //canon - read line by line
    //echo - prints input
    raw.c_cflag &= ~@as(c.u_int, c.ECHO | c.ICANON);
    _ = c.tcsetattr(c.STDIN_FILENO, c.TCSAFLUSH, &raw);
}

