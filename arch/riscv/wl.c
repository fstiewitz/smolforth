#include<config.h>

extern ucell FORTH;

void* wl_search_order[WL_SO_MAX] = {
    (&FORTH + 2),
    0
};
