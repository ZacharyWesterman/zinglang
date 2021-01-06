%skeleton "lalr1.cc"
%require "3.7.1"
%defines

%define api.token.raw

%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define api.filename.type {zstring}

%code requires {
	#include <z/core/string.hpp>
	#include "node.hh"
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
	EQUALS	"="
	PLUS		"+"
	MINUS		"-"
	STAR		"*"
	SLASH		"/"
	PERC		"%"
	LPAREN	"("
	RPAREN	")"
	SEMICOL	";"
	LBRACE "{"
	RBRACE "}"
;

%token <zstring> IDENTIFIER "identifier"
%token <long> INT "int"
%token <double> FLOAT "float"
%token <std::complex<double>> COMPLEX "complex"
%token <zstring> STRING "string"

%nterm <node> exp value stmt stmtlist

%precedence STMT
%left "="
%left "+" "-";
%left "*" "/" "%" "\\";
%precedence NEGATE

%printer { yyo << $$; } <*>
%printer { yyo << $$.type; } <node>;

%%

%start unit;

unit:
	stmtlist { drv.ast = $1; }

stmtlist:
	stmt {
		$$.type = drv.symbol("stmt");
		$$.children.add($1);
	}
	| stmtlist stmt {
		$$ = $1;
		$$.children.add($2);
	}

stmt:
	exp ";"
	| "{" stmtlist "}" { $$ = $2; }

//Expression values
value:
	"identifier" {
		$$.type = drv.symbol("var");
		$$.text = drv.symbol($1);
	}
	| "int" {
		$$.type = drv.symbol("const");
		$$.value = $1;
	}
	| "float" {
		$$.type = drv.symbol("const");
		$$.value = $1;
	}
	| "complex" {
		$$.type = drv.symbol("const");
		$$.value = $1;
	}
	| "string" {
		$$.type = drv.symbol("const");
		$$.value = $1;
	}

//Expressions
exp:
	value { $$ = $1; }
	//Assignment
	| "identifier" "=" exp {
		$$.type = drv.symbol("assign");
		$$.text = drv.symbol($1);
		$$.children = {$3};
	}
	//Addition operators
	| exp "+" exp {
		//fold constants
		if ($1.value.numeric() && $3.value.numeric())
		{
			$$ = $1;
			$$.value += $3.value;
		}
		else
		{
			$$.type = drv.symbol("add");
			$$.subtype = drv.symbol("add");
			$$.children = {$1, $3};
		}
	}
	| exp "-" exp {
		//fold constants
		if ($1.value.numeric() && $3.value.numeric())
		{
			$$ = $1;
			$$.value -= $3.value;
		}
		else
		{
			$$.type = drv.symbol("add");
			$$.subtype = drv.symbol("sub");
			$$.children = {$1, $3};
		}
	}
	//Multiplication operators
	| exp "*" exp {
		//fold constants
		if ($1.value.numeric() && $3.value.numeric())
		{
			$$ = $1;
			$$.value *= $3.value;
		}
		else
		{
			$$.type = drv.symbol("mult");
			$$.subtype = drv.symbol("mult");
			$$.children = {$1, $3};
		}
	}
	| exp "/" exp {
		//check for div by 0, but continue to form AST.
		bool zero = $3.value.complex() == 0.0;
		if (zero && $3.value.numeric()) error(@$, "division by zero");
		//fold constants
		if (!zero && $1.value.numeric() && $3.value.numeric())
		{
			$$ = $1;
			$$.value /= $3.value;
		}
		else
		{
			$$.type = drv.symbol("mult");
			$$.subtype = drv.symbol("div");
			$$.children = {$1, $3};
		}
	}
	| exp "%" exp {
		//check for div by 0, but continue to form AST.
		bool zero = $3.value.complex() == 0.0;
		if (zero && $3.value.numeric()) error(@$, "division by zero");
		//fold constants
		if (!zero && $1.value.numeric() && $3.value.numeric())
		{
			$$ = $1;
			$$.value %= $3.value;
		}
		else
		{
			$$.type = drv.symbol("mult");
			$$.subtype = drv.symbol("mod");
			$$.children = {$1, $3};
		}
	}
	//Unary operators
	| "-" exp %prec NEGATE {
		//fold any redundant negate operations
		if ($2.type == drv.symbol("negate"))
		{
			$$ = $2.children[0];
		}
		else if ($2.value.numeric()) //fold constants
		{
			$$ = $2;
			$$.value = -$$.value;
		}
		else
		{
			$$.type = drv.symbol("negate");
			$$.children = {$2};
		}
	}
	| "(" exp ")"	{ $$ = $2; }
%%

void yy::parser::error (const location_type& l, const std::string& m)
{
	std::cerr << l << ": " << m << '\n';
}
