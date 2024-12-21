## smolforth

A small forth implementation.

### Features

- Highly modular.
- Can export relocatable object files (`*.o`).
- x86-64 and RV32/64.

### Usage

This project requires `bash`, `perl`, `m4`, `make`, `gcc` (native) and `g++` (native).
Additionally, for other architectures, `gcc` and `qemu-user` for every target platform (and `qemu-system` to run some OS-level tests).
This project assumes x86_64 to be native.

To build and test all targets:

```
./build_all.sh
```

or to build a specific target (64-bit RISC-V as an example):

```
./build_all.sh rv64
```

or for complete control:

```
make -C arch/rv64 clean INC="..."
make -C arch/rv64 -j12 INC="..."
```

The example folder showcases compilation to object files, and three simple RV64 OS-kernels running smolforth.
**These examples act as your tutorial. Sorry.**

`INC` is a space-separated list of word sets and features to include in the executable. By default, all features are enabled.

Read ARCHITECTURE.md for an explanation of the build system.

**Start reading reloc-setup.fth for an in-depth explanation of object file compilation.**

- `core` is required.
- always provides the Exception Extensions word set.

The following word sets are fully provided:

- `block` provides the Block Extensions word set.
- `double` provides the Double-Number Extensions word set.
- `file` provides the File Access Extensions word set.
- `float` provides the Floating-Point Extensions word set.
- `memory` provides the Memory-Allocation word set.
- `search` provides the Search-Order Extensions word set.
- `string` provides the String Extensions word set.

- `facility` provides the Facility word set.

The following word sets are partially provided:

- `facility` provides names from the Facility Extensions word set (`K-` words are missing).

The following word sets sparsely provided:

- `tools` provides a few Programming-Tools Extensions words defined in `tools.fth`. Other Programming-Tools Extensions words are provided because smolforth uses them internally (like `STATE`, `CS-PICK`, `CS-ROLL`, `N>R` and `NR>`), others are provided by `search` instead (`WORDS`, `NAME>STRING`), and some are available in the folder `asm/`, but only on supported platforms.
- `asm` enables `CODE` and an assembler if one is available on the platform.

### Optimizations

**Performant code generation was not the focus of this project.** The most basic compiler supported on all platforms is a "dumb" compiler where almost every word turns into a call or push of some kind.

smolforth features three levels of optimizations that are enabled by putting one in `INC`.
Availability varies between architectures.
To highlight the difference, consider the stack movement words (e.g. `SWAP`, `DROP`, `ROT`, ...).

- `O0` is the default and dumb assembler. Every stack movement word translates to a call to that word.
- `O1` is an inlined assembler. Stack movement words are inlined **individually**.
- `O2` is an optimizing compiler. **Combinations of stack movement words** are optimized together.

`O0` is generally the smallest. `O1` and `O2` increase code size in favor of less function calls.

### Limitations

This project is small in the sense that there are no "nice-to-have" features. Things you might miss from other implementations:

- No bounds checks. Good Luck!
- You cannot set memory size at run-time. It's 16MB, as defined in `main.c`. Recompile if you need more.
- No FFI, no non-standard words. You can write your own word set, if you read ARCHITECTURE.md. And again, recompile.
- No cross-compiler or device link.
- No image save/restore.

### License

0BSD
