#ifndef SMOLFORTH_CONFIG_H
#define SMOLFORTH_CONFIG_H

#include<stdint.h>

#include<config-local.h>

udcell sf_to_c(char *st, char *rst, udcell (*f)(char *st, char *rst));
udcell c_to_sf(char *st, char *rst, udcell (*f)(char *st, char *rst));

#define DECLARE(X) udcell X(char* st, char* rst);
#define SFIMPL(X) udcell X##_impl_c(char* st, char* rst)

void* to_body(void* ptr);

void make_word(char* name, int nlen, int flags, void* exec, void* extended);
void* forward_word();

enum {
    SECTION_CDATA = 1,
    SECTION_IDATA = 2,
    SECTION_UDATA = 4,
};

struct sf_data_t {
    void* start;
    void* gate;
    char* here;
    void* end;
    ucell flags;
    void* word;
};

struct sf_header_t {
    cell state;
    cell errno;
    char* err_str;
    ucell err_size;
    cell compiler_status;
    cell source_id;
    cell blk;
    cell base;
    struct sf_data_t code;
    struct sf_data_t *active_section;
    /*
     * VARIABLE -> UIDATA
     * :[NONAME] -> CDATA
     * [>]CREATE -> ADATA
     * CONSTANT -> IDATA
     * VALUE -> ICDATA
     * BUFFER -> UDATA
     */
    struct sf_data_t *cdata;
    struct sf_data_t *idata;
    struct sf_data_t *udata;
    struct sf_data_t *wdata;
    struct sf_data_t *uidata;
    struct sf_data_t *icdata;
    char* line_ptr;
    ucell line_size;
    ucell handler;
    void* stack_ptr;
    ucell stack_size;
    void* return_stack_ptr;
    ucell return_stack_size;
    ucell csri;
    char po[256];
};

extern struct sf_header_t sf_header;

cell pop(char **st);
void push(cell v, char **st);
ucell upop(char **st);
void upush(ucell v, char **st);
dcell dpop(char **st);
void dpush(dcell v, char **st);
udcell udpop(char **st);
void udpush(udcell v, char **st);

cell bpop(char **st);
void bpush(cell v, char **st);
ucell bupop(char **st);
void bupush(ucell v, char **st);
dcell bdpop(char **st);
void bdpush(dcell v, char **st);
udcell budpop(char **st);
void budpush(udcell v, char **st);

void c_store(signed reg, ucell v);

udcell dummy_abort(char* st, char* rst);
void print_stacks(char* st, char* rst);

#define W_IMMEDIATE 1
#define W_ADDR 2
#define W_CONSTANT 4
#define W_PUSH_MASK 14
#define W_EXEC 16
#define W_CREATE (W_ADDR+W_EXEC)
#define W_RUNTIME 32
#define W_DETACHED 64
#define W_EXTENDED 128

#define WL_SO_MAX 16
extern void* wl_search_order[WL_SO_MAX];

union ret {
    udcell r;
    struct {
        ucell a0;
        ucell a1;
    };
};
#define RETURN(st, rst)  \
    union ret _r;        \
    _r.a0 = (ucell) st;  \
    _r.a1 = (ucell) rst; \
    return _r.r

#define SFCALL(st, rst, call)          \
    {                                  \
        union ret _r;                  \
        _r.r = sf_to_c(st, rst, call); \
        st = (char *) _r.a0;           \
        rst = (char *) _r.a1;          \
    }

#endif //SMOLFORTH_CONFIG_H
