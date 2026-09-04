CC = gcc

program: main.o ops.o
	$(CC) main.o ops.o -o program

main.o: main.c ops.h
	$(CC) -std=c17 -Wall -Wextra -Wpedantic -c main.c -o main.o

ops.o: ops.c ops.h
	$(CC) -std=c17 -Wall -Wextra -Wpedantic -c ops.c -o ops.o

.PHONY: test clean

test: program
	sh tests/test.sh

clean:
	rm -f program broken_link main.i main.s main.o ops.o compile_error.o \
		main.text.bin
