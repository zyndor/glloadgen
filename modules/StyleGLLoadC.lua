local util = require "util"
local struct = require "StructGLLoad"
local common = require "CommonStyle"
local glload = require "glload_util"


local my_style

----------------------------------------------------------
-- Type header.
local type_hdr = {}

function type_hdr.GetFilename(basename, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory .. glload.GetTypeHeaderBasename(spec, options)
end

function type_hdr.WriteBlockBeginIncludeGuard(hFile, spec, options)
	local includeGuard = glload.GetTypeHdrFileIncludeGuard(spec, options)
	hFile:fmt("#ifndef %s\n", includeGuard)
	hFile:fmt("#define %s\n", includeGuard)
end

function type_hdr.WriteBlockEndIncludeGuard(hFile, spec, options)
	hFile:fmt("#endif //%s\n", glload.GetTypeHdrFileIncludeGuard(spec, options))
end

function type_hdr.WriteInit(hFile, spec, options)
	hFile:rawwrite(spec.GetHeaderInit())
end

function type_hdr.WriteStdTypedefs(hFile, spec, options)
	local defArray = common.GetStdTypedefs()
	
	--Use include-guards for the typedefs, since they're common among
	--headers in this style.
	hFile:write("#ifndef GL_LOAD_GEN_BASIC_OPENGL_TYPEDEFS\n")
	hFile:write("#define GL_LOAD_GEN_BASIC_OPENGL_TYPEDEFS\n")
	hFile:write("\n")
	hFile:inc()
	
	for _, def in ipairs(defArray) do
		hFile:write(def)
	end
	
	hFile:dec()
	hFile:write("\n")
	hFile:write("#endif /*GL_LOAD_GEN_BASIC_OPENGL_TYPEDEFS*/\n")
	hFile:write("\n")
end

function type_hdr.WritePassthruTypedefs(hFile, specData, spec, options)
	common.WritePassthruData(hFile, specData.funcData.passthru)
end

-----------------------------------------------------------
-- Extension header.
local ext_hdr = {}

function ext_hdr.GetFilename(basename, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory .. glload.GetExtsHeaderBasename(spec, options)
end

function ext_hdr.WriteBlockBeginIncludeGuard(hFile, spec, options)
	local includeGuard = glload.GetExtFileIncludeGuard(spec, options)
	hFile:fmt("#ifndef %s\n", includeGuard)
	hFile:fmt("#define %s\n", includeGuard)
end

function ext_hdr.WriteBlockEndIncludeGuard(hFile, spec, options)
	hFile:fmt("#endif //%s\n", glload.GetExtFileIncludeGuard(spec, options))
end

function ext_hdr.WriteTypedefs(hFile, specData, spec, options)
	common.WritePassthruData(hFile, specData.funcData.passthru)
end

function ext_hdr.WriteBlockBeginExtern(hFile, spec, options)
	hFile:writeblock(glload.GetBeginExternBlock())
end

function ext_hdr.WriteBlockEndExtern(hFile, spec, options)
	hFile:writeblock(glload.GetEndExternBlock())
end

function ext_hdr.WriteExtVariable(hFile, extName, spec, options)
	hFile:fmt("extern int %s;\n",
		glload.GetExtVariableName(extName, spec, options))
end

function ext_hdr.WriteEnumerator(hFile, enum, enumTable, spec, options)
	hFile:fmt("#define %s %s\n",
		glload.GetEnumeratorName(enum, spec, options),
		common.ResolveEnumValue(enum, enumTable))
end

function ext_hdr.WriteFuncTypedef(hFile, func, typemap, spec, options)
	hFile:fmt(glload.GetTypedefFormat(spec),
		common.GetFuncReturnType(func, typemap),
		glload.GetFuncTypedefName(func, spec, options),
		common.GetFuncParamList(func, typemap))
end

function ext_hdr.WriteFuncDecl(hFile, func, typemap, spec, options)
	hFile:fmt("extern %s %s;\n",
		glload.GetFuncTypedefName(func, spec, options),
		glload.GetFuncPtrName(func, spec, options))
	hFile:fmt("#define %s %s\n",
		spec.FuncNamePrefix() .. func.name,
		glload.GetFuncPtrName(func, spec, options))
end


-----------------------------------------------------------
-- Core header.
local core_hdr = {}

function core_hdr.GetFilename(basename, version, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory .. glload.GetCoreHeaderBasename(version, spec, options)
end

function core_hdr.GetFilenameRem(basename, version, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory .. glload.GetRemHeaderBasename(version, spec, options)
end

function core_hdr.WriteBlockBeginIncludeGuard(hFile, version, spec, options)
	local includeGuard = glload.GetCoreHdrFileIncludeGuard(version, spec, options)
	hFile:fmt("#ifndef %s\n", includeGuard)
	hFile:fmt("#define %s\n", includeGuard)
end

function core_hdr.WriteBlockEndIncludeGuard(hFile, version, spec, options)
	hFile:fmt("#endif //%s\n", glload.GetCoreHdrFileIncludeGuard(version, spec, options))
end

function core_hdr.WriteBlockBeginIncludeGuardRem(hFile, version, spec, options)
	local includeGuard = glload.GetCoreHdrFileIncludeGuard(version, spec, options, true)
	hFile:fmt("#ifndef %s\n", includeGuard)
	hFile:fmt("#define %s\n", includeGuard)
end

function core_hdr.WriteBlockEndIncludeGuardRem(hFile, version, spec, options)
	hFile:fmt("#endif //%s\n", glload.GetCoreHdrFileIncludeGuard(version, spec, options, true))
end

function core_hdr.WriteBlockBeginExtern(hFile, spec, options)
	hFile:writeblock(glload.GetBeginExternBlock())
end

function core_hdr.WriteBlockEndExtern(hFile, spec, options)
	hFile:writeblock(glload.GetEndExternBlock())
end

function core_hdr.WriteEnumerator(hFile, enum, enumTable, spec, options)
	hFile:fmt("#define %s %s\n",
		glload.GetEnumeratorName(enum, spec, options),
		common.ResolveEnumValue(enum, enumTable))
end

function core_hdr.WriteFuncTypedef(hFile, func, typemap, spec, options)
	hFile:fmt(glload.GetTypedefFormat(spec),
		common.GetFuncReturnType(func, typemap),
		glload.GetFuncTypedefName(func, spec, options),
		common.GetFuncParamList(func, typemap))
end

function core_hdr.WriteFuncDecl(hFile, func, typemap, spec, options)
	hFile:fmt("extern %s %s;\n",
		glload.GetFuncTypedefName(func, spec, options),
		glload.GetFuncPtrName(func, spec, options))
	hFile:fmt("#define %s %s\n",
		spec.FuncNamePrefix() .. func.name,
		glload.GetFuncPtrName(func, spec, options))
end


-----------------------------------------------------------
-- Include header
local incl_hdr = {}

function incl_hdr.VersionFilenameCore(basename, version, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory ..
		glload.GetVersionCoreBasename(version, spec, options)
end

function incl_hdr.VersionFilenameComp(basename, version, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory ..
		glload.GetVersionCompBasename(version, spec, options)
end

function incl_hdr.AllFilename(basename, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory .. 
		glload.GetAllBasename(spec, options)
end

function incl_hdr.WriteBlockBeginIncludeGuardCore(hFile, version, spec, options)
	local includeGuard = glload.GetInclFileIncludeGuard(version, spec, options)
	hFile:fmt("#ifndef %s\n", includeGuard)
	hFile:fmt("#define %s\n", includeGuard)
end

function incl_hdr.WriteBlockEndIncludeGuardCore(hFile, version, spec, options)
	hFile:fmt("#endif //%s\n", glload.GetInclFileIncludeGuard(version, spec, options))
end

function incl_hdr.WriteBlockBeginIncludeGuardComp(hFile, version, spec, options)
	local includeGuard = glload.GetInclFileCompIncludeGuard(version, spec, options)
	hFile:fmt("#ifndef %s\n", includeGuard)
	hFile:fmt("#define %s\n", includeGuard)
end

function incl_hdr.WriteBlockEndIncludeGuardComp(hFile, version, spec, options)
	hFile:fmt("#endif //%s\n", glload.GetInclFileCompIncludeGuard(version, spec, options))
end

function incl_hdr.WriteBlockBeginIncludeGuardAll(hFile, spec, options)
	local includeGuard = glload.GetInclFileAllIncludeGuard(spec, options)
	hFile:fmt("#ifndef %s\n", includeGuard)
	hFile:fmt("#define %s\n", includeGuard)
end

function incl_hdr.WriteBlockEndIncludeGuardAll(hFile, spec, options)
	hFile:fmt("#endif //%s\n", glload.GetInclFileAllIncludeGuard(spec, options))
end

function incl_hdr.WriteIncludeIntType(hFile, spec, options)
	hFile:fmt('#include "%s"\n', glload.GetTypeHeaderBasename(spec, options))
end

function incl_hdr.WriteIncludeIntExts(hFile, spec, options)
	hFile:fmt('#include "%s"\n', glload.GetExtsHeaderBasename(spec, options))
end

function incl_hdr.WriteIncludeIntVersionCore(hFile, sub_version, spec, options)
	hFile:fmt('#include "%s"\n', glload.GetCoreHeaderBasename(sub_version, spec, options))
end

function incl_hdr.WriteIncludeIntVersionComp(hFile, sub_version, specData, spec, options)
	if(not my_style.FilterVersionHasRemoved(sub_version, specData, spec, options)) then
		return
	end
	
	hFile:fmt('#include "%s"\n', glload.GetRemHeaderBasename(sub_version, spec, options))
end

----------------------------------------------------------
-- Type header.
local load_hdr = {}

function load_hdr.GetFilename(basename, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory .. spec.FilePrefix() .. "load.h"
end


----------------------------------------------------------
-- Source file.
local source = {}

function source.GetFilename(basename, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.sourceDirectory .. spec.FilePrefix() .. "load.c"
end

function source.WriteIncludes(hFile, spec, options)
	hFile:writeblock[[
#include <stdlib.h>
#include <string.h>
]]
	hFile:fmt('#include "%s"\n', glload.headerDirectory .. 
		glload.GetAllBasename(spec, options))
end

function source.WritePointerLoading(hFile, specData, spec, options)
	hFile:writeblock(spec.GetLoaderFunc())
end

function source.WriteExtVariable(hFile, extName, spec, options)
	hFile:fmt("int %s = 0;\n",
		glload.GetExtVariableName(extName, spec, options))
end

function source.WriteBlockBeginClearExtVars(hFile, spec, options)
	hFile:fmtblock("static void %s()\n{\n",
		glload.GetClearExtVarsFuncName(spec, options))
	hFile:inc()
end

function source.WriteBlockEndClearExtVars(hFile, spec, options)
	hFile:dec()
	hFile:write("}\n")
end

function source.WriteClearExtVar(hFile, extName, spec, options)
	hFile:fmt("%s = 0;\n",
		glload.GetExtVariableName(extName, spec, options))
end

function source.WriteFuncDef(hFile, func, typemap, spec, options)
	hFile:fmt("%s %s = NULL;\n",
		glload.GetFuncTypedefName(func, spec, options),
		glload.GetFuncPtrName(func, spec, options))
end

function source.WriteFuncDefCond(hFile, func, typemap, spec, options, funcSeen)
	if(not funcSeen[func.name]) then
		source.WriteFuncDef(hFile, func, typemap, spec, options)
	end
end

function source.WriteBlockBeginLoadExtensionFuncs(hFile, extName, spec, options)
	hFile:fmt("static int %s()\n",
		glload.GetLoadExtensionFuncName(extName, spec, options))
	hFile:write("{\n")
	hFile:inc()
	hFile:write("int numFailed = 0;\n")
end

function source.WriteBlockEndLoadExtensionFuncs(hFile, extName, spec, options)
	hFile:write("return numFailed;\n")
	hFile:dec()
	hFile:write("}\n")
end

function source.WriteLoadFunction(hFile, func, typemap, spec, options)
	hFile:fmt('%s = %s("%s");\n',
		glload.GetFuncPtrName(func, spec, options),
		common.GetProcAddressName(spec),
		common.GetOpenGLFuncName(func, spec))
	hFile:fmt("if(!%s) ++numFailed;\n",
		glload.GetFuncPtrName(func, spec, options))
end

function source.WriteBlockBeginLoadCoreFuncs(hFile, version, spec, options)
	hFile:fmt("static int %s()\n",
		glload.GetLoadCoreFuncName(version, spec, options))
	hFile:write("{\n")
	hFile:inc()
	hFile:write("int numFailed = 0;\n")
end

function source.WriteBlockEndLoadCoreFuncs(hFile, version, spec, options)
	hFile:write("return numFailed;\n")
	hFile:dec()
	hFile:write("}\n")
end

function source.WriteBlockBeginLoadCoreFuncsComp(hFile, version, spec, options)
	hFile:fmt("static int %s()\n",
		glload.GetLoadCoreCompFuncName(version, spec, options))
	hFile:write("{\n")
	hFile:inc()
	hFile:write("int numFailed = 0;\n")
end

function source.WriteBlockEndLoadCoreFuncsComp(hFile, version, spec, options)
	hFile:write("return numFailed;\n")
	hFile:dec()
	hFile:write("}\n")
end

function source.WriteLoadFunctionCore(hFile, func, typemap, spec, options)
	hFile:fmt('%s = %s("%s");\n',
		glload.GetFuncPtrName(func, spec, options),
		common.GetProcAddressName(spec),
		common.GetOpenGLFuncName(func, spec))
		
	if(func.name:match("EXT$")) then
		hFile:fmt("/* %s comes from DSA.*/\n",
			common.GetOpenGLFuncName(func, spec))
	else
		hFile:fmt("if(!%s) ++numFailed;\n",
			glload.GetFuncPtrName(func, spec, options))
	end
end

my_style =
{
	type_hdr = type_hdr,
	ext_hdr = ext_hdr,
	core_hdr = core_hdr,
	incl_hdr = incl_hdr,
	load_hdr = load_hdr,
	source = source,
}

function my_style.FilterVersionHasRemoved(version, specData, spec, options)
	for _, enum in ipairs(specData.coredefs[version].enums) do
		if(enum.removed) then
			return true
		end
	end
	
	for _, func in ipairs(specData.coredefs[version].funcs) do
		if(func.deprecated) then
			return true
		end
	end
	
	return false
end

function my_style.FilterVersionHasCore(version, specData, spec, options)
	for _, enum in ipairs(specData.coredefs[version].enums) do
		if(not enum.removed and not enum.extensions) then
			return true
		end
	end
	
	for _, func in ipairs(specData.coredefs[version].funcs) do
		if(not func.deprecated) then
			return true
		end
	end
	
	return false
end


function my_style.FilterHasCompatibility(version, specData, spec, options)
	if(tonumber(version) >= 3.1) then
		return true
	else
		return false
	end
end

local function HasFunclistAnyCore(funcList)
	for _, func in ipairs(funcList) do
		if(not func.deprecated) then
			return true
		end
	end
	
	return false
end

local function HasFunclistAnyComp(funcList)
	for _, func in ipairs(funcList) do
		if(func.deprecated) then
			return true
		end
	end
	
	return false
end

function my_style.FilterVersionHasCoreFuncs(version, specData, spec, options)
	local coreExtByVersion = spec.GetCoreExts()
	if(not coreExtByVersion) then return end
	
	local coreExts = coreExtByVersion[version]
	
	if(coreExts) then
		for _, extName in ipairs(coreExts) do
			if(HasFunclistAnyCore(specData.extdefs[extName].funcs)) then
				return true
			end
		end
	end
	
	if(HasFunclistAnyCore(specData.coredefs[version].funcs)) then
		return true
	end
	
	return false
end

function my_style.FilterVersionHasCompFuncs(version, specData, spec, options)
	local coreExtByVersion = spec.GetCoreExts()
	if(not coreExtByVersion) then return end
	
	local coreExts = coreExtByVersion[version]
	
	if(coreExts) then
		for _, extName in ipairs(coreExts) do
			if(HasFunclistAnyComp(specData.extdefs[extName].funcs)) then
				return true
			end
		end
	end
	
	if(HasFunclistAnyComp(specData.coredefs[version].funcs)) then
		return true
	end
	
	return false
end

function my_style.FilterCoreEnum(enum)
	return not enum.removed and not enum.extensions
end

function my_style.FilterCompEnum(enum)
	return enum.removed and not enum.extensions
end

function my_style.FilterCoreFunc(func)
	return not func.deprecated
end

function my_style.FilterCompFunc(func)
	return func.deprecated
end



local function Create()
	return common.DeepCopyTable(my_style), struct
end

return { Create = Create }
