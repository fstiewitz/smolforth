#ifndef SF_HAS_EMBEDDED
#ifndef SF_HAS_FREESTANDING
void dump_argv(char** st, char** rst) {
    for(int i = sf_argc - 1; i >= 0; --i) {
        upush(sf_argv[i], st);
        upush(strlen(sf_argv[i]), st);
    }
    push(sf_argc, st);
}
#endif
#endif
