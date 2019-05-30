#define ROUNDS 32

.section .opd, "aw"
.align 3

# void speck_init(speck_ctx_t *ctx, uint64_t k[2])
.global speck_init
speck_init:
	.quad .speck_init, .TOC.@tocbase, 0

# void speck_encrypt(speck_ctx_t *ctx, uint64_t ct[2], uint64_t const pt[2])
.global speck_encrypt
speck_encrypt:
	.quad .speck_encrypt, .TOC.@tocbase, 0

# void speck_decrypt(speck_ctx_t *ctx, uint64_t const ct[2], uint64_t pt[2])
.global speck_decrypt
speck_decrypt:
	.quad .speck_decrypt, .TOC.@tocbase, 0

.text

.speck_init:
	# %r3 is ctx, %r4 is key
	# k is %r5
	# l is %r6
	# i is %r7

	ld     %r5, 0(%r4)
	ld     %r6, 8(%r4)
	# After loading, %r4 can be clobbered

	std    %r5, 0(%r3)

	li     %r7, ROUNDS - 1
	mtctr  %r7

	li     %r7, 0
.speck_init.round:
	# l = ror(l, 8)
	rotrdi %r6, %r6, 8

	# l += k
	add    %r6, %r6, %r5

	# l ^= i
	xor    %r6, %r6, %r7

	# k = rol(k, 3)
	rotldi %r5, %r5, 3

	# k ^= l
	xor    %r5, %r5, %r6

	# store round key
	stdu   %r5, 8(%r3)

	# i++
	addi   %r7, %r7, 1
	bdnz   .speck_init.round

	blr

.speck_encrypt:
	# %r3 is ctx, %r4 is ct, %r5 is pt
	# x    is %r7
	# y    is %r6
	# k[i] is %r8

	ld     %r6, 0(%r5)
	ld     %r7, 8(%r5)
	# After loading, %r5 can be clobbered

	subi   %r3, %r3, 8
	li     %r5, ROUNDS
	mtctr  %r5

.speck_encrypt.round:
	# Load round key
	ldu    %r8, 8(%r3)

	# x = ror(x, 8)
	rotrdi %r7, %r7, 8

	# x += y
	add    %r7, %r7, %r6

	# x ^= k
	xor    %r7, %r7, %r8

	# y = rol(y, 3)
	rotldi %r6, %r6, 3

	# y ^= x
	xor    %r6, %r6, %r7

	bdnz   .speck_encrypt.round

	std    %r6, 0(%r4)
	std    %r7, 8(%r4)

	blr

.speck_decrypt:
	# %r3 is ctx, %r4 is ct, %r5 is pt
	# x    is %r7
	# y    is %r6
	# k[i] is %r8

	ld     %r6, 0(%r4)
	ld     %r7, 8(%r4)
	# After loading, %r4 can be clobbered

	addi   %r3, %r3, 8 * ROUNDS
	li     %r4, ROUNDS
	mtctr  %r4

.speck_decrypt.round:
	# Load round key
	ldu    %r8, -8(%r3)

	# y ^= x
	xor    %r6, %r6, %r7

	# y = ror(y, 3)
	rotrdi %r6, %r6, 3

	# x ^= k
	xor    %r7, %r7, %r8

	# x -= y
	sub    %r7, %r7, %r6

	# x = rol(x, 8)
	rotldi %r7, %r7, 8

	bdnz   .speck_decrypt.round

	std    %r6, 0(%r5)
	std    %r7, 8(%r5)

	blr
