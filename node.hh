#pragma once

#include <z/core/array.hpp>
#include <z/core/string.hpp>
#include <z/util/generic.hpp>

struct node
{
	zstring* text;
	zstring* type;
	zstring* subtype;
	z::util::generic value;

	z::core::array<node> children;

	node();
	void print(int depth = 0) const noexcept;
	void clear() noexcept;

	void promote(node& other) noexcept;
};
