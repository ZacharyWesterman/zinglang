%skeleton "lalr1.cc"
%require "3.7.1"
%defines

%define api.token.raw

%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define api.filename.type {z::core::string<z::utf8>}

%code requires {
	# include <z/core/string.hpp>
	class driver;
}

// The parsing context.
%param { driver& drv }

%locations

%define parse.trace
%define parse.error detailed
%define parse.lac full

%code {
#include "driver.hh"
}

%define api.token.prefix {TOK_}
%token
	ASSIGN	":="
	MINUS	"-"
	PLUS	"+"
	STAR	"*"
	SLASH	"/"
	BSLASH	"\\"
	PERC	"%"
	LPAREN	"("
	RPAREN	")"
	ATSYMBL	"@"
	SEMICLN ";"
	QUERY 	"?"
;

%token <z::core::string<z::utf8>> IDENTIFIER "identifier"
%token <z::core::string<z::utf8>> TEXT "text"
%token <double> NUMBER "number"
%nterm <double> exp

%left "+" "-";
%left "*" "/" "%" "\\";
%precedence NEGATE

%printer { yyo << $$; } <*>;

%%

%start unit;
unit: expressions;

expressions:
	%empty
	| expressions assignment
	| expressions printval

assignment:
	"identifier" ":=" exp { drv.variables[$1] = $3; };
	| "?" "identifier" { //input variable from stdin
		z::core::string<z::utf8> value;
		std::cin >> value;
		drv.variables[$2] = value.integer();
	}

printval:
	"@" exp { std::cout << $2 << std::endl; }
	| "@" exp ";" { std::cout << $2; }
	| "text" { std::cout << $1 << std::endl; }
	| "text" ";" { std::cout << $1; }

exp:
	"number"
	| "identifier"	{ $$ = drv.variables[$1]; }
	| exp "+" exp	{ $$ = $1 + $3; }
	| exp "-" exp	{ $$ = $1 - $3; }
	| exp "*" exp	{ $$ = $1 * $3; }
	| exp "/" exp	{ $$ = $1 / $3; }
	| exp "\\" exp	{ $$ = (int)$1 / (int)$3; }
	| exp "%" exp	{ $$ = (int)$1 % (int)$3; }
	| "-" exp %prec NEGATE { $$ = -$2; }
	| "(" exp ")"	{ $$ = $2; }
%%

void yy::parser::error (const location_type& l, const std::string& m)
{
	std::cerr << l << ": " << m << '\n';
}
