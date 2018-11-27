#pragma once

#include <z/compiler/preprocTags.h>

class preproc : public z::compiler::preprocTags
{
public:
	bool include(z::core::string<>& prefix, z::core::string<>& postfix);
};
