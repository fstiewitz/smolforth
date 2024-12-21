#include<algorithm>
#include<stdio.h>
#include<elf.h>
#include <vector>
#include <tuple>
#include <cstring>
#include <elf.h>
#include <fstream>
#include <iostream>
#include <stack>
#include <sstream>
#include <map>
#include <variant>
#include <charconv>
#include <assert.h>
#include <elf.h>
#include <vector>
#include <set>

#ifdef TARGET_X86_64
#define ELFCLASSX ELFCLASS64
#define MACHINE EM_X86_64
#define FRELOC R_X86_64_64
#define uintX_t uint64_t
#define intX_t int64_t
#define ElfX_Ehdr Elf64_Ehdr
#define ElfX_Shdr Elf64_Shdr
#define ElfX_Rela Elf64_Rela
#define ElfX_Sym Elf64_Sym
#define ElfX_Half Elf64_Half
#define ElfX_Word Elf64_Word
#define ElfX_Xword Elf64_Xword
#define ElfX_Addr Elf64_Addr
#define ElfX_Off Elf64_Off
#define ELFX_ST_INFO(A, B) ELF64_ST_INFO(A, B)
#define ELFX_R_INFO(A, B) ELF64_R_INFO(A, B)
#else
#ifdef TARGET_RV64
#define TARGET_RVX
#define ELFCLASSX ELFCLASS64
#define MACHINE EM_RISCV
#define FRELOC R_RISCV_64
#define uintX_t uint64_t
#define intX_t int64_t
#define ElfX_Ehdr Elf64_Ehdr
#define ElfX_Shdr Elf64_Shdr
#define ElfX_Rela Elf64_Rela
#define ElfX_Sym Elf64_Sym
#define ElfX_Half Elf64_Half
#define ElfX_Word Elf64_Word
#define ElfX_Xword Elf64_Xword
#define ElfX_Addr Elf64_Addr
#define ElfX_Off Elf64_Off
#define ELFX_ST_INFO(A, B) ELF64_ST_INFO(A, B)
#define ELFX_R_INFO(A, B) ELF64_R_INFO(A, B)
#else
#ifdef TARGET_RV32
#define TARGET_RVX
#define ELFCLASSX ELFCLASS32
#define MACHINE EM_RISCV
#define FRELOC R_RISCV_32
#define uintX_t uint32_t
#define intX_t int32_t
#define ElfX_Ehdr Elf32_Ehdr
#define ElfX_Shdr Elf32_Shdr
#define ElfX_Rela Elf32_Rela
#define ElfX_Sym Elf32_Sym
#define ElfX_Half Elf32_Half
#define ElfX_Word Elf32_Word
#define ElfX_Xword Elf32_Xword
#define ElfX_Addr Elf32_Addr
#define ElfX_Off Elf32_Off
#define ELFX_ST_INFO(A, B) ELF32_ST_INFO(A, B)
#define ELFX_R_INFO(A, B) ELF32_R_INFO(A, B)
#else
#error "Unknown architecture, please define TARGET"
#endif
#endif
#endif

std::map<std::string, std::string> wordlist_names_export {};
std::map<std::string, std::tuple<int, uintX_t, uintX_t>> section_limits0 {};
std::map<int, std::tuple<int, uintX_t, uintX_t, std::string>> section_limits {};

int in_any_section(uintX_t addr) {
	for(auto &[n, p] : section_limits) {
		auto &[flags, start, end, name] = p;
		if(start <= addr && addr < end) {
			return n;
		}
	}
	return -1;
}

uintX_t got_size;

std::map<std::string, uintX_t> local_symbols {};
std::multimap<std::string, std::tuple<uintX_t, uintX_t, int>> dup_symbols {};
std::map<std::string, std::tuple<uintX_t, uintX_t, int>> global_symbols {};
std::set<std::pair<std::string, uintX_t>> undefined_symbols {};
std::map<std::tuple<std::string, uintX_t>, uintX_t> global_symbol_assoc {};
std::map<uintX_t, std::tuple<std::string, intX_t, int, uintX_t, int>> relocations {};
std::map<uintX_t, uintX_t> wordlist_assoc {};
std::map<uintX_t, std::string> wordlist_names {};

