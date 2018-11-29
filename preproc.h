#pragma once

#include <z/compiler/preprocTags.h>

class preproc : public z::compiler::preprocTags
{
public:
	zstring directive() const;
	zstring directend() const;
};
