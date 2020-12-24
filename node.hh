#pragma once

#include <z/core/array.hpp>
#include <z/core/string.hpp>

struct node
{
	zstring* text;
	zstring* type;
	zstring* subtype;
	int valType;
	union
	{
		long ival;
		double fval;
		std::complex<double> cval;
	};

	z::core::array<node> children;

	node();
	void print(int depth = 0) const noexcept;
	void clear() noexcept;
};
