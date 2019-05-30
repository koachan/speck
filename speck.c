// Adapted from the IACR paper
// https://eprint.iacr.org/2013/404

#include <stdint.h>

#include "speck.h"

#define ROR(x, r)     ((x >> r) | (x << (64 - r)))
#define ROL(x, r)     ((x << r) | (x >> (64 - r)))
#define R(x, y, k)    (x = ROR(x, 8), x += y, x ^= k, y = ROL(y, 3), y ^= x)
#define RINV(x, y, k) (y ^= x, y = ROR(y, 3), x ^= k, x -= y, x = ROL(x, 8))

void
speck_init(speck_ctx_t *ctx, uint64_t key[2]) {
	uint64_t k = key[0], l = key[1];

	ctx->k[0] = k;
	for (uint64_t i = 0; i < _SPECK_ROUNDS - 1; i++) {
		R(l, k, i);
		ctx->k[i + 1] = k;
	}
}

void
speck_encrypt(speck_ctx_t *ctx, uint64_t ct[2], uint64_t const pt[2]) {
	uint64_t x = pt[1], y = pt[0];

	for (int64_t i = 0; i < _SPECK_ROUNDS; i++) {
		R(x, y, ctx->k[i]);
	}

	ct[1] = x;
	ct[0] = y;
}

void
speck_decrypt(speck_ctx_t *ctx, uint64_t const ct[2], uint64_t pt[2]) {
	uint64_t x = ct[1], y = ct[0];

	for (int64_t i = _SPECK_ROUNDS - 1; i >= 0; i--) {
		RINV(x, y, ctx->k[i]);
	}

	pt[1] = x;
	pt[0] = y;
}
