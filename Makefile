CFLAGS=-O3 -std=gnu99
LDFLAGS=-Wl,-O1

main: main.o speck.o
	$(CC) $(LDFLAGS) $^ -o $@

main-ppc: main-ppc.o speck-ppc.o
	$(CC) $(LDFLAGS) -m32 $^ -o $@

main-ppc64: main-ppc64.o speck-ppc64.o
	$(CC) $(LDFLAGS) -m64 $^ -o $@

main-ppc.o: main.c
	$(CC) $(CFLAGS) -m32 $? -c -o $@

speck-ppc.o: speck-ppc.S
	$(CC) $(CFLAGS) -m32 $? -c -o $@

main-ppc64.o: main.c
	$(CC) $(CFLAGS) -m64 $? -c -o $@

speck-ppc64.o: speck-ppc64.S
	$(CC) $(CFLAGS) -m64 $? -c -o $@

.PHONY: clean
clean:
	rm -f *.o main main-ppc main-ppc64
