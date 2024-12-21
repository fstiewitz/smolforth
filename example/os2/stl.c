#include<stddef.h>

void* memcpy(void* dest, const void* src, size_t size) {
    for(size_t i = 0; i < size; ++i) {
        ((char*)dest)[i] = ((char*)src)[i];
    }
    return dest;
}

void* memcpy_r(void* dest, const void* src, size_t size) {
    if(size) {
        do {
            ((char*)dest)[size - 1] = ((char*)src)[size - 1];
            --size;
        } while(size);
    }
    return dest;
}

void* memmove(void* dest, const void* src, size_t size) {
    if(dest < src) {
        return memcpy(dest, src, size);
    } else {
        return memcpy_r(dest, src, size);
    }
}

int memcmp(const void* lhs, const void* rhs, size_t count) {
    for(size_t i = 0; i < count; ++i) {
        int x = ((char*)lhs)[i] - ((char*)rhs)[i];
        if(x != 0) return x;
    }
    return 0;
}

void* memset(void* s, int c, size_t n) {
    for(size_t i = 0; i < n; ++i) {
        ((char*)s)[i] = c;
    }
    return s;
}
