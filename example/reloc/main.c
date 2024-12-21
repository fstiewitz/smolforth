// TUT Where it all comes together. We include config.h, which defines the types `cell`,
// TUT `ucell`, `dcell`, `udcell`, stack push/pop operations and the system header.
// TUT The system header is a block of data that includes important Forth variables
// TUT like BLK, SOURCE-ID, BASE, stack descriptors, section descriptors, exception data, etc.
// TUT We don't actually need to initialize this structure here, but we do the stack pointers anyway.
// TUT If you want an example that actually runs smolforth and needs to initialize this,
// TUT check out `example/os2`.
// TUT
// TUT - SFWRAPBODY and SFIMPL are macros for defining and implementing smolforth words in C.
// TUT - SFIMPL has two arguments and returns two values (the data stack and return stack).
// TUT - The calling convention is explained in `arch/x86_64/README.md`
// TUT
// TUT You can now read `example/os1/Makefile`.

#include <stdio.h>
#include <config.h>

extern char FORTH$body$FORTH_MAIN;
extern cell FORTH$body$TESTVAR;

int main() {
    FORTH$body$TESTVAR = 99;
    cell stss[32];
    sf_header.return_stack_ptr = (ucell*)alloca(2*4096);
    sf_header.stack_ptr = stss;
    sf_header.return_stack_ptr = ((ucell)sf_header.return_stack_ptr + 2 * 4096) & -32;
    char* st = (char*)sf_header.stack_ptr;
    char* rst = (char*)sf_header.return_stack_ptr;
    union ret r;
    r.r = c_to_sf(st, rst, &FORTH$body$FORTH_MAIN);
    st = (void*)r.a0;
    rst = (void*)r.a1;
    return 0;
}

SFWRAPBODY(FORTH, TYPE)
SFWRAPBODY(FORTH, CR)

SFIMPL(TYPE) {
    ucell size = upop(&st);
    char* addr = (char*)upop(&st);
    fwrite(addr, 1, size, stdout);
    RETURN(st, rst);
}

SFIMPL(CR) {
    fputc('\r', stdout);
    fputc('\n', stdout);
    RETURN(st, rst);
}
