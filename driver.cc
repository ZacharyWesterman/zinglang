#include "driver.hh"
#include "parser.hh"

driver::driver () : trace_parsing (false), trace_scanning (false), trace_ast(false) {}

driver::~driver()
{
	for (auto& i : symtab) delete i;
}

int driver::parse(const zstring &f)
{
	for (auto& i : symtab) delete i;
	symtab.clear();

	ast.clear();
	file = f;
	location.initialize(&file);
	scan_begin();

	yy::parser parse(*this);
	parse.set_debug_level(trace_parsing);
	int res = parse();

	scan_end();

	if (trace_ast) ast.print();

	return res;
}

zstring* driver::symbol(const zstring& str) noexcept
{
	auto pos = symtab.find((zstring*)&str);
	if (pos >= 0) return symtab[pos];
	else
	{
		auto ptr = new zstring(str);
		symtab.add(ptr);
		return ptr;
	}
}
