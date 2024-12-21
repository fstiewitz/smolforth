#include <stdio.h>
#include <sys/mman.h>
#include <elf.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>

bool process32(int argc, char **argv, char *mem, __off_t size);
bool process64(int argc, char **argv, char *mem, __off_t size);

static void print_help() {
    fprintf(stderr, "Usage: make-elf-writable path sections...\n");
    exit(1);
}

int main(int argc, char** argv) {
    if(argc < 3) print_help();
    int fd = open(argv[1], O_RDWR);
    if(fd == -1) {
        perror("could not open ELF file");
        goto err0;
    }
    struct stat s;
    if(-1 == fstat(fd, &s)) {
        perror("could not stat ELF file");
        goto err0;
    }
    char* mem = NULL;
    if(s.st_size <= sizeof(Elf32_Ehdr)) {
        fprintf(stderr, "ELF file way too small\n");
        goto err1;
    }
    mem = mmap(NULL, s.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if(mem == MAP_FAILED) {
        perror("could not map ELF file");
        goto err1;
    }
    if(strncmp(mem, "\x7f" "ELF", 4) != 0) {
        fprintf(stderr, "ELF file has wrong magic number\n");
        goto err1;
    }
    switch(mem[4]) {
        case ELFCLASS32:
            if(process32(argc - 2, argv + 2, mem, s.st_size)) goto err1;
            break;
        case ELFCLASS64:
            if(process64(argc - 2, argv + 2, mem, s.st_size)) goto err1;
            break;
        case ELFCLASSNONE:
            fprintf(stderr, "invalid ELF class\n");
            goto err1;
    }
    munmap(mem, s.st_size);
    close(fd);
    return 0;
    err1:
    munmap(mem, s.st_size);
    err0:
    close(fd);
    return 1;
}

#define VERIFYSIZE(O, T) do { \
    if(O + sizeof(T) > size) {\
        fprintf(stderr, "ELF file truncated? - tried to access %x+sizeof(%s) in file of size %x\n", O, #T, size);                      \
        return 1;                 \
    }\
} while(0)

bool process32l(char *section, Elf32_Ehdr *hdr, char *mem, __off_t size) {
    Elf32_Phdr *phdr = (Elf32_Phdr *) (mem + hdr->e_phoff);
    VERIFYSIZE(hdr->e_phoff + (hdr->e_phnum - 1) * hdr->e_phentsize, Elf32_Phdr);
    Elf32_Shdr *shdr = (Elf32_Shdr *) (mem + hdr->e_shoff);
    VERIFYSIZE(hdr->e_shoff + (hdr->e_shnum - 1) * hdr->e_shentsize, Elf32_Shdr);
    Elf32_Shdr *shstr = shdr + hdr->e_shstrndx;
    if(shstr->sh_offset == 0) return 0;
    char* shn = mem + shstr->sh_offset;
    VERIFYSIZE(shstr->sh_offset + shstr->sh_size, char);
    for(int i = 0; i < hdr->e_shnum; ++i) {
        Elf32_Shdr *sec = shdr + i;
        VERIFYSIZE(shstr->sh_offset + sec->sh_name + strlen(section), char);
        if(memcmp(section, shn + sec->sh_name, strlen(section)) == 0) {
            sec->sh_flags |= SHF_WRITE;
            fprintf(stderr, "found section %s (%x+%x), made writable\n", section, sec->sh_offset, sec->sh_size);
            Elf32_Off moffset = sec->sh_offset;
            Elf32_Word msize = sec->sh_size;
            Elf32_Off mend = moffset + msize;
            for(int j = 0; j < hdr->e_phnum; ++j) {
                Elf32_Phdr *psec = phdr + j;
                if(psec->p_offset <= moffset && psec->p_offset + psec->p_filesz > mend) {
                    psec->p_flags |= PF_W;
                    fprintf(stderr, "found program section %s (%x+%x), made writable\n", section, psec->p_offset, psec->p_filesz);
                }
            }
            break;
        }
    }
    return 0;
}

bool process32(int argc, char **argv, char *mem, __off_t size) {
    Elf32_Ehdr *hdr = (Elf32_Ehdr *) mem;
    VERIFYSIZE(0, Elf32_Ehdr);
    if(hdr->e_phentsize < sizeof(Elf32_Phdr)) return 1;
    if(hdr->e_shentsize < sizeof(Elf32_Shdr)) return 1;
    for(int i = 0; i < argc; ++i) {
        if(process32l(argv[i], hdr, mem, size)) return 1;
    }
    return 0;
}

bool process64l(char *section, Elf64_Ehdr *hdr, char *mem, __off_t size) {
    Elf64_Phdr *phdr = (Elf64_Phdr *) (mem + hdr->e_phoff);
    VERIFYSIZE(hdr->e_phoff + (hdr->e_phnum - 1) * hdr->e_phentsize, Elf64_Phdr);
    Elf64_Shdr *shdr = (Elf64_Shdr *) (mem + hdr->e_shoff);
    VERIFYSIZE(hdr->e_shoff + (hdr->e_shnum - 1) * hdr->e_shentsize, Elf64_Shdr);
    Elf64_Shdr *shstr = shdr + hdr->e_shstrndx;
    if(shstr->sh_offset == 0) return 0;
    char* shn = mem + shstr->sh_offset;
    VERIFYSIZE(shstr->sh_offset + shstr->sh_size, char);
    for(int i = 0; i < hdr->e_shnum; ++i) {
        Elf64_Shdr *sec = shdr + i;
        VERIFYSIZE(shstr->sh_offset + sec->sh_name + strlen(section), char);
        if(memcmp(section, shn + sec->sh_name, strlen(section)) == 0) {
            sec->sh_flags |= SHF_WRITE;
            fprintf(stderr, "found section %s (%lx+%lx), made writable\n", section, sec->sh_offset, sec->sh_size);
            Elf64_Off moffset = sec->sh_offset;
            Elf64_Word msize = sec->sh_size;
            Elf64_Off mend = moffset + msize;
            for(int j = 0; j < hdr->e_phnum; ++j) {
                Elf64_Phdr *psec = phdr + j;
                if(psec->p_offset <= moffset && psec->p_offset + psec->p_filesz > mend) {
                    psec->p_flags |= PF_W;
                    fprintf(stderr, "found program section %s (%lx+%lx), made writable\n", section, psec->p_offset, psec->p_filesz);
                }
            }
            break;
        }
    }
    return 0;
}

bool process64(int argc, char **argv, char *mem, __off_t size) {
    Elf64_Ehdr *hdr = (Elf64_Ehdr *) mem;
    VERIFYSIZE(0, Elf64_Ehdr);
    if(hdr->e_phentsize < sizeof(Elf64_Phdr)) return 1;
    if(hdr->e_shentsize < sizeof(Elf64_Shdr)) return 1;
    for(int i = 0; i < argc; ++i) {
        if(process64l(argv[i], hdr, mem, size)) return 1;
    }
    return 0;
}
