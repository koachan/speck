#ifndef __SPECK_H__
#define __SPECK_H__

#include <stdint.h>

#define _SPECK_ROUNDS 32

typedef struct {
	uint64_t k[_SPECK_ROUNDS];
} speck_ctx_t;

void speck_init(speck_ctx_t *ctx, uint64_t k[2]);
void speck_encrypt(speck_ctx_t *ctx, uint64_t ct[2], uint64_t const pt[2]);
void speck_decrypt(speck_ctx_t *ctx, uint64_t const ct[2], uint64_t pt[2]);

#endif /* __SPECK_H__ */
