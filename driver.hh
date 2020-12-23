#pragma once

#include <z/core/string.hpp>
#include <map>
#include "parser.hh"

// Give Flex the prototype of yylex we want ...
#define YY_DECL yy::parser::symbol_type yylex (driver& drv)
// ... and declare it for the parser's sake.
YY_DECL;

// Conducting the whole scanning and parsing of Calc++.
class driver
{
public:
	driver ();

	std::map<z::core::string<z::utf8>, double> variables;

	int result;

	// Run the parser on file F. Return 0 on success.
	int parse (const z::core::string<z::utf8>& f);
	// The name of the file being parsed.
	z::core::string<z::utf8> file;
	// Whether to generate parser debug traces.
	bool trace_parsing;

	// Handling the scanner.
	void scan_begin ();
	void scan_end ();
	// Whether to generate scanner debug traces.
	bool trace_scanning;
	// The token's location used by the scanner.
	yy::location location;
};
