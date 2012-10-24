
local util = require "util"
local common = require "CommonStyle"

local data = {}

data.internalPrefix = "_int_"
data.headerDirectory = ""
data.sourceDirectory = ""

function data.GetLoaderBasename(spec, options)
	return spec.FilePrefix() .. "load.h"
end

function data.GetVersionCoreBasename(version, spec, options)
	return spec.FilePrefix() .. version:gsub("%.", "_") .. ".h"
end

function data.GetVersionCompBasename(version, spec, options)
	return spec.FilePrefix() .. version:gsub("%.", "_") .. "_comp.h"
end

function data.GetAllBasename(spec, options)
	return spec.FilePrefix() .. "all.h"
end

function data.GetTypeHeaderBasename(spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. "type.h"
end

function data.GetExtsHeaderBasename(spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. "exts.h"
end

function data.GetCoreHeaderBasename(version, spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. version:gsub("%.", "_") .. ".h"
end

function data.GetRemHeaderBasename(version, spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. version:gsub("%.", "_") .. "_rem.h"
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
#endif /*__cplusplus*/
]]
end

function data.GetEndExternBlock()
	return [[
#ifdef __cplusplus
}
#endif /*__cplusplus*/
]]
end

function data.WriteLoaderFuncBegin(hFile, funcName)
	hFile:fmt("static int %s()\n", funcName)
	hFile:write("{\n")
	hFile:inc()
	hFile:write("int numFailed = 0;\n")
end

function data.WriteLoaderFuncEnd(hFile)
	hFile:write("return numFailed;\n")
	hFile:dec()
	hFile:write("}\n")
end

function data.GetLoadExtensionFuncName(extName, spec, options)
	return "LoadExt_" .. extName
end

function data.GetLoadCoreFuncName(version, spec, options)
	return "LoadCore_Version_" .. version:gsub("%.", "_")
end

function data.GetLoadCoreCompFuncName(version, spec, options)
	return "LoadCore_Version_" .. version:gsub("%.", "_") .. "_Comp"
end

function data.GetLoadAllCoreFuncName(version, spec, options)
	return "LoadVersion_" .. version:gsub("%.", "_")
end

function data.GetLoadAllCoreCompFuncName(version, spec, options)
	return "LoadVersion_" .. version:gsub("%.", "_") .. "_Comp"
end

function data.GetMapTableStructName(spec, options)
	return string.format("%s%sStrToExtMap", options.prefix, spec.DeclPrefix())
end

function data.GetInMainFuncLoader(hFile, func, spec, options)
	local ret = ""
	ret = ret .. string.format('%s = (%s)%s("%s%s");\n',
		data.GetFuncPtrName(func, spec, options),
		data.GetFuncTypedefName(func, spec, options),
		common.GetProcAddressName(spec),
		spec.FuncNamePrefix(), func.name)
	ret = ret .. string.format('if(!%s) return %s;\n',
		data.GetFuncPtrName(func, spec, options),
		"0")
	return ret
end


local hdr_extra_spec =
{
	wgl = "",
	glX = "",
	gl = [=[
/**
This function retrieves the major GL version number. Only works after LoadFunctions has been called.
**/
int $<prefix>GetMajorVersion();

/**
This function retrieves the minor GL version number. Only works after LoadFunctions has been called.
**/
int $<prefix>GetMinorVersion();

/**Returns non-zero if the current GL version is greater than or equal to the given version.**/
int $<prefix>IsVersionGEQ(int testMajorVersion, int testMinorVersion);
]=],
}

local hdr_desc =
{
	wgl = [[Loads function pointers for WGL extensions.]],
	glX = [[Loads function pointers for GLX extensions.]],
	gl = [[Loads function pointers for OpenGL. This function will also load the core OpenGL functions (ie: not in extensions). It will only load the version and profile specified by the current OpenGL context. So if you get a 3.2 compatibility context, then it will load only try to load 3.2 compatibility in addition to any available extensions.]],
}

local hdr_pattern = 
[=[
/**
\file
\brief C header to include if you want to initialize $<specname>.

**/

/**\addtogroup module_glload_cinter**/
/**@{**/

/**
\brief The loading status returned by the loading functions.

**/
enum
{
	$<prefix>LOAD_FAILED = 0,
	$<prefix>LOAD_SUCCEEDED,
};

#ifdef __cplusplus
extern "C" {
#endif /*__cplusplus*/

/**
\brief Loads all of the function pointers available.

$<desc>

\return Will return $<prefix>LOAD_FAILED if the loading failed entirely and nothing was loaded. Returns $<prefix>LOAD_SUCCEEDED if the loading process worked as planned. If it is neither, then the (return value - $<prefix>LOAD_SUCCEEDED) is the number of core functions that fialed to load.
**/
int $<prefix>LoadFunctions($<params>);

$<extra>
/**@}**/

#ifdef __cplusplus
}
#endif /*__cplusplus*/
]=]

function data.GetLoaderHeaderString(spec, options)
	local ret = hdr_pattern
	ret = ret:gsub("%$%<extra%>", hdr_extra_spec[options.spec])
	ret = ret:gsub("%$%<specname%>", spec.DisplayName())
	ret = ret:gsub("%$%<prefix%>", spec.DeclPrefix())
	ret = ret:gsub("%$%<desc%>", hdr_desc[options.spec])
	ret = ret:gsub("%$%<params%>", spec.GetLoaderParams())
	return ret
end


return data
