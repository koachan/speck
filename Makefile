CFLAGS=-O2 -std=c99
CPU=$(shell uname -m)

ifeq ($(CPU),ppc)
all: main main-ppc
else
all: main
endif

main: main.o speck.o

main-ppc: main.o speck-ppc.o
	$(CC) $? -o $@

.PHONY: clean
clean:
	rm -f *.o main main-ppc