void add_relocation(std::string name, uintX_t word_addr, intX_t addend, uintX_t from, int type) {
	auto t = std::make_tuple(name, addend, type, word_addr, 0);
	if(relocations.contains(from)) {
		if(relocations.at(from) != t) {
			std::cerr << "duplicate relocation mismatch@" << std::to_string(from) << " to " << name << std::endl;
		}
		assert(relocations.at(from) == t);
	} else {
		relocations[from] = t;
	}
}

void add_relocation(std::string name, uintX_t word_addr, intX_t addend, uintX_t from, int type, int l) {
	auto t = std::make_tuple(name, addend, type, word_addr, l);
	if(relocations.contains(from)) {
		if(relocations.at(from) != t) {
			std::cerr << "duplicate relocation mismatch@" << std::to_string(from) << " to " << name << std::endl;
		}
		assert(relocations.at(from) == t);
	} else {
		relocations[from] = t;
	}
}

std::string lnext(uintX_t addr) {
	static int ln = 0;
	std::string n = std::string(".L") + std::to_string(++ln);
	local_symbols[n] = addr;
	return n;
}

ElfX_Sym make_sym(uint32_t name, unsigned char info, unsigned char other, uint16_t shndx, ElfX_Addr value, uintX_t size) {
	ElfX_Sym sym;
	sym.st_name = name;
	sym.st_info = info;
	sym.st_other = other;
	sym.st_shndx = shndx;
	sym.st_value = value;
	sym.st_size = size;
	return sym;
}

uintX_t forth_addr = 0;

std::string qualify_wordlist_name(uintX_t addr) {
	if(wordlist_assoc.contains(addr) && wordlist_assoc.at(addr) != addr && wordlist_assoc.at(addr) != forth_addr) {
		return qualify_wordlist_name(wordlist_assoc.at(addr)) + "$" + wordlist_names.at(addr);
	} else {
		return wordlist_names.at(addr);
	}
}

