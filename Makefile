CFLAGS=-O3

main: main.o speck.o

main-ppc: main.o speck-ppc.o
	$(CC) $? -o $@

.PHONY: clean
clean:
	rm -f *.o main main-ppc
