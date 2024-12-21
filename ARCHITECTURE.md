## Architecture of smolforth

A smolforth compiler has three "parts":

1. A platform-agnostic collection of words that are necessary to create a bootstrap compiler. Not all core words, but enough to compile the rest of them to an object file.
2. A platform-specific collection of words that are necessary to create a bootstrap compiler.
3. A Forth-implementation of all remaining words.

Building smolforth thus works as follows:

1. Build a bootstrap compiler.
2. Evaluate the remaining words and export them to an object file.
3. Re-link the bootstrap compiler with that object file.

### Word Sets

smolforth uses a system built around `m4` to assemble the core words you want.

A word set (for example `facility`) has:

- A text file (`gen/facility.txt`) with macros defining every word that cannot be implemented in smolforth alone (e.g. `TIME&DATE` in `facility`).
- `facility/*.m4` are word definitions for the words defined in `gen/facility.txt` inside M4 macros.
- `facility/*.c` are C files with other word definitions also defined in `gen/facility.txt`.
- `facility/environment_queries.h` (and `environment_functions.h`) include code for `ENVIRONMENT?`.
- Various `facility*.fth` are included by `extensions.fth` and `extensions-boot.fth` and include Forth implementations of words that can be implemented that way.

Any architecture-specific words would be defined in `arch/.../facility/`.