void save_obj() {
	std::ofstream ofd {"out.h", std::ios_base::out};
	for(auto &[wl, wl_end] : wordlist_names_export) {
		ofd << "#define sf_" << wl << "_end " << wl << "$" << wl_end << std::endl;
		ofd << "extern char " << wl << "$" << wl_end << ";" << std::endl;
	}
	ofd << "#define SF_WL_EXPORT_COUNT " <<wordlist_names_export.size() << std::endl;
	ofd << "#define SF_WL_EXPORTED ";
	{
		auto k = wordlist_names_export.begin();
		if(k != wordlist_names_export.end()) {
			ofd << "&sf_" << k->first << "_end";
			for(++k; k != wordlist_names_export.end(); ++k) {
				ofd << ", &sf_" << k->first << "_end";
			}
		}
	}
	/* determine full name of all words */
	/* determine full name of word lists */
	{
		for(auto &[addr, name] : wordlist_names) {
			if(name == "FORTH" && wordlist_assoc.contains(addr) && wordlist_assoc.at(addr) == addr) {
				forth_addr = addr;
			}
		}
		std::map<uintX_t, std::string> qwl {};
		for(auto &[addr, name] : wordlist_names) {
			qwl[addr] = qualify_wordlist_name(addr);
		}
		wordlist_names = std::move(qwl);
	}
	/* determine full name of all symbols */
	{
		decltype(dup_symbols) qsymbols {};
		for(auto &[name, addr] : dup_symbols) {
			auto &[b, w, l] = addr;
			auto saddr = std::get<1>(addr);
			if(wordlist_assoc.contains(saddr)) {
				if(saddr != wordlist_assoc.at(saddr)) {
					qsymbols.emplace(qualify_wordlist_name(wordlist_assoc.at(saddr)) + "$" + name, addr);
				} else {
					qsymbols.emplace(name, addr);
				}
			} else {
				qsymbols.emplace(name, addr);
			}
		}
		dup_symbols = std::move(qsymbols);
		for(auto &[n, a] : dup_symbols) {
			fprintf(stderr, "%s\t\tL %lx %lx\r\n", n.c_str(), std::get<0>(a), std::get<1>(a));
		}
	}
	/* determine global symbols */
	{
		decltype(global_symbol_assoc) gsym {};
		for(auto &[k, sym] : global_symbol_assoc) {
			auto &[name, wl] = k;
			if(wordlist_assoc.contains(sym)) {
				if(sym != wordlist_assoc.at(sym)) {
					gsym[std::make_tuple(qualify_wordlist_name(wordlist_assoc.at(sym)) + "$" + name, wl)] = sym;
				} else {
					gsym[std::make_tuple(name, wl)] = sym;
				}
			} else {
				gsym[std::make_tuple(name, wl)] = sym;
			}
		}
		global_symbol_assoc = std::move(gsym);
		for(auto &[k, sym] : global_symbol_assoc) {
			auto &[name, wl] = k;
			auto r = dup_symbols.equal_range(name);
			for(; r.first != r.second; ++r.first) {
				auto &[b, w, l] = r.first->second;
				if(w == sym) {
					global_symbols.emplace(r.first->first, r.first->second);
				}
			}
		}
		for(auto &[n, a] : global_symbols) {
			fprintf(stderr, "%s\t\tG %lx %lx\r\n", n.c_str(), std::get<0>(a), std::get<1>(a));
		}
	}
	/* determine full name of all relocations */
	{
		std::map<uintX_t, std::tuple<std::string, intX_t, int, uintX_t, int>> qrelocations {};
		for(auto &[addr, d] : relocations) {
			auto &[name, addend, type, wl, l] = d;
			if(wordlist_assoc.contains(wl)) {
				if(wl != wordlist_assoc.at(wl)) {
					qrelocations[addr] = std::make_tuple(qualify_wordlist_name(wordlist_assoc.at(wl)) + "$" + name, addend, type, wl, l);
				} else {
					qrelocations[addr] = d;
				}
			} else {
				qrelocations[addr] = d;
			}
		}
		relocations = std::move(qrelocations);
	}
	section_limits.clear();
	{
		int i = 0;
		for(auto &[n, t] :section_limits0) {
			section_limits[i++] = std::tuple_cat(t, std::make_tuple(n));
		}
	}
	std::erase_if(section_limits, [](auto &e) {
		auto &[flags, start, end, n] = e.second;
		return start == end;
	});
	// remove relocations outside of any section
	std::erase_if(relocations, [](auto &e) {
		auto a = e.first;
		return -1 == in_any_section(a);
	});
	// add undefined symbols from relocation entries
	for(auto &[addr, r] : relocations) {
		auto &[name, addend, flags, wl, l] = r;
		if(!dup_symbols.contains(name)) {
			undefined_symbols.emplace(name, wl);
		}
	}
	fprintf(stderr, "saving OBJ\n");

	ElfX_Ehdr header = {
		.e_type = ET_REL,
		.e_machine = MACHINE,
		.e_version = EV_CURRENT,
		.e_entry = 0,
		.e_phoff = 0,
		.e_shoff = 0,
		#ifdef TARGET_RVX
		.e_flags = EF_RISCV_FLOAT_ABI_DOUBLE,
		#else
		.e_flags = 0,
		#endif
		.e_ehsize = sizeof(header),
		.e_phentsize = 0,
		.e_phnum = 0,
		.e_shentsize = sizeof(ElfX_Shdr),
		.e_shnum = 3, // at least .symtab, .strtab and .shstrtab
		.e_shstrndx = 0
	};
	header.e_ident[EI_MAG0] = ELFMAG0;
	header.e_ident[EI_MAG1] = ELFMAG1;
	header.e_ident[EI_MAG2] = ELFMAG2;
	header.e_ident[EI_MAG3] = ELFMAG3;
	header.e_ident[EI_CLASS] = ELFCLASSX;
	header.e_ident[EI_DATA] = ELFDATA2LSB;
	header.e_ident[EI_VERSION] = EV_CURRENT;
	header.e_ident[EI_OSABI] = ELFOSABI_SYSV;

	ElfX_Off next_file_pos = sizeof(header);

	std::string string_table{};
	std::string sh_string_table{};

	std::vector<ElfX_Shdr> sections;
	sections.push_back(ElfX_Shdr{
		static_cast<ElfX_Word>(string_table.size()),
					   SHT_NULL,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0 });

	string_table.push_back(0);
	sh_string_table.push_back(0);

	for(auto &[section, limits] : section_limits) {
		auto &[flags, start, end, n] = limits;
		ElfX_Shdr hdr{
			static_cast<ElfX_Word>(sh_string_table.size()),
			SHT_PROGBITS,
			0,
			0,
			0,
			static_cast<uintX_t>(end - start),
			0,
			0,
			sizeof(uintX_t),
			0
		};
		std::string name = ".bss";
		if(0 != (flags & 2)) { // IDATA
			hdr.sh_flags |= SHF_ALLOC | SHF_WRITE;
			name = ".data";
		}
		if(0 != (flags & 1)) { // CDATA
			hdr.sh_flags |= SHF_ALLOC | SHF_EXECINSTR;
			name = ".text";
		}
		if(0 != (flags & 3)) {
			hdr.sh_offset = next_file_pos;
			next_file_pos += hdr.sh_size;
		}

		sh_string_table += name + "." + n;
		sh_string_table.push_back(0);
		sections.push_back(hdr);
	}

	for(auto &section : sections) {
		section.sh_link = sections.size() + 1;
	}

	std::vector<ElfX_Sym> symbol_table{};
	std::vector<std::tuple<std::string, uintX_t, int>> symbol_indices {};
	symbol_table.push_back(ElfX_Sym {0});
	int local_symbol_count = 0;
	for(auto &[name, addr] : local_symbols) {
		auto s = in_any_section(addr);
		if(s == -1) continue;
		++local_symbol_count;
		symbol_table.push_back(make_sym(
			static_cast<ElfX_Word>(string_table.size()),
										ELFX_ST_INFO(STB_LOCAL, STT_FUNC),
										STV_DEFAULT,
								  s + 1,
								  addr - std::get<1>(section_limits.at(s)),
										0 ));
		string_table += name;
		string_table.push_back(0);
		symbol_indices.emplace_back(name, 0, 1);
	}
	for(auto &[name, addr_pair] : dup_symbols) {
		auto &[addr, wl_addr, local] = addr_pair;
		if(addr != -1 && local) {
			auto s = in_any_section(addr);
			if(s == -1) {
				std::cerr << "UNDEFINED SYMBOL WHERE DEFINED SYMBOL EXPECTED: " << name << "@" << std::to_string(addr) << std::endl;
			}
			assert(s != -1);
			++local_symbol_count;
			symbol_table.push_back(make_sym(
				static_cast<ElfX_Word>(string_table.size()),
											ELFX_ST_INFO(STB_LOCAL, STT_FUNC),
											STV_DEFAULT,
								   s + 1,
								   addr - std::get<1>(section_limits.at(s)),
											0));
			string_table += name;
			string_table.push_back(0);
			symbol_indices.emplace_back(name, wl_addr, local);
		}
	}
	for(auto &[name, addr_pair] : dup_symbols) {
		auto &[addr, wl_addr, local] = addr_pair;
		if(addr != -1 && !local && !global_symbols.contains(name)) {
			auto s = in_any_section(addr);
			if(s == -1) {
				std::cerr << "UNDEFINED SYMBOL WHERE DEFINED SYMBOL EXPECTED: " << name << "@" << std::to_string(addr) << std::endl;
			}
			assert(s != -1);
			++local_symbol_count;
			symbol_table.push_back(make_sym(
				static_cast<ElfX_Word>(string_table.size()),
											ELFX_ST_INFO(STB_GLOBAL, STT_FUNC),
											STV_DEFAULT,
								   s + 1,
								   addr - std::get<1>(section_limits.at(s)),
											0));
			string_table += name;
			string_table.push_back(0);
			symbol_indices.emplace_back(name, wl_addr, local);
		}
	}
	for(auto &[name, addr_pair] : global_symbols) {
		auto &[addr, wl_addr, local] = addr_pair;
		if(addr != -1) {
			auto s = in_any_section(addr);
			if(s == -1) {
				std::cerr << "UNDEFINED SYMBOL WHERE DEFINED SYMBOL EXPECTED: " << name << "@" << std::to_string(addr) << std::endl;
			}
			assert(s != -1);
			symbol_table.push_back(make_sym(
				static_cast<ElfX_Word>(string_table.size()),
											ELFX_ST_INFO(STB_GLOBAL, STT_FUNC),
											STV_DEFAULT,
								   s + 1,
								   addr - std::get<1>(section_limits.at(s)),
											0));
			string_table += name;
			string_table.push_back(0);
			symbol_indices.emplace_back(name, wl_addr, 0);
		}
	}
	for(auto &[name, wl_addr] : undefined_symbols) {
			symbol_table.push_back(make_sym(
				static_cast<ElfX_Word>(string_table.size()),
											ELFX_ST_INFO(STB_GLOBAL, STT_NOTYPE),
											STV_DEFAULT,
								   0,
								   0,
								   0));
			string_table += name;
			string_table.push_back(0);
			symbol_indices.emplace_back(name, wl_addr, 0);
	}

	Elf64_Word symtab = sections.size();
	sections.push_back(ElfX_Shdr{
		static_cast<ElfX_Word>(sh_string_table.size()),
					   SHT_SYMTAB,
					0,
					0,
					next_file_pos,
					symbol_table.size() * sizeof(ElfX_Sym),
					   static_cast<Elf64_Word>(symtab + 1),
					   1 + (ElfX_Word)local_symbol_count,
					   0,
					sizeof(ElfX_Sym) });

	sh_string_table += ".symtab";
	sh_string_table.push_back(0);
	next_file_pos += symbol_table.size() * sizeof(ElfX_Sym);

	std::vector<std::vector<ElfX_Rela>> relocations_data_vector {};

	Elf64_Word i = 0;
	for(auto &[section, limits] : section_limits) {
		++i;
		auto &[flags, start, end, n] = limits;
		std::vector<ElfX_Rela> relocations_data {};

		for(auto &[addr, r] : relocations) {
			auto &[name, addend, flags, wl, l] = r;
			auto s = in_any_section(addr);
			if(s != section) continue;
			auto &[f, start, end, n] = section_limits.at(s);
			auto idx_it = std::find(symbol_indices.begin(), symbol_indices.end(), std::make_tuple(name, wl, l));
			if(idx_it == symbol_indices.end()) {
				if(l) {
					idx_it = std::find(symbol_indices.begin(), symbol_indices.end(), std::make_tuple(name, wl, 0));
					if(idx_it == symbol_indices.end()) {
						fprintf(stderr, "COULD NOT FIND LOCAL SYMBOL FOR %s@%lx\r\n", name.c_str(), wl);
					}
				} else {
					if(global_symbols.contains(name)) {
						auto s = global_symbols[name];
						idx_it = std::find(symbol_indices.begin(), symbol_indices.end(), std::make_tuple(name, std::get<1>(s), l));
						if(idx_it == symbol_indices.end()) goto err;
					} else {
						err:
						fprintf(stderr, "COULD NOT FIND GLOBAL SYMBOL FOR %s@%lx\r\n", name.c_str(), wl);
					}
				}
			}
			assert(idx_it != symbol_indices.end());
			relocations_data.push_back(ElfX_Rela {
				.r_offset = addr - start,
				.r_info = ELFX_R_INFO(1 + idx_it - symbol_indices.begin(), flags),
									   .r_addend = addend
			});
		}

		if(relocations_data.empty()) continue;

		sections.push_back(ElfX_Shdr{
			static_cast<ElfX_Word>(sh_string_table.size()),
						   SHT_RELA,
					 0,
					 0,
					 next_file_pos,
					 relocations_data.size() * sizeof(ElfX_Rela),
						   symtab,
						   i,
						   8,
					 sizeof(ElfX_Rela) });

		next_file_pos += relocations_data.size() * sizeof(ElfX_Rela);
		sh_string_table += ".rela." + n;
		sh_string_table.push_back(0);
		relocations_data_vector.emplace_back(std::move(relocations_data));
	}

	sections.push_back(ElfX_Shdr{
		static_cast<ElfX_Word>(sh_string_table.size()),
					   SHT_STRTAB,
					0,
					0,
					next_file_pos,
					string_table.size(),
					   0,
					0,
					1,
					0 });

	sh_string_table += ".strtab";
	sh_string_table.push_back(0);
	next_file_pos += string_table.size();
	sections[symtab].sh_link = sections.size() - 1;

	sections.push_back(ElfX_Shdr{
		static_cast<ElfX_Word>(sh_string_table.size()),
					   SHT_STRTAB,
					0,
					0,
					next_file_pos,
					sh_string_table.size() + strlen(".shstrtab") + 1,
					   0,
					0,
					1,
					0 });

	sh_string_table += ".shstrtab";
	sh_string_table.push_back(0);
	next_file_pos += sh_string_table.size();


	header.e_shoff = next_file_pos;
	header.e_shnum = sections.size();
	header.e_shstrndx = header.e_shnum - 1;

	std::ofstream fd{ "out.o" };
	fd.write(reinterpret_cast<const char *>(&header), sizeof(header));

	for(auto &[ix, limits] : section_limits) {
		auto &[flags, start, end, name] = limits;
		if(0 != (flags & 3)) {
			std::ifstream bd {"out." + name + "." + std::to_string(flags) + ".bin"};
			fd << bd.rdbuf();
		}
	}

	fd.write(reinterpret_cast<const char *>(symbol_table.data()), symbol_table.size() * sizeof(ElfX_Sym));

	for(auto &v : relocations_data_vector) {
		fd.write(reinterpret_cast<const char*>(v.data()), v.size() * sizeof(ElfX_Rela));
	}

	fd.write(string_table.c_str(), string_table.size());
	fd.write(sh_string_table.c_str(), sh_string_table.size());

	for (auto &s: sections) {
		fd.write(reinterpret_cast<const char *>(&s), sizeof(s));
	}
}

