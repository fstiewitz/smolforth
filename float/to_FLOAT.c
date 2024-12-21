#include <config.h>
#include <float/float.h>

#include <alloca.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

SFWRAPFUN(to_FLOAT)

udcell to_FLOAT_impl_c(char* st, char* rst) {
    ucell l = upop(&st);
    char* addr = (char*)upop(&st);
    if(l == 0) {
        fpush(0);
        push(-1, &st);
    } else {
        int has_non_space = 0;
        int has_space = 0;
        int has_e = 0;
        int has_sign = 0;
        for(ucell i = 0; i < l; ++i) {
            switch(addr[i]) {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                case '.':
                case 'e':
                case 'E':
                case 'd':
                case 'D':
                case '+':
                case '-':
                case ' ':
                    break;
                default:
                    push(0, &st);
                    RETURN(st, rst);
                    break;
            }
            if(isspace(addr[i])) has_space = 1;
            else has_non_space = 1;
            if(has_non_space && has_space) {
                push(0, &st);
                RETURN(st, rst);
            }
            if(isspace(addr[i])) continue;
            switch(addr[i]) {
                case 'e':
                case 'E':
                case 'd':
                case 'D':
                    if(has_e) {
                        push(0, &st);
                        RETURN(st, rst);
                    }
                    has_e = 1;
                    break;
                case '+':
                case '-':
                    if(i) has_sign = 1;
                    break;
            }
        }
        if(!has_non_space && has_space) {
            fpush(0);
            push(-1, &st);
            RETURN(st, rst);
        }

        ucell k = l + 1 + ((has_sign && !has_e) ? 1 : 0);
        char* m = alloca(k);
        ucell j = 0;
        for(ucell i = 0; i < l; ++i) {
            switch(addr[i]) {
                case 'd':
                case 'D':
                    m[j++] = 'E';
                    break;
                case '+':
                case '-':
                    if(i && has_sign && !has_e) {
                        m[j++] = 'E';
                    }
                    m[j++] = addr[i];
                    break;
                default:
                    m[j++] = addr[i];
                    break;
            }
        }
        m[k - 1] = 0;
        fcell d;
#if FCELL_WIDTH == 32
        if(1 == sscanf(m, "%f", &d)) {
#elif FCELL_WIDTH == 64
        if(1 == sscanf(m, "%lf", &d)) {
#else
#error "Unknown FCELL_WIDTH value"
#endif
            fpush(d);
            push(-1, &st);
        } else {
            push(0, &st);
        }
    }
    RETURN(st, rst);
}
