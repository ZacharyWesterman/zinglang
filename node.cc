#include "node.hh"
#include <iostream>

node::node() : text(nullptr), type(nullptr), subtype(nullptr), valType(z::core::zstr::string) {}

void node::print(int depth) const noexcept
{
	if (!depth) std::cout << "BEGIN Generated AST:\n";
	zstring indent;
	indent.repeat("  ",depth);

	if (type)
	{
		std::cout << indent << *type;
		if (subtype) std::cout << " (" << *subtype << ")";
		if (text) std::cout << " \"" << *text << '"';
		switch (valType)
		{
			case z::core::zstr::integer:
				std::cout << ' ' << ival;
				break;
			case z::core::zstr::floating:
				std::cout << ' ' << fval;
				break;
			case z::core::zstr::complex:
				std::cout << ' ' << cval;
				break;
			default:;
		}
	}
	std::cout << std::endl;

	for (auto& child : children) child.print(depth+1);
	if (!depth) std::cout << "END Generated AST.\n";
}

void node::clear() noexcept
{
	text = type = nullptr;
	valType = z::core::zstr::string;
	children.clear();
}
