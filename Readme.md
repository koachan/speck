Speck-128/128 in C and PowerPC assembly
---

This is an implementation of the [Speck cipher](https://eprint.iacr.org/2013/404),
with 128 bits key and block size, in C, 32-bit PowerPC assembly, and
64-bit PowerPC assembly.

Disclaimer: This is experimental code, use it at your own risk.

### How to build

Ensure that you have `make` installed, then run:
```
make main       # Build the C version
make main-ppc   # Build the 32-bit PowerPC version
make main-ppc64 # Build the 64-bit PowerPC version
```

### How to run the tests

After building, run the executable generated (`main`, `main-ppc`,
or `main-ppc64`).

### TODO

- Does the assembly code work on little endian PowerPC CPUs?

### See also

[A Speck-128/128 Cipher Implementation](https://koachan.github.io/post/speck-implementation)