void symbol(std::stack<std::variant<uintX_t, std::string>> st, int local_flag) {
	auto name = std::get<std::string>(st.top());
	st.pop();
	if(name.empty()) return;
	auto word_addr = std::get<uintX_t>(st.top());
	st.pop();
	auto addr = std::get<uintX_t>(st.top());
	st.pop();
	if(name == "UNKNOWN") return;
	dup_symbols.emplace(name, std::make_tuple(addr, word_addr, local_flag));
}

void reloc_execute(std::stack<std::variant<uintX_t, std::string>> st, int local_flag) {
	assert(st.size() == 5);
	auto reloc = std::get<uintX_t>(st.top());
	st.pop();
	auto name = std::get<std::string>(st.top());
	st.pop();
	if(name.empty()) return;
	auto word_addr = (intX_t)std::get<uintX_t>(st.top());
	st.pop();
	auto addend = (intX_t)std::get<uintX_t>(st.top());
	st.pop();
	auto addr = std::get<uintX_t>(st.top());
	st.pop();
	#ifdef TARGET_X86_64
	switch(reloc) {
		case 0:
			add_relocation(name, word_addr, addend - 4, addr + 1, R_X86_64_PC32, local_flag);
			break;
		case 1:
			add_relocation(name, word_addr, addend, addr + 2, R_X86_64_64, local_flag);
			break;
		default:
			std::cerr << "unknown relocation type " << std::to_string(reloc) << std::endl;
			break;
	}
	#else
	#ifdef TARGET_RVX
	switch(reloc) {
		case 0:
			add_relocation(name, word_addr, addend, addr, R_RISCV_CALL, local_flag);
			break;
		case 1:
			add_relocation(name, word_addr, addend, addr, R_RISCV_JAL, local_flag);
			break;
		default:
			std::cerr << "unknown relocation type " << std::to_string(reloc) << std::endl;
			break;
	}
	#endif
	#endif
}

