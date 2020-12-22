#include "driver.hh"
#include "parser.hh"

driver::driver () : trace_parsing (false), trace_scanning (false)
{
	variables["true"] = 1;
	variables["false"] = 0;
}

int driver::parse(const z::core::string<z::utf8> &f)
{
	file = f;
	location.initialize(&file);
	scan_begin();

	yy::parser parse(*this);
	parse.set_debug_level(trace_parsing);
	int res = parse();

	scan_end();
	return res;
}
