#pragma once

#include <z/core/string.hpp>
#include <z/core/sortedRefArray.hpp>
#include "parser.hh"
#include "node.hh"

// Give Flex the prototype of yylex we want ...
#define YY_DECL yy::parser::symbol_type yylex (driver& drv)
// ... and declare it for the parser's sake.
YY_DECL;

// Conducting the whole scanning and parsing of Calc++.
class driver
{
public:
	driver ();
	~driver();

	z::core::sortedRefArray<zstring*> symtab;

	int result;

	// Run the parser on file F. Return 0 on success.
	int parse (const zstring& f);
	// The name of the file being parsed.
	zstring file;
	// Whether to generate parser debug traces.
	bool trace_parsing;

	// Handling the scanner.
	void scan_begin ();
	void scan_end ();
	// Whether to generate scanner debug traces.
	bool trace_scanning;

	// Whether to list the AST after parsing.
	bool trace_ast;

	node ast; //abstract syntax tree

	// The token's location used by the scanner.
	yy::location location;

	zstring* symbol(const zstring&) noexcept;
};
