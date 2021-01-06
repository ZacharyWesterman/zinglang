%{
# include <z/core/string.hpp>
# include "driver.hh"
# include "parser.hh"
%}

%option noyywrap nounput noinput batch debug

%{
	//Parse symbols in a user-defined way
	yy::parser::symbol_type make_STRING(zstring& s, const yy::parser::location_type& loc);
%}

blank [ \t\r]
id [a-zA-Z][a-zA-Z_0-9]*
int [0-9]+
float [0-9]+(\.[0-9]*)?([eE][-+]?[0-9]+)?
complex [0-9]+(\.[0-9]*)?([eE][-+]?[0-9]+)?[iI]
string \"(\\(.|\n)|[^\\\"])*\"
bad_string \"(\\.|[^\\\"])*$

%x IN_COMMENT

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
"//".*	loc.step(); //single-line comments
<INITIAL>{
"/*"	BEGIN(IN_COMMENT);
}
<IN_COMMENT>{
"*/"		BEGIN(INITIAL);
[^*\n]+	//eat comment in chunks
"*" 		//eat any lone stars
\n			loc.lines(yyleng); loc.step();
}

"="		return yy::parser::make_EQUALS(loc);
"+"		return yy::parser::make_PLUS(loc);
"-"		return yy::parser::make_MINUS(loc);
"*"		return yy::parser::make_STAR(loc);
"/"		return yy::parser::make_SLASH(loc);
"%"		return yy::parser::make_PERC(loc);
"("		return yy::parser::make_LPAREN(loc);
")"		return yy::parser::make_RPAREN(loc);
";"		return yy::parser::make_SEMICOL(loc);
"{"		return yy::parser::make_LBRACE(loc);
"}"		return yy::parser::make_RBRACE(loc);

{id} return yy::parser::make_IDENTIFIER(yytext, loc);
{int} return yy::parser::make_INT((long)zstring(yytext), loc);
{float} return yy::parser::make_FLOAT((double)zstring(yytext), loc);
{complex} return yy::parser::make_COMPLEX(zstring(yytext).complex(), loc);
{string} {
	uint32_t current;
	bool escape = false;
	zstring result;

	const char escseq[] = "abfnrtv";
	const char escres[] = "\a\b\f\n\r\t\v";

	for (int i=1; i<yyleng-1; ++i)
	{
		current = yytext[i];
		if (escape)
		{
			//common escape characters
			int k=0;
			while (escseq[k])
			{
				if (escseq[k] == (char)current)
				{
					current = escres[k];
					escape = false;
					break;
				}
				++k;
			}
		}
		else if ('\\' == current)
		{
			escape = true;
			continue;
		}
		else if ('\n' == current)
		{
			throw yy::parser::syntax_error(loc, "unterminated string constant");
		}

		result.append(current);
	}

	return yy::parser::make_STRING(result, loc);
}

{bad_string} {
	throw yy::parser::syntax_error(loc, "unterminated string constant");
}

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
