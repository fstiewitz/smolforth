#include<config.h>

void* to_body(void* ptr) {
    unsigned char flags = *((char*)ptr - 1);
    ucell*r = (ucell*)ptr + 1;
    if(0 != (flags & W_EXEC)) {
        r += 1;
    } else if(0 != (flags & W_RUNTIME)) {
        r += 1;
    }
    if(0 != (flags & W_EXTENDED)) {
        r += 1;
    }
    if(0 != (flags & W_DETACHED)) {
        r = *(ucell**)r;
    }
    return r;
}
