#include "preproc.h"

zstring preproc::directive() const
{
	return "#";
}

zstring preproc::directend() const
{
	return "[;$]";
}