void reloc_addr(std::stack<std::variant<uintX_t, std::string>> st, int local_flag) {
	assert(st.size() == 5);
	auto reloc = std::get<uintX_t>(st.top());
	st.pop();
	auto name = std::get<std::string>(st.top());
	st.pop();
	if(name.empty()) return;
	auto word_addr = (intX_t)std::get<uintX_t>(st.top());
	st.pop();
	auto addend = (intX_t)std::get<uintX_t>(st.top());
	st.pop();
	auto addr = std::get<uintX_t>(st.top());
	st.pop();
	#ifdef TARGET_X86_64
	switch(reloc) {
		case 0:
			add_relocation(name, word_addr, addend - 4, addr + 3, R_X86_64_GOTPCREL, local_flag);
			break;
		case 1:
			add_relocation(name, word_addr, addend - 4, addr + 3, R_X86_64_PC32, local_flag);
			break;
		default:
			std::cerr << "unknown relocation type " << std::to_string(reloc) << std::endl;
			break;
	}
	#else
	#ifdef TARGET_RVX
	switch(reloc) {
		case 0: {
			auto s = lnext(addr);
			add_relocation(name, word_addr, addend, addr, R_RISCV_PCREL_HI20, local_flag);
			add_relocation(s, 0, 0, addr + 4, R_RISCV_PCREL_LO12_I, 1);
			break;
		}
		case 1: {
			auto s = lnext(addr);
			add_relocation(name, word_addr, 0, addr, R_RISCV_GOT_HI20, local_flag);
			add_relocation(s, 0, 0, addr + 4, R_RISCV_PCREL_LO12_I, 1);
			break;
		}
		case 3: {
			add_relocation(name, word_addr, addend, addr, R_RISCV_PCREL_HI20, local_flag);
			break;
		}
		default:
			std::cerr << "unknown relocation type " << std::to_string(reloc) << std::endl;
			break;
	}
	#endif
	#endif
}

