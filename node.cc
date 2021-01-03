#include "node.hh"
#include <iostream>

node::node() : text(nullptr), type(nullptr), subtype(nullptr) {}

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
		if (value.numeric())
		{
			std::cout << " [" << value.typeString() << "] " << value.toString();
		}
	}
	std::cout << std::endl;

	for (auto& child : children) child.print(depth+1);
	if (!depth) std::cout << "END Generated AST.\n";
}

void node::clear() noexcept
{
	text = type = nullptr;
	value = z::util::generic();
	children.clear();
}
