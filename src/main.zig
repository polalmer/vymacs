const std = @import("std");
const c = @import("c");

pub fn main(init: std.process.Init) !void {
    _ = init;

    const originalState = enableRawMode();
    defer disableRawMode(&originalState);

    var char:u8 = 0x00;
    //maybe does the read exist in zig native
    while(c.read(c.STDIN_FILENO, &char, 1) == 1 and char != 'q'){
        if(std.ascii.isControl(char)){
            std.log.debug("{d}", .{char});
        }
        else{
            std.log.debug("{d} ({c})", .{char, char});
        }
    }
}

fn disableRawMode(originalState:*const c.termios) void{
    _ = c.tcsetattr(c.STDIN_FILENO, c.TCSAFLUSH, originalState);
}

fn enableRawMode() c.termios{
    //read term and savce copy
    var term:c.termios = .{};
    _ = c.tcgetattr(c.STDIN_FILENO, &term);
    const original = term;

    //disable default states
    //canon - read line by line
    //echo - prints input
    //ISIG - ctrl-c = interupt
    //IEXTEN - Ctrl-v read next char literally
    term.c_lflag &= ~@as(c.u_int, c.ECHO | c.ICANON | c.ISIG | c.IEXTEN);
    //IXON - flow control Ctrl-S, Ctrl-Q
    //ICRNL - treat \r as \n
    //legacy flags not really used in modern terminals 
    //BRKINT - break conditions like Ctrl-C
    //ISTRIP - 8th bit of each input is stripped
    //INPCK - enable parity checking
    term.c_iflag &= ~@as(c.u_int, c.IXON | c.ICRNL | c.BRKINT | c.ISTRIP | c.INPCK);
    //OPOST - convert \n to \r\n
    term.c_oflag &= ~@as(c_uint, c.OPOST);
    //legacy - set char size to 8bits per byte
    term.c_cflag |= @as(c_uint, c.CS8);

    //apply changed term
    _ = c.tcsetattr(c.STDIN_FILENO, c.TCSAFLUSH, &term);

    return original;
}

