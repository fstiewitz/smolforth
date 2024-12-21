#include<config.h>

#include<stdarg.h>
#include<string.h>

void* next_word;

void make_word(char* name, int nlen, int flags, void* exec, void* extended) {
    struct sf_data_t *ws = sf_header.active_section;
    if(sf_header.wdata || sf_header.active_section->flags == SECTION_UDATA) {
        flags |= W_DETACHED;
        ws = sf_header.wdata;
        if(!ws) ws = sf_header.idata;
    }

    if((ucell)ws->here % sizeof(cell)) {
        ws->here += sizeof(cell) - ((ucell)ws->here % sizeof(cell));
    }

    int narea = nlen + 2;
    if(narea % sizeof(cell)) {
        narea += sizeof(cell) - (narea % sizeof(cell));
    }
    narea /= sizeof(cell);
    cell *w = (cell*)ws->here + narea;
    next_word = w;
    *(cell**)w = *(cell**)wl_search_order[WL_SO_MAX-1];
    ((char*)w)[-1] = flags;
    memcpy((char*)w - 1 - nlen, name, nlen);
    ((char*)w)[-2-nlen] = 0;

    ++w;
    if(0 != (flags & (W_EXEC | W_RUNTIME))) {
        *(w++) = (cell)exec;
    }
    if(0 != (flags & W_EXTENDED)) {
        *(w++) = (cell)extended;
    }
    if(0 != (flags & W_DETACHED)) {
        *(w++) = (cell)sf_header.active_section->here;
    }
    ws->here = (void*)w;
}

void* forward_word() {
    if(((char*)next_word)[-2]) {
        *(cell**)wl_search_order[WL_SO_MAX-1] = next_word;
        return 0;
    }
    void* s = next_word;
    return s;
}
