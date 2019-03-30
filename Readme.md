Speck-128/128 in C and PowerPC assembly
---

This is an implementation of the Speck cipher, with 128 bits key and block size,
in standard C99 and 32-bit PowerPC assembly.

Disclaimer: This is experimental code, use it at your own risk.

### How to build

Ensure that you have GNU make installed, then run `make` (or `gmake`).

### How to run the tests

After building, run `./main` to run the C implementation, or `./main-ppc` to run
the assembly version.

### TODO

- x86 (32 and 64-bit) assembly implementation
- 64-bit PowerPC implementation

### See also

[A Speck-128/128 Cipher Implementation](https://koachan.github.io/post/speck-implementation)
