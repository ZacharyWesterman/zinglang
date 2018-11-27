#include "preproc.h"

extern "C"
{
	z::compiler::preprocTags* preprocTags()
	{
		return new preproc;
	}
}
