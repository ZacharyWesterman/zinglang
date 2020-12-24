#include <iostream>
#include "driver.hh"

int main(int argc, char *argv[])
{
	int res = 0;
	driver drv;
	for (int i = 1; i < argc; ++i)
	{
		const zstring param = argv[i];
		if (param == "-p")
			drv.trace_parsing = true;
		else if (param == "-s")
			drv.trace_scanning = true;
		else if (param == "-a")
			drv.trace_ast = true;
		else if (drv.parse (argv[i]))
			res = 1;
	}
	return res;
}
