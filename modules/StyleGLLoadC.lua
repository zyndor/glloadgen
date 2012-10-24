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
	hFile:fmt("#endif /*%s*/\n", glload.GetTypeHdrFileIncludeGuard(spec, options))
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
	hFile:fmt("#endif /*%s*/\n", glload.GetExtFileIncludeGuard(spec, options))
end

function ext_hdr.WriteTypedefs(hFile, specData, spec, options)
--	common.WritePassthruData(hFile, specData.funcData.passthru)
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
	hFile:fmt("#endif /*%s*/\n", glload.GetCoreHdrFileIncludeGuard(version, spec, options))
end

function core_hdr.WriteBlockBeginIncludeGuardRem(hFile, version, spec, options)
	local includeGuard = glload.GetCoreHdrFileIncludeGuard(version, spec, options, true)
	hFile:fmt("#ifndef %s\n", includeGuard)
	hFile:fmt("#define %s\n", includeGuard)
end

function core_hdr.WriteBlockEndIncludeGuardRem(hFile, version, spec, options)
	hFile:fmt("#endif /*%s*/\n", glload.GetCoreHdrFileIncludeGuard(version, spec, options, true))
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
	hFile:fmt("#endif /*%s*/\n", glload.GetInclFileIncludeGuard(version, spec, options))
end

function incl_hdr.WriteBlockBeginIncludeGuardComp(hFile, version, spec, options)
	local includeGuard = glload.GetInclFileCompIncludeGuard(version, spec, options)
	hFile:fmt("#ifndef %s\n", includeGuard)
	hFile:fmt("#define %s\n", includeGuard)
end

function incl_hdr.WriteBlockEndIncludeGuardComp(hFile, version, spec, options)
	hFile:fmt("#endif /*%s*/\n", glload.GetInclFileCompIncludeGuard(version, spec, options))
end

function incl_hdr.WriteBlockBeginIncludeGuardAll(hFile, spec, options)
	local includeGuard = glload.GetInclFileAllIncludeGuard(spec, options)
	hFile:fmt("#ifndef %s\n", includeGuard)
	hFile:fmt("#define %s\n", includeGuard)
end

function incl_hdr.WriteBlockEndIncludeGuardAll(hFile, spec, options)
	hFile:fmt("#endif /*%s*/\n", glload.GetInclFileAllIncludeGuard(spec, options))
end

function incl_hdr.WriteIncludeIntType(hFile, spec, options)
	hFile:fmt('#include "%s"\n', glload.GetTypeHeaderBasename(spec, options))
end

function incl_hdr.WriteIncludeIntExts(hFile, spec, options)
	hFile:fmt('#include "%s"\n', glload.GetExtsHeaderBasename(spec, options))
end

function incl_hdr.WriteIncludeIntVersionCore(hFile, sub_version, specData, spec, options)
	if(not my_style.FilterVersionHasCore(sub_version, specData, spec, options)) then
		return
	end

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
	return dir .. glload.headerDirectory .. glload.GetLoaderBasename(spec, options)
end

function load_hdr.WriteLoaderDecl(hFile, spec, options)
	hFile:writeblock(glload.GetLoaderHeaderString(spec, options))
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
#include <stddef.h>
#include <string.h>
]]
	hFile:fmt('#include "%s"\n', glload.headerDirectory .. 
		glload.GetAllBasename(spec, options))
	hFile:fmt('#include "%s"\n', glload.headerDirectory .. 
		glload.GetLoaderBasename(spec, options))
end

function source.WritePointerLoading(hFile, specData, spec, options)
	hFile:writeblock(spec.GetLoaderFunc())
end

