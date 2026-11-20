# check if the file is newer than the output if yes run
#Wall, Wextra, pedantic enhanced warnings
vymacs: vymacs.c
	gcc vymacs.c -o vymacs -Wall -Wextra -pedantic -std=c23
