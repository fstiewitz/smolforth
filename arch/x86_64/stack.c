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
    return (dcell) (((udcell) nh << (8 * sizeof(cell))) | (udcell) nl);
}

void dpush(dcell v, char **st) {
    push((cell) (v & (((dcell) 1 << (8 * sizeof(cell))) - 1)), st);
    push((cell) (v >> (8 * sizeof(cell))), st);
}

udcell udpop(char **st) {
    ucell nh = upop(st);
    ucell nl = upop(st);
    return (((udcell) nh << (8 * sizeof(cell))) | (udcell) nl);
}

void udpush(udcell v, char **st) {
    upush((ucell) (v & (((udcell) 1 << (8 * sizeof(cell))) - 1)), st);
    upush((ucell) (v >> (8 * sizeof(cell))), st);
}

cell bpop(char **st) {
    *st += sizeof(cell);
    return ((cell *) *st)[-1];
}

void bpush(cell v, char **st) {
    *st -= sizeof(cell);
    *(cell *) *st = v;
}

ucell bupop(char **st) {
    *st += sizeof(ucell);
    return ((ucell *) *st)[-1];
}

void bupush(ucell v, char **st) {
    *st -= sizeof(ucell);
    *(ucell *) *st = v;
}

dcell bdpop(char **st) {
    ucell nh = bupop(st);
    ucell nl = bupop(st);
    return (dcell) (((udcell) nh << (8 * sizeof(cell))) | (udcell) nl);
}

void bdpush(dcell v, char **st) {
    bpush((cell) (v & (((dcell) 1 << (8 * sizeof(cell))) - 1)), st);
    bpush((cell) (v >> (8 * sizeof(cell))), st);
}

udcell budpop(char **st) {
    ucell nh = bupop(st);
    ucell nl = bupop(st);
    return (((udcell) nh << (8 * sizeof(cell))) | (udcell) nl);
}

void budpush(udcell v, char **st) {
    bupush((ucell) (v & (((udcell) 1 << (8 * sizeof(cell))) - 1)), st);
    bupush((ucell) (v >> (8 * sizeof(cell))), st);
}
