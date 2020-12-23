%{
# include <z/core/string.hpp>
# include "driver.hh"
# include "parser.hh"
%}

%option noyywrap nounput noinput batch debug

%{
	//Parse symbols in a user-defined way
	yy::parser::symbol_type make_NUMBER(const z::core::string<z::utf8> &s, const yy::parser::location_type& loc);
	yy::parser::symbol_type make_TEXT(const z::core::string<z::utf8> &s, const yy::parser::location_type& loc);
%}

id [a-zA-Z][a-zA-Z_0-9]*
value [0-9]+(\.[0-9]+)?
blank [ \t\r]
text \"(\\\"|[^\"])*\"

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

"-"		return yy::parser::make_MINUS(loc);
"+"		return yy::parser::make_PLUS(loc);
"*"		return yy::parser::make_STAR(loc);
"/"		return yy::parser::make_SLASH(loc);
"\\"	return yy::parser::make_BSLASH(loc);
"%"		return yy::parser::make_PERC(loc);
"("		return yy::parser::make_LPAREN(loc);
")"		return yy::parser::make_RPAREN(loc);
":="	return yy::parser::make_ASSIGN(loc);
"@"		return yy::parser::make_ATSYMBL(loc);
";"		return yy::parser::make_SEMICLN(loc);
"?"		return yy::parser::make_QUERY(loc);

{value}	return make_NUMBER(yytext, loc);
{text}	return make_TEXT(yytext, loc);
{id}	return yy::parser::make_IDENTIFIER(yytext, loc);
. {
	throw yy::parser::syntax_error(loc, "invalid character: " + std::string(yytext));
}
<<EOF>>	return yy::parser::make_YYEOF(loc);
%%

yy::parser::symbol_type make_NUMBER(const z::core::string<z::utf8> &s, const yy::parser::location_type& loc)
{
	return yy::parser::make_NUMBER((double)s, loc);
}

yy::parser::symbol_type make_TEXT (const z::core::string<z::utf8> &s, const yy::parser::location_type& loc)
{
	auto s2 = s.substr(1,s.length()-2);
	s2.replace("\\n", "\n");
	s2.replace("\\\"", "\"");

	return yy::parser::make_TEXT(s2, loc);
}

void driver::scan_begin()
{
	yy_flex_debug = trace_scanning;
	if (!file.length() || (file == "-"))
	{
		yyin = stdin;
	}
	else if (!(yyin = fopen(file.cstring(), "r")))
	{
		std::cerr << "cannot open " << file.cstring() << ": " << strerror(errno) << '\n';
		exit(EXIT_FAILURE);
	}
}

void driver::scan_end()
{
	fclose(yyin);
}
