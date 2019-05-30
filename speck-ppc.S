#define ROUNDS 32

.text

# void speck_init(speck_ctx_t *ctx, uint64_t k[2])
.global speck_init
speck_init:
	# %r3 is ctx, %r4 is key
	# k is (%r6, %r7)
	# l is (%r8, %r9)
	# i is %r10

	lwz    %r6, 0(%r4)
	lwz    %r7, 4(%r4)
	lwz    %r8, 8(%r4)
	lwz    %r9, 12(%r4)
	# After loading, %r4 can be clobbered

	stw    %r6, 0(%r3)
	stw    %r7, 4(%r3)

	li     %r10, 0
	li     %r0, ROUNDS - 1
	mtctr  %r0

speck_init.round:
	# %r5 and %r12 are temps

	# tmp = ror(l, 8)
	srwi   %r5, %r8, 8
	srwi   %r12, %r9, 8
	insrwi %r5, %r9, 8, 0
	insrwi %r12, %r8, 8, 0

	# l = tmp + k
	addc   %r9, %r12, %r7
	adde   %r8, %r5, %r6

	# l ^= i
	xor    %r9, %r9, %r10

	# tmp = rol(k, 3)
	slwi   %r5, %r6, 3
	slwi   %r12, %r7, 3
	inslwi %r5, %r7, 3, 29
	inslwi %r12, %r6, 3, 29

	# k = tmp ^ l
	xor    %r6, %r5, %r8
	xor    %r7, %r12, %r9

	# store round key
	stwu   %r6, 8(%r3)
	stw    %r7, 4(%r3)

	# i++
	addi   %r10, %r10, 1
	bdnz   speck_init.round

	blr

# void speck_encrypt(speck_ctx_t *ctx, uint64_t ct[2], uint64_t const pt[2])
.global speck_encrypt
speck_encrypt:
	# %r3 is ctx, %r4 is ct, %r5 is pt
	# x    is (%r8,  %r9)
	# y    is (%r6,  %r7)
	# k[i] is (%r10, %r11)

	lwz    %r6, 0(%r5)
	lwz    %r7, 4(%r5)
	lwz    %r8, 8(%r5)
	lwz    %r9, 12(%r5)
	# After loading, %r5 can be clobbered

	subi   %r3, %r3, 8
	li     %r5, ROUNDS
	mtctr  %r5

speck_encrypt.round:
	# %r5 and %r12 are temps

	# Load round key
	lwzu   %r10, 8(%r3)
	lwz    %r11, 4(%r3)

	# tmp = ror(x, 8)
	srwi   %r5, %r8, 8
	srwi   %r12, %r9, 8
	insrwi %r5, %r9, 8, 0
	insrwi %r12, %r8, 8, 0

	# x = tmp + y
	addc   %r9, %r12, %r7
	adde   %r8, %r5, %r6

	# x ^= k
	xor    %r8, %r8, %r10
	xor    %r9, %r9, %r11

	# tmp = rol(y, 3)
	slwi   %r5, %r6, 3
	slwi   %r12, %r7, 3
	inslwi %r5, %r7, 3, 29
	inslwi %r12, %r6, 3, 29

	# y = tmp ^ x
	xor    %r6, %r5, %r8
	xor    %r7, %r12, %r9

	bdnz   speck_encrypt.round

	stw    %r6, 0(%r4)
	stw    %r7, 4(%r4)
	stw    %r8, 8(%r4)
	stw    %r9, 12(%r4)

	blr

# void speck_decrypt(speck_ctx_t *ctx, uint64_t const ct[2], uint64_t pt[2])
.global speck_decrypt
speck_decrypt:
	# %r3 is ctx, %r4 is ct, %r5 is pt
	# x    is (%r8,  %r9)
	# y    is (%r6,  %r7)
	# k[i] is (%r10, %r11)

	lwz    %r6, 0(%r4)
	lwz    %r7, 4(%r4)
	lwz    %r8, 8(%r4)
	lwz    %r9, 12(%r4)
	# After loading, %r4 can be clobbered

	addi   %r3, %r3, 8 * ROUNDS
	li     %r4, ROUNDS
	mtctr  %r4

speck_decrypt.round:
	# %r4 and %r12 are temps

	# Load round key
	lwzu   %r10, -8(%r3)
	lwz    %r11, 4(%r3)

	# tmp = y ^ x
	xor    %r4, %r6, %r8
	xor    %r12, %r7, %r9

	# y = ror(tmp, 3)
	srwi   %r6, %r4, 3
	srwi   %r7, %r12, 3
	insrwi %r6, %r12, 3, 0
	insrwi %r7, %r4, 3, 0

	# x ^= k
	xor    %r8, %r8, %r10
	xor    %r9, %r9, %r11

	# tmp = x - y
	subfc  %r12, %r7, %r9
	subfe  %r4, %r6, %r8

	# x = rol(tmp, 8)
	slwi   %r8, %r4, 8
	slwi   %r9, %r12, 8
	inslwi %r8, %r12, 8, 24
	inslwi %r9, %r4, 8, 24

	bdnz   speck_decrypt.round

	stw    %r6, 0(%r5)
	stw    %r7, 4(%r5)
	stw    %r8, 8(%r5)
	stw    %r9, 12(%r5)
	blr
