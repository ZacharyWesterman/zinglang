#pragma once

#include <z/compiler/preprocTags.h>

class preproc : public z::compiler::preprocTags
{
public:
	// z::core::string<> directive() const;
	z::core::string<> directend() const;
};
