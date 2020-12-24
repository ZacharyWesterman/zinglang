%{
# include <z/core/string.hpp>
# include "driver.hh"
# include "parser.hh"
%}

%option noyywrap nounput noinput batch debug

%{
	//Parse symbols in a user-defined way
	/* yy::parser::symbol_type make_FLOAT(const zstring& s, const yy::parser::location_type& loc);
	yy::parser::symbol_type make_INT(const zstring& s, const yy::parser::location_type& loc); */
%}

blank [ \t\r]
id [a-zA-Z][a-zA-Z_0-9]*
int [0-9]+
float [0-9]+(\.[0-9]*)?([eE][-+]?[0-9]+)?
complex [0-9]+(\.[0-9]*)?([eE][-+]?[0-9]+)?[iI]

%{
	// Code run each time a pattern is matched.
	# define YY_USER_ACTION	loc.columns (yyleng);
%}
%%
%{
	// A handy shortcut to the location held by the driver.
	yy::location& loc = drv.location;
	// Code run each time yylex is called.
	loc.step();
%}
{blank}+	loc.step();
\n+			loc.lines(yyleng); loc.step();
#.*			loc.step(); //discard any comment text

"+"		return yy::parser::make_PLUS(loc);
"-"		return yy::parser::make_MINUS(loc);
"*"		return yy::parser::make_STAR(loc);
"/"		return yy::parser::make_SLASH(loc);
"\\"	return yy::parser::make_BSLASH(loc);
"%"		return yy::parser::make_PERC(loc);
"("		return yy::parser::make_LPAREN(loc);
")"		return yy::parser::make_RPAREN(loc);

{id} return yy::parser::make_IDENTIFIER(yytext, loc);
{int} return yy::parser::make_INT((long)zstring(yytext), loc);
{float} return yy::parser::make_FLOAT((double)zstring(yytext), loc);
{complex} return yy::parser::make_COMPLEX(zstring(yytext).complex(), loc);

. {
	throw yy::parser::syntax_error(loc, "invalid character: " + std::string(yytext));
}
<<EOF>>	return yy::parser::make_YYEOF(loc);
%%

void driver::scan_begin()
{
	yy_flex_debug = trace_scanning;
	if (!file.length() || (file == "-"))
	{
		yyin = stdin;
	}
	else if (!(yyin = fopen(zpath(file).cstring(), "r")))
	{
		std::cerr << "cannot open " << file << ": " << strerror(errno) << '\n';
		exit(EXIT_FAILURE);
	}
}

void driver::scan_end()
{
	fclose(yyin);
}
