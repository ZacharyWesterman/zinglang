#include "preproc.h"

z::core::string<> preproc::directive() const
{
	return "#";
}

z::core::string<> preproc::directend() const
{
	return "[;$]";
}
