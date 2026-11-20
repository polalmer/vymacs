#include <stdlib.h>
#include <unistd.h>
#include <termios.h>

struct termios original_terminal_state;

void disableRawMode(){
    //TCSAFLUSH wait for all output to be finished before applying the change
    //and discards all input left
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &original_terminal_state);
}

void enableRawMode(){
    //get the information of the terminal into the pointer termios
    tcgetattr(STDIN_FILENO, &original_terminal_state);
    atexit(disableRawMode);
    struct termios terminal_info = original_terminal_state;
    //c_lflag local modes of the terminal
    //~ ist the bitwise not
    //turn off ECHO AND ICANON
    //ECHO - each key press is printed to the terminal
    // ICANON - dont wait for \n
    terminal_info.c_lflag &= ~(ECHO | ICANON);
    //apply the changes attributes of termios
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &terminal_info);
}

int main(){
    enableRawMode();
    char c;
    while(read(STDIN_FILENO, &c, 1) == 1 && c != 'q');
    return 0;
}
