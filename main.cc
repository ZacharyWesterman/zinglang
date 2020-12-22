#include <iostream>
#include "driver.hh"

int main(int argc, char *argv[])
{
	int res = 0;
	driver drv;
	for (int i = 1; i < argc; ++i)
	{
		const z::core::string<z::utf8> param = argv[i];
		if (param == "-p")
			drv.trace_parsing = true;
		else if (param == "-s")
			drv.trace_scanning = true;
		else if (!drv.parse (argv[i]))
			std::cout << drv.result << '\n';
		else
			res = 1;
	}
	return res;
}
