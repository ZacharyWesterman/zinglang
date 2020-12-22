/* Parser for calc++.	 -*- C++ -*-

	 Copyright (C) 2005--2015, 2018--2020 Free Software Foundation, Inc.

	 This file is part of Bison, the GNU Compiler Compiler.

	 This program is free software: you can redistribute it and/or modify
	 it under the terms of the GNU General Public License as published by
	 the Free Software Foundation, either version 3 of the License, or
	 (at your option) any later version.

	 This program is distributed in the hope that it will be useful,
	 but WITHOUT ANY WARRANTY; without even the implied warranty of
	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
	 GNU General Public License for more details.

	 You should have received a copy of the GNU General Public License
	 along with this program.	If not, see <http://www.gnu.org/licenses/>.	*/

%skeleton "lalr1.cc" // -*- C++ -*-
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

%define api.location.file none

%define parse.trace
%define parse.error detailed
%define parse.lac full

%code {
# include "driver.hh"
}

%define api.token.prefix {TOK_}
%token
	ASSIGN	":="
	MINUS	"-"
	PLUS	"+"
	STAR	"*"
	SLASH	"/"
	LPAREN	"("
	RPAREN	")"
;

%token <z::core::string<z::utf8>> IDENTIFIER "identifier"
%token <int> NUMBER "number"
%nterm <int> exp

%printer { yyo << $$.cstring(); } <z::core::string<z::utf8>>;
%printer { yyo << $$; } <*>;

%%

%start unit;
unit: assignments exp	{ drv.result = $2; };

assignments:
	%empty {}
| assignments assignment {};

assignment:
	"identifier" ":=" exp { drv.variables[$1] = $3; };

%left "+" "-";
%left "*" "/";
exp:
	"number"
| "identifier"	{ $$ = drv.variables[$1]; }
| exp "+" exp	 { $$ = $1 + $3; }
| exp "-" exp	 { $$ = $1 - $3; }
| exp "*" exp	 { $$ = $1 * $3; }
| exp "/" exp	 { $$ = $1 / $3; }
| "(" exp ")"	 { $$ = $2; }
%%

void yy::parser::error (const location_type& l, const std::string& m)
{
	std::cerr << l << ": " << m << '\n';
}
