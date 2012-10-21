
local util = require "util"

local data = {}

data.internalPrefix = "_int_"
data.headerDirectory = ""
data.sourceDirectory = ""

function data.GetTypeHeaderBasename(spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. "type.h"
end

function data.GetExtsHeaderBasename(spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. "exts.h"
end

function data.GetCoreHeaderBasename(version, spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. version .. ".h"
end

function data.GetRemHeaderBasename(version, spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. version .. "_rem.h"
end

function data.GetExtVariableName(extName, spec, options)
	return spec.FuncNamePrefix() .. "ext_" .. extName
end

function data.GetEnumeratorName(enum, spec, options)
	return spec.EnumNamePrefix() .. enum.name
end

function data.GetFuncTypedefName(func, spec, options)
	local temp = "PFN" .. spec.FuncNamePrefix() .. func.name .. "PROC"
	return temp:upper()
end

--Three parameters: the return value, the typedef name, and the params
function data.GetTypedefFormat(spec)
	return "typedef %s (" .. spec.GetCodegenPtrType() .. " * %s)(%s);\n"
end

function data.GetFuncPtrName(func, spec, options)
	return "_funcptr_" .. spec.FuncNamePrefix() .. func.name
end

function data.GetTypeHdrFileIncludeGuard(spec, options)
	return spec.GetIncludeGuardString() .. "_GEN_TYPE" .. "_H"
end

function data.GetExtFileIncludeGuard(spec, options)
	return spec.GetIncludeGuardString() .. "_GEN_EXTENSIONS" .. "_H"
end

function data.GetCoreHdrFileIncludeGuard(version, spec, options, removed)
	if(removed) then
		return spec.GetIncludeGuardString() .. "_GEN_CORE_REM" .. version:gsub("%.", "_") .. "_H"
	else
		return spec.GetIncludeGuardString() .. "_GEN_CORE_" .. version:gsub("%.", "_") .. "_H"
	end
end

function data.GetInclFileIncludeGuard(version, spec, options)
	return spec.GetIncludeGuardString() .. "_GEN_" .. version:gsub("%.", "_") .. "_H"
end

function data.GetInclFileCompIncludeGuard(version, spec, options)
	return spec.GetIncludeGuardString() .. "_GEN_" .. version:gsub("%.", "_") .. "COMP_H"
end

function data.GetInclFileAllIncludeGuard(spec, options)
	return spec.GetIncludeGuardString() .. "_GEN_ALL_H"
end

function data.GetBeginExternBlock()
	return [[
#ifdef __cplusplus
extern "C" {
#endif //__cplusplus
]]
end

function data.GetEndExternBlock()
	return [[
#ifdef __cplusplus
}
#endif //__cplusplus
]]
end


return data
