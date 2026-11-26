const std = @import("std");

const termios = @import("termios.h");
const clib = @import("clib");

pub fn main(init: std.process.Init) !void {
    _ = init;

    const originalState = enableRawMode();
    defer disableRawMode(&originalState);

    var char:u8 = 0x00;
    //maybe does the read exist in zig native
    while(clib.read(clib.STDIN_FILENO, &char, 1) == 1 and char != 'q'){
        if(std.ascii.isControl(char)){
            std.log.debug("{d}", .{char});
        }
        else{
            std.log.debug("{d} ({c})", .{char, char});
        }
    }
}

fn disableRawMode(originalState:*const termios.termios) void{
    _ = termios.tcsetattr(clib.STDIN_FILENO, termios.TCSAFLUSH, originalState);
}

fn enableRawMode() termios.termios{
    //read term and savce copy
    var term:termios.termios = .{};
    _ = termios.tcgetattr(clib.STDIN_FILENO, &term);
    const original = term;

    //disable default states
    //canon - read line by line
    //echo - prints input
    //ISIG - ctrl-c = interupt
    //IEXTEN - Ctrl-v read next char literally
    term.c_lflag &= ~@as(c_uint, termios.ECHO | termios.ICANON | termios.ISIG | termios.IEXTEN);
    //IXON - flow control Ctrl-S, Ctrl-Q
    //ICRNL - treat \r as \n
    //legacy flags not really used in modern terminals 
    //BRKINT - break conditions like Ctrl-C
    //ISTRIP - 8th bit of each input is stripped
    //INPCK - enable parity checking
    term.c_iflag &= ~@as(c_uint, termios.IXON | termios.ICRNL | termios.BRKINT | termios.ISTRIP | termios.INPCK);
    //OPOST - convert \n to \r\n
    term.c_oflag &= ~@as(c_uint, termios.OPOST);
    //legacy - set char size to 8bits per byte
    term.c_cflag |= @as(c_uint, termios.CS8);

    //apply changed term
    _ = termios.tcsetattr(clib.STDIN_FILENO, termios.TCSAFLUSH, &term);

    return original;
}

