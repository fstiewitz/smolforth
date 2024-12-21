#include<config.h>

cell pop(char **st) {
    *st -= sizeof(cell);
    return *(cell *) *st;
}

void push(cell v, char **st) {
    *(cell *) *st = v;
    *st += sizeof(cell);
}

ucell upop(char **st) {
    *st -= sizeof(ucell);
    return *(ucell *) *st;
}

void upush(ucell v, char **st) {
    *(ucell *) *st = v;
    *st += sizeof(ucell);
}

dcell dpop(char **st) {
    ucell nh = upop(st);
    ucell nl = upop(st);
    return (dcell) (((udcell) nh << CELL_WIDTH) | (udcell) nl);
}

void dpush(dcell v, char **st) {
    push((cell) (v & (((dcell) 1 << CELL_WIDTH) - 1)), st);
    push((cell) (v >> CELL_WIDTH), st);
}

udcell udpop(char **st) {
    ucell nh = upop(st);
    ucell nl = upop(st);
    return (((udcell) nh << CELL_WIDTH) | (udcell) nl);
}

void udpush(udcell v, char **st) {
    upush((ucell) (v & (((udcell) 1 << CELL_WIDTH) - 1)), st);
    upush((ucell) (v >> CELL_WIDTH), st);
}