function source.WriteExtVariable(hFile, extName, spec, options)
	hFile:fmt("int %s = 0;\n",
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
	glload.WriteLoaderFuncBegin(hFile,
		glload.GetLoadExtensionFuncName(extName, spec, options))
end

function source.WriteBlockEndLoadExtensionFuncs(hFile, extName, spec, options)
	glload.WriteLoaderFuncEnd(hFile)
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
	glload.WriteLoaderFuncBegin(hFile,
		glload.GetLoadCoreFuncName(version, spec, options))
end

function source.WriteBlockEndLoadCoreFuncs(hFile, version, spec, options)
	glload.WriteLoaderFuncEnd(hFile)
end

function source.WriteBlockBeginLoadCoreFuncsComp(hFile, version, spec, options)
	glload.WriteLoaderFuncBegin(hFile,
		glload.GetLoadCoreCompFuncName(version, spec, options))
end

function source.WriteBlockEndLoadCoreFuncsComp(hFile, version, spec, options)
	glload.WriteLoaderFuncEnd(hFile)
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

function source.WriteBlockBeginLoadAllCoreFunc(hFile, version, spec, options)
	glload.WriteLoaderFuncBegin(hFile,
		glload.GetLoadAllCoreFuncName(version, spec, options))
end

function source.WriteBlockEndLoadAllCoreFunc(hFile, version, spec, options)
	glload.WriteLoaderFuncEnd(hFile)
end

function source.WriteBlockBeginLoadAllCoreCompFunc(hFile, version, spec, options)
	hFile:fmt("static int %s()\n",
		glload.GetLoadAllCoreCompFuncName(version, spec, options))
	hFile:write("{\n")
	hFile:inc()
	hFile:write("int numFailed = 0;\n")
end

function source.WriteBlockEndLoadAllCoreCompFunc(hFile, version, spec, options)
	hFile:write("return numFailed;\n")
	hFile:dec()
	hFile:write("}\n")
end

function source.WriteCallCoreLoad(hFile, sub_version, spec, options)
	hFile:fmt("numFailed += %s();\n",
		glload.GetLoadCoreFuncName(sub_version, spec, options))
end

function source.WriteCallCoreCompLoad(hFile, sub_version, spec, options)
	hFile:fmt("numFailed += %s();\n",
		glload.GetLoadCoreCompFuncName(sub_version, spec, options))
end



function source.WriteMainLoadPrelim(hFile, specData, spec, options)
	--Write the extension function mapping table.
	common.WriteCMappingTable(hFile, specData, spec, options,
		glload.GetMapTableStructName(spec, options),
		"ExtensionTable",
		glload.GetExtVariableName,
		glload.GetLoadExtensionFuncName)
	hFile:write "\n"
	
	--Write the function to find entries.
	common.WriteCFindExtEntryFunc(hFile, specData, spec,
							options, glload.GetMapTableStructName(spec, options),
							"ExtensionTable")
	hFile:write "\n"

	--Write the function to clear the extension variables.
	common.WriteCClearExtensionVarsFunc(hFile, specData, spec, options,
		glload.GetExtVariableName,
		"0")
	hFile:write "\n"

	--Write a function that loads an extension by name.
	common.WriteCLoadExtByNameFunc(hFile, specData, spec, options,
		glload.GetMapTableStructName(spec, options),
		spec.DeclPrefix() .. "LOAD_SUCCEEDED")
		
	if(options.version) then
		hFile:write "\n"
		
		--Write a table that maps from version X.Y profile Z to a loading function.
		hFile:fmtblock([[
typedef struct %s%sVersProfToLoaderMap_s
{
	int majorVersion;
	int minorVersion;
	int compatibilityProfile;
	PFN_LOADFUNCPOINTERS LoadVersion;
} %s;
]], options.prefix, spec.DeclPrefix(), "VersionMapEntry")
		hFile:write "\n"
		
		hFile:write("static VersionMapEntry g_versionMapTable[] =\n")
		hFile:write("{\n")
		hFile:inc()
		local numEntries = 0
		for _, version in ipairs(spec.GetCoreVersions()) do
			local major, minor = version:match("(%d+)%.(%d+)")
			hFile:fmt("{%s, %s, 0, %s},\n",
				major, minor,
				glload.GetLoadAllCoreFuncName(version, spec, options))
			numEntries = numEntries + 1
			if(my_style.FilterVersionHasCompProfile(version)) then
				hFile:fmt("{%s, %s, 1, %s},\n",
					major, minor,
					glload.GetLoadAllCoreCompFuncName(version, spec, options))
				numEntries = numEntries + 1
			end
		end
		hFile:dec()
		hFile:write("};\n")
		hFile:write "\n"
		hFile:fmt("static int g_numVersionMapEntries = %i;\n", numEntries)
		hFile:write "\n"
		
		--Write a function to find a map entry and call the loader, returning
		--the value.
		hFile:writeblock([[
static int LoadVersionFromMap(int major, int minor, int compatibilityProfile)
{
	int loop = 0;
	for(; loop < g_numVersionMapEntries; ++loop)
	{
		if(
			(g_versionMapTable[loop].majorVersion == major) &&
			(g_versionMapTable[loop].minorVersion == minor) &&
			(g_versionMapTable[loop].compatibilityProfile == compatibilityProfile))
		{
			return g_versionMapTable[loop].LoadVersion();
		}
	}
	
	return -1;
}
]])
		hFile:write "\n"
		
		--Write a function to get the current version from a string.
		hFile:writeblock(common.GetParseVersionFromString())
		hFile:write "\n"
		
		--Write function to load extensions from alist functions.
		local indexed = spec.GetIndexedExtStringFunc(options);
		common.FixupIndexedList(specData, indexed)
		hFile:writeblock(common.GetProcExtsFromExtListFunc(
			hFile, specData, spec, options,
			indexed, glload.GetFuncPtrName, glload.GetEnumeratorName))
		
	end
	hFile:write "\n"
	hFile:writeblock(common.GetProcessExtsFromStringFunc("LoadExtByName(%s)"))
end

local function FindFuncByName(specData, name)
	for _, func in ipairs(specData.funcData.functions) do
		if(name == func.name) then
			return func
		end
	end
end

function source.WriteMainLoader(hFile, specData, spec, options)
	if(options.version) then
		hFile:writeblock[[
static int g_majorVersion = 0;
static int g_minorVersion = 0;
]]
		hFile:write "\n"
	end

	hFile:fmt("int %sLoadFunctions(%s)\n", spec.DeclPrefix(), spec.GetLoaderParams())
	hFile:write "{\n"
	hFile:inc()
	
	if(options.version) then
		hFile:writeblock[[
int numFailed = 0;
int compProfile = 0;

g_majorVersion = 0;
g_minorVersion = 0;
]]
		hFile:write "\n"
	end
	
	hFile:write("ClearExtensionVars();\n")
	hFile:write "\n"
	
	--Load the extensions. Needs to be done differently based on the removal
	--of glGetString(GL_EXTENSIONS).
	if(options.version) then
		--Get the current version.
		--To do that, we need certain functions.
		local strFunc = FindFuncByName(specData, "GetString")
		
		hFile:writeblock(glload.GetInMainFuncLoader(hFile, strFunc, spec, options))
		strFunc = glload.GetFuncPtrName(strFunc, spec, options)
		
		hFile:write "\n"
		hFile:fmt("ParseVersionFromString(&g_majorVersion, &g_minorVersion, (const char*)%s(GL_VERSION));\n", strFunc)
		hFile:write "\n"
		
		--Load extensions in different ways, based on version.
		hFile:write("if(g_majorVersion < 3)\n")
		hFile:write "{\n"
		hFile:inc()
		--Load the file from a list of extensions. We already have the string getter.
		hFile:fmt("ProcExtsFromExtString((const char*)%s(GL_EXTENSIONS));\n", strFunc)
		hFile:dec()
		hFile:write "}\n"
		hFile:write "else\n"
		hFile:write "{\n"
		hFile:inc()
		--Load some additional functions.
		local indexed = spec.GetIndexedExtStringFunc(options);
		common.FixupIndexedList(specData, indexed)
		hFile:writeblock(glload.GetInMainFuncLoader(hFile, indexed[1], spec, options))
		hFile:writeblock(glload.GetInMainFuncLoader(hFile, indexed[3], spec, options))
		hFile:write("\n")
		hFile:write("ProcExtsFromExtList();\n")
		hFile:dec()
		hFile:write "}\n"
	else
		local extListName, needLoad = spec.GetExtStringFuncName()
		if(needLoad) then
			extListName = FindFuncByName(specData, extListName)
			
			hFile:writeblock(glload.GetInMainFuncLoader(hFile, extListName, spec, options))

			extListName = glload.GetFuncPtrName(extListName, spec, options);
		end

		local function EnumResolve(enumName)
			return GetEnumName(specData.enumtable[enumName], spec, options)
		end
		
		hFile:write "\n"
		hFile:fmt("ProcExtsFromExtString((const char *)%s(%s));\n",
			extListName,
			spec.GetExtStringParamList(EnumResolve))
	end
	
	hFile:write "\n"
	--Write the core loading, if any.
	if(options.version) then
		--Step 1: figure out if we're core or compatibility. Only applies
		--to GL 3.1+
		hFile:writeblock [[
if(g_majorVersion >= 3)
{
	if(g_majorVersion == 3 && g_minorVersion == 0)
	{ /*Deliberately empty. Core/compatibility didn't exist til 3.1.*/
	}
	else if(g_majorVersion == 3 && g_minorVersion == 1)
	{
		if(glext_ARB_compatibility)
			compProfile = 1;
	}
	else
	{
		GLint iProfileMask = 0;
		glGetIntegerv(GL_CONTEXT_PROFILE_MASK, &iProfileMask);
		
		if(!iProfileMask)
		{
			if(glext_ARB_compatibility)
				compProfile = 1;
		}
		else
		{
			if(iProfileMask & GL_CONTEXT_COMPATIBILITY_PROFILE_BIT)
				compProfile = 1;
		}
	}
}
]]
		hFile:write "\n"

		--Step 2: load the version.
		local major, minor = options.version:match("(%d+)%.(%d+)")

		hFile:fmtblock([[
numFailed = LoadVersionFromMap(g_majorVersion, g_minorVersion, compProfile);
if(numFailed == -1) /*Couldn't find something to load.*/
{
	/*Unable to find a compatible one. Load max version+compatibility.*/
	numFailed = LoadVersionFromMap(%i, %i, 1);
	if(numFailed == -1) /*Couldn't even load it.*/
		return %sLOAD_FAILED;
}

return %sLOAD_SUCCEEDED + numFailed;
]], major, minor, spec.DeclPrefix(), spec.DeclPrefix())
		
	else
		hFile:fmt("return %s;\n", spec.DeclPrefix() .. "LOAD_SUCCEEDED")
	end
	
	hFile:dec()
	hFile:write "}\n"
end

function source.WriteMainExtraFuncs(hFile, specData, spec, options)
	hFile:writeblock[[
int GetMajorVersion() { return g_majorVersion; }
int GetMinorVersion() { return g_minorVersion; }

int IsVersionGEQ( int testMajorVersion, int testMinorVersion )
{
	if(g_majorVersion > testMajorVersion) return 1;
	if(g_majorVersion < testMajorVersion) return 0;
	if(g_minorVersion >= testMinorVersion) return 1;
	return 0;
}
]]
end

------------------------------------------------------
-- Filters

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


function my_style.FilterVersionHasCompProfile(version)
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
