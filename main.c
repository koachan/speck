#include <stdint.h>
#include <stdio.h>
#include <time.h>

#include "speck.h"

#define CTR       6553600 /* 16-byte blocks, for a total of 100 MiB */
#define CPU_SPEED 1416.67 /* MHz */

// Encrypt dummy data and return timing info
static double
do_encrypt(void) {
	struct timespec start, end;
	double sec, nsec;

	uint64_t k[2] = {0}, ct[2] = {0}, pt[2] = {0};
	speck_ctx_t ctx;

	speck_init(&ctx, k);

	clock_gettime(CLOCK_MONOTONIC, &start);

	for(uint64_t i = 0; i < CTR; i++) {
		speck_encrypt(&ctx, ct, pt);
	}

	clock_gettime(CLOCK_MONOTONIC, &end);

	sec  = end.tv_sec - start.tv_sec;
	nsec = end.tv_nsec - start.tv_nsec;

	// bytes/s
	return (CTR * 16) / (sec + nsec / 1000000000);
}

// Decrypt dummy data and return timing info
static double
do_decrypt(void) {
	struct timespec start, end;
	double sec, nsec;

	uint64_t k[2] = {0}, ct[2] = {0}, pt[2] = {0};
	speck_ctx_t ctx;

	speck_init(&ctx, k);

	clock_gettime(CLOCK_MONOTONIC, &start);

	for(uint64_t i = 0; i < CTR; i++) {
		speck_decrypt(&ctx, ct, pt);
	}

	clock_gettime(CLOCK_MONOTONIC, &end);

	sec  = end.tv_sec - start.tv_sec;
	nsec = end.tv_nsec - start.tv_nsec;

	// bytes/s
	return (CTR * 16) / (sec + nsec / 1000000000);
}

static int
test_vector_check(void) {
	// The paper's test vectors are reversed
	uint64_t k[2]  = {0x0706050403020100, 0x0f0e0d0c0b0a0908};
	uint64_t pt[2] = {0x7469206564616d20, 0x6c61766975716520};
	uint64_t ct[2] = {0x7860fedf5c570d18, 0xa65d985179783265};

	int enc, dec;

	uint64_t t[2]  = {0};
	speck_ctx_t ctx;

	speck_init(&ctx, k);

	speck_encrypt(&ctx, t, pt);
	enc = (t[0] == ct[0]) && (t[1] == ct[1]);

	speck_decrypt(&ctx, ct, t);
	dec = (t[0] == pt[0]) && (t[1] == pt[1]);

	return enc && dec;
}

int
main(void) {
	double ebps, dbps;
	if (!test_vector_check()) {
		return 1;
	}

	ebps = do_encrypt();
	dbps = do_decrypt();
	printf("Encryption: approx. %lf MiB/s (%lf cpb at %lf MHz)\n",
		ebps / (1 << 20), (CPU_SPEED * 1000000.0) / ebps, CPU_SPEED);
	printf("Decryption: approx. %lf MiB/s (%lf cpb at %lf MHz)\n",
		dbps / (1 << 20), (CPU_SPEED * 1000000.0) / dbps, CPU_SPEED);
	return 0;
}