void reloc(std::stack<std::variant<uintX_t, std::string>> st, int local_flag) {
	if(std::get_if<uintX_t>(&st.top())) {
		return;
	}
	assert(st.size() == 5);
	auto name = std::get<std::string>(st.top());
	st.pop();
	if(name.empty()) return;
	auto word_addr = (intX_t)std::get<uintX_t>(st.top());
	st.pop();
	auto addend = (intX_t)std::get<uintX_t>(st.top());
	st.pop();
	auto to = std::get<uintX_t>(st.top());
	st.pop();
	auto from = std::get<uintX_t>(st.top());
	st.pop();
	add_relocation(name, word_addr, addend, from, FRELOC, local_flag);
}


int main() {
	std::ifstream fd {"out.txt"};
	std::string wl_end {};
	std::string csection;
	std::vector<std::pair<std::string, uintX_t>> wl_assocs {};
	for(std::string s; std::getline(fd, s);) {
		// std::cerr << "line " << s << std::endl;
		std::stack<std::variant<uintX_t, std::string>> st {};
		int local_flag = 0;
		int n = 0;
		bool quoting = false;
		while(n < s.size()) {
			if(isspace(s[n])) {
				++n;
			} else {
				int ts = n;
				++n;
				while(n < s.size() && !isspace(s[n])) ++n;
				std::string_view ss = std::string_view(s).substr(ts, n - ts);
				if(quoting) {
					st.emplace(std::string(ss));
					quoting = false;
				} else {
					if(ss == "QUOTE") {
						quoting = true;
					} else if(ss == "LOCAL") {
						local_flag = 1;
					} else if(ss == "SYMBOL") {
						symbol(std::move(st), local_flag);
					} else if(ss == "SECTION") {
						auto flags = std::get<uintX_t>(st.top());
						st.pop();
						csection = std::get<std::string>(st.top());
						st.pop();
						section_limits0[csection] = std::make_tuple(flags, 0, 0);
					} else if(ss == "LIMIT") {
						auto end = std::get<uintX_t>(st.top());
						st.pop();
						auto start = std::get<uintX_t>(st.top());
						st.pop();
						if(start != end) {
							std::get<1>(section_limits0[csection]) = start;
							std::get<2>(section_limits0[csection]) = end;
						} else {
							section_limits0.erase(csection);
						}
					} else if(ss == "WORDLIST") {
						auto wl = std::get<std::string>(st.top());
						if(!wl_end.empty()) {
							wordlist_names_export[wl] = wl_end;
						}
						wl_end = "";
					} else if(ss == "RELOC") {
						reloc(std::move(st), local_flag);
					} else if(ss == "RELOC-EXECUTE") {
						reloc_execute(std::move(st), local_flag);
					} else if(ss == "RELOC-ADDR") {
						reloc_addr(std::move(st), local_flag);
					} else if(ss == "RELOC-CONSTANT") {
						// TODO
					} else if(ss == "WL-ASSOC:START") {
						wl_assocs.clear();
					} else if(ss == "WL-ASSOC:SYMBOL") {
						auto n = std::get<std::string>(st.top());
						st.pop();
						auto addr = std::get<uintX_t>(st.top());
						st.pop();
						st.pop();
						wl_assocs.emplace_back(n, addr);
					} else if(ss == "WL-ASSOC:WORDLIST") {
						auto wl = std::get<std::string>(st.top());
						st.pop();
						auto addr = std::get<uintX_t>(st.top());
						st.pop();
						wordlist_names[addr] = wl;
						for(auto &[n, a] : wl_assocs) {
							if(!global_symbol_assoc.contains(std::make_tuple(n, addr))) {
								global_symbol_assoc[std::make_tuple(n, addr)] = a;
							}
							wordlist_assoc[a] = addr;
						}
						wl_assocs.clear();
					} else if(ss == "WL-END") {
						wl_end = std::get<std::string>(st.top());
						st.pop();
					} else if(ss == "\\") {
						break;
					} else if(ss == "(") {
						n = s.find(')', n);
						if(n == std::string::npos) {
							break;
						}
						++n;
					} else {
						uintX_t v = 0;
						auto ec = std::from_chars(ss.begin(), ss.end(), v, 16);
						if(ec.ptr != ss.end()) {
							std::cerr << "error in token " << ss << std::endl;
						}
						st.emplace((uintX_t)v);
					}
				}
			}
		}
	}
	save_obj();
	return 0;
}
