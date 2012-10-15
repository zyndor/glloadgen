
local common = require "CommonStyle"


local my_style = {}
my_style.header = {}
my_style.source = {}

function my_style.WriteLargeHeading(hFile, headingName)
	hFile:write("/*", string.rep("*", #headingName), "*/\n")
	hFile:write("/*", headingName, "*/\n")
end

function my_style.WriteSmallHeading(hFile, headingName)
	hFile:write("/*", headingName, "*/\n")
end

----------------------------------------------------------------
-- Header file construction

function my_style.header.CreateFile(basename, options)
	local filename = basename .. ".h"
	return common.CreateFile(filename, options.indent), filename
end


local function GetIncludeGuard(hFile, spec, options)
	local str = "POINTER_C_GENERATED_HEADER_" ..
		spec.GetIncludeGuardString() .. "_H"

	if(#options.prefix > 0) then
		return options.prefix:upper() .. "_" .. str
	end
	
	return str
end

function my_style.header.WriteBeginIncludeGuard(hFile, spec, options)
	local inclGuard = GetIncludeGuard(hFile, spec, options)
	
	hFile:fmt("#ifndef %s\n", inclGuard)
	hFile:fmt("#define %s\n", inclGuard)
end

function my_style.header.WriteEndIncludeGuard(hFile, spec, options)
	local inclGuard = GetIncludeGuard(hFile, spec, options)
	
	hFile:fmt("#endif //%s\n", inclGuard)
end

function my_style.header.WriteStdTypedefs(hFile, specData, options)
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

function my_style.header.WriteSpecTypedefs(hFile, specData, options)
	hFile:push()
	common.WritePassthruData(hFile, specData.funcData.passthru)
	hFile:write("\n")
	hFile:pop()
end

function my_style.header.WriteBeginDecl(hFile, specData, options)
	common.WriteExternCStart(hFile)
end

function my_style.header.WriteBeginExtVarDeclBlock(hFile, spec, options)
end

function my_style.header.WriteEndExtVarDeclBlock(hFile, spec, options)
end

local function GetExtVariableName(extName, spec, options)
	return options.prefix .. spec.DeclPrefix() .. "ext_" .. extName
end

function my_style.header.WriteExtVariableDecl(hFile, extName, specData, spec, options)
	hFile:write("extern int ", GetExtVariableName(extName, spec, options), ";\n");
end

function my_style.header.WriteBeginEnumDeclBlock(hFile, specData, options) end

function my_style.header.WriteEndEnumDeclBlock(hFile, specData, options) end

local function GetEnumName(enum, spec, options)
	return spec.EnumNamePrefix() .. enum.name
end

function my_style.header.WriteEnumDecl(hFile, enum, enumTable, spec, options)
	hFile:fmt("#define %s %s\n",
		GetEnumName(enum, spec, options),
		common.ResolveEnumValue(enum, enumTable))
end

function my_style.header.WriteEnumPrevDecl(hFile, enum, enumTable, spec, options, extName)
	hFile:fmt("/*Copied %s%s From: %s*/\n",
		spec.EnumNamePrefix(),
		enum.name,
		extName)
end

function my_style.header.WriteBeginFuncDeclBlock(hFile, specData, options)
end

local function GetFuncPtrName(func, spec, options)
	return options.prefix .. "_ptrc_".. spec.FuncNamePrefix() .. func.name
end

local function GetFuncPtrDef(hFile, func, typemap, spec, options)
	return string.format("%s (%s *%s)(%s)",
		common.GetFuncReturnType(func, typemap),
		spec.GetCodegenPtrType(),
		GetFuncPtrName(func, spec, options),
		common.GetFuncParamList(func, typemap))
end

function my_style.header.WriteFuncDecl(hFile, func, typemap, spec, options)
	--Declare the function pointer.
	hFile:write("extern ",
		GetFuncPtrDef(hFile, func, typemap, spec, options),
		";\n")
	
	--#define it to the proper OpenGL name.
	hFile:fmt("#define %s %s\n",
		common.GetOpenGLFuncName(func, spec),
		GetFuncPtrName(func, spec, options))
end

function my_style.header.WriteEndFuncDeclBlock(hFile, specData, options)
end

function my_style.header.WriteBeginExtFuncDeclBlock(hFile, extName,
	spec, options)
	hFile:fmt("#ifndef %s\n", spec.ExtNamePrefix() .. extName)
	hFile:fmt("#define %s 1\n", spec.ExtNamePrefix() .. extName)
end

function my_style.header.WriteEndExtFuncDeclBlock(hFile, extName,
	spec, options)
	hFile:fmt("#endif /*%s*/ \n", spec.ExtNamePrefix() .. extName)
end

function my_style.header.WriteBeginSysDeclBlock(hFile, spec, options)
end

function my_style.header.WriteEndSysDeclBlock(hFile, spec, options)
end

local function GetStatusCodeEnumName(spec, options)
	return string.format("%s%sLoadStatus", options.prefix, spec.DeclPrefix())
end

local function GetStatusCodeName(name, spec, options)
	return string.format("%s%s%s", options.prefix, spec.DeclPrefix(), name)
end

function my_style.header.WriteUtilityDecls(hFile, spec, options)
	hFile:fmt("enum %s\n", GetStatusCodeEnumName(spec, options))
	hFile:write("{\n")
	hFile:inc()
		hFile:write(GetStatusCodeName("LOAD_FAILED", spec, options), " = 0,\n")
		hFile:write(GetStatusCodeName("LOAD_SUCCEEDED", spec, options), " = 1,\n")
	hFile:dec()
	hFile:write("};\n")
end

local function DecorateFuncName(name, spec, options)
	return string.format("%s%s%s", options.prefix, spec.DeclPrefix(), name)
end

local function GetLoaderFuncName(spec, options)
	return DecorateFuncName("LoadFunctions", spec, options)
end

function my_style.header.WriteMainLoaderFuncDecl(hFile, spec, options)
	hFile:fmt("int %s(%s);\n",
		GetLoaderFuncName(spec, options),
		spec.GetLoaderParams())
end

function my_style.header.WriteVersioningFuncDecls(hFile, spec, options)
	--Only for GL
	if(options.spec ~= "gl") then
		return
	end
	
	hFile:fmt("int %s();\n", DecorateFuncName("GetMinorVersion", spec, options))
	hFile:fmt("int %s();\n", DecorateFuncName("GetMajorVersion", spec, options))
	hFile:fmt("int %s(int majorVersion, int minorVersion);\n",
		DecorateFuncName("IsVersionGEQ", spec, options))
end

function my_style.header.WriteEndDecl(hFile, specData, options)
	common.WriteExternCEnd(hFile)
end

--------------------------------------------------
-- Source file construction functions.

function my_style.source.CreateFile(basename, options)
	local filename = basename .. ".c"
	return common.CreateFile(filename, options.indent), filename
end

function my_style.source.WriteIncludes(hFile, spec, options)
	hFile:writeblock([[
#include <stdlib.h>
#include <string.h>
#ifdef WIN32
#define strcasecmp(lhs, rhs) _stricmp((lhs), (rhs))
#endif
]])
	hFile:write("\n")
	
end

function my_style.source.WriteBeginDef(hFile, spec, options) end
function my_style.source.WriteEndDef(hFile, spec, options) end

function my_style.source.WriteBeginExtVarDefBlock(hFile, spec, options)
end

function my_style.source.WriteEndExtVarDefBlock(hFile, spec, options)
end

function my_style.source.WriteExtVariableDef(hFile, extName, specData, spec, options)
	hFile:fmt("int %s = %s;\n", GetExtVariableName(extName, spec, options),
		GetStatusCodeName("LOAD_FAILED", spec, options));
end

function my_style.source.WriteBeginExtFuncDefBlock(hFile, extName, spec, options)
end

function my_style.source.WriteEndExtFuncDefBlock(hFile, extName, spec, options)
end

function my_style.source.WriteFuncDef(hFile, func, typemap, spec, options)
	--Declare the function pointer.
	hFile:fmt("%s = NULL;\n",
		GetFuncPtrDef(hFile, func, typemap, spec, options))
end

local function GetExtLoaderFuncName(extName, spec, options)
	return "Load_" .. extName;
end

function my_style.source.WriteBeginExtLoaderBlock(hFile, extName, spec, options)
	hFile:fmt("static int %s()\n", GetExtLoaderFuncName(extName, spec, options))
	hFile:write("{\n")
	hFile:inc()
	hFile:write("int numFailed = 0;\n")
end

function my_style.source.WriteEndExtLoaderBlock(hFile, extName, spec, options)
	hFile:write("return numFailed;\n")
	hFile:dec()
	hFile:write("}\n")
end

function my_style.source.WriteExtFuncLoader(hFile, func, typemap, spec, options)
	hFile:fmt('%s = %s("%s%s");\n',
		GetFuncPtrName(func, spec, options),
		common.GetProcAddressName(spec),
		spec.FuncNamePrefix(), func.name)
	hFile:fmt('if(!%s) numFailed++;\n', GetFuncPtrName(func, spec, options))
end

function my_style.source.WriteBeginCoreFuncDefBlock(hFile, version, spec, options)
end

function my_style.source.WriteEndCoreFuncDefBlock(hFile, version, spec, options)
end

local function GetCoreLoaderFuncName(version, spec, options)
	return "Load_Version_" .. version:gsub("%.", "_")
end

function my_style.source.WriteBeginCoreLoaderBlock(hFile, version, spec, options)
	hFile:fmt("static int %s()\n", GetCoreLoaderFuncName(version, spec, options))
	hFile:write("{\n")
	hFile:inc()
	hFile:write("int numFailed = 0;\n")
end

function my_style.source.WriteEndCoreLoaderBlock(hFile, version, spec, options)
	hFile:write("return numFailed;\n")
	hFile:dec()
	hFile:write("}\n")
end

function my_style.source.WriteCoreFuncLoader(hFile, func, typemap, spec, options)
	hFile:fmt('%s = %s("%s%s");\n',
		GetFuncPtrName(func, spec, options),
		common.GetProcAddressName(spec),
		spec.FuncNamePrefix(), func.name)

	--Special hack for DSA_EXT functions in core functions.
	--They do not count against the loaded count.
	if(func.name:match("EXT$")) then
		hFile:write("/*An EXT_direct_state_access-based function. Don't count it.*/")
	else
		hFile:fmt('if(!%s) numFailed++;\n', GetFuncPtrName(func, spec, options))
	end
end

function my_style.source.WriteGetExtStringFuncDef(hFile, func, typemap, spec, options)
	my_style.source.WriteFuncDef(hFile, func, typemap, spec, options)
end

local function GetMapTableStructName(spec, options)
	return string.format("%s%sStrToExtMap", options.prefix, spec.DeclPrefix())
end

local function GetMapTableVarName()
	return "ExtensionMap"
end

function my_style.source.WriteBeginSysDefBlock(hFile, spec, options)
end

function my_style.source.WriteEndSysDefBlock(hFile, spec, options)
end

function my_style.source.WriteUtilityDefs(hFile, specData, spec, options)
	--Write the struct for the mapping table.
	hFile:write("typedef int (*PFN_LOADEXTENSION)();\n")
	hFile:fmt("typedef struct %s%sStrToExtMap_s\n",
		options.prefix, spec.DeclPrefix())
	hFile:write("{\n")
	hFile:inc()
	hFile:write("char *extensionName;\n")
	hFile:write("int *extensionVariable;\n")
	hFile:write("PFN_LOADEXTENSION LoadExtension;\n")
	hFile:dec()
	hFile:fmt("} %s;\n", GetMapTableStructName(spec, options))
	hFile:write "\n"
	
	--Write the mapping table itself.
	hFile:fmt("static %s %s[] = {\n",
		GetMapTableStructName(spec, options),
		GetMapTableVarName())
	hFile:inc()
	for _, extName in ipairs(options.extensions) do
		if(#specData.extdefs[extName].funcs > 0) then
			hFile:fmt('{"%s", &%s, %s},\n',
				spec.ExtNamePrefix() .. extName,
				GetExtVariableName(extName, spec, options),
				GetExtLoaderFuncName(extName, spec, options))
		else
			hFile:fmt('{"%s", &%s, NULL},\n',
				spec.ExtNamePrefix() .. extName,
				GetExtVariableName(extName, spec, options))
		end
	end
	hFile:dec()
	hFile:write("};\n")
	hFile:write "\n"
	
	hFile:fmt("static int g_extensionMapSize = %i;\n", #options.extensions);
	hFile:write "\n"
	
	--Write function to find map entry by name.
	hFile:fmt("static %s *FindExtEntry(const char *extensionName)\n",
		GetMapTableStructName(spec, options))
	hFile:write("{\n")
	hFile:inc()
	hFile:write("int loop;\n")
	hFile:fmt("%s *currLoc = %s;\n",
		GetMapTableStructName(spec, options),
		GetMapTableVarName())
	hFile:writeblock([[
for(loop = 0; loop < g_extensionMapSize; ++loop, ++currLoc)
{
	if(strcasecmp(extensionName, currLoc->extensionName) == 0)
		return currLoc;
}

return NULL;
]])
	hFile:dec()
	hFile:write("}\n")
	hFile:write "\n"

	--Write the function to clear the extension variables.
	hFile:fmt("static void ClearExtensionVars()\n")
	hFile:write("{\n")
	hFile:inc()
	for _, extName in ipairs(options.extensions) do
		hFile:fmt('%s = %s;\n',
			GetExtVariableName(extName, spec, options),
			GetStatusCodeName("LOAD_FAILED", spec, options))
	end
	hFile:dec()
	hFile:write("}\n")
	hFile:write "\n"
	
	--Write a function that loads an extension by name. It is called when
	--processing, so it should also set the extension variable based on the load.
	hFile:writeblock([[
static void LoadExtByName(const char *extensionName)
{
	]] .. GetMapTableStructName(spec, options) .. [[ *entry = NULL;
	entry = FindExtEntry(extensionName);
	if(entry)
	{
		if(entry->LoadExtension)
		{
			int numFailed = entry->LoadExtension();
			if(numFailed == 0)
			{
				*(entry->extensionVariable) = ]] ..
				GetStatusCodeName("LOAD_SUCCEEDED", spec, options) ..
				[[;
			}
			else
			{
				*(entry->extensionVariable) = ]] ..
				GetStatusCodeName("LOAD_SUCCEEDED", spec, options) ..
				[[ + numFailed;
			}
		}
		else
		{
			*(entry->extensionVariable) = ]] ..
			GetStatusCodeName("LOAD_SUCCEEDED", spec, options) ..
			[[;
		}
	}
}
]])

	hFile:write "\n"
	
end

local function WriteAncillaryFuncs(hFile, specData, spec, options)
	local indexed = spec.GetIndexedExtStringFunc(options);
	if(indexed) then
		for _, func in ipairs(specData.funcData.functions) do
			if(indexed[1] == func.name) then
				indexed[1] = func
			end
			if(indexed[3] == func.name) then
				indexed[3] = func
			end
		end
		for _, enum in ipairs(specData.enumerations) do
			if(indexed[2] == enum.name) then
				indexed[2] = enum
			end
			if(indexed[4] == enum.name) then
				indexed[4] = enum
			end
		end
	
		hFile:writeblock([[
static void ProcExtsFromExtList()
{
	GLint iLoop;
	GLint iNumExtensions = 0;
	]] .. GetFuncPtrName(indexed[1], spec, options)
	.. [[(]] .. GetEnumName(indexed[2], spec, options)
	.. [[, &iNumExtensions);

	for(iLoop = 0; iLoop < iNumExtensions; iLoop++)
	{
		const char *strExtensionName = (const char *)]] ..
		GetFuncPtrName(indexed[3], spec, options) ..
		[[(]] .. GetEnumName(indexed[4], spec, options) .. [[, iLoop);
		LoadExtByName(strExtensionName);
	}
}
]])
	else
		hFile:writeblock(common.GetProcessExtsFromStringFunc("LoadExtByName"))
	end
	
	hFile:write "\n"

	return indexed
end

local function WriteInMainFuncLoader(hFile, func, spec, options)
	hFile:fmt('%s = %s("%s%s");\n',
		GetFuncPtrName(func, spec, options),
		common.GetProcAddressName(spec),
		spec.FuncNamePrefix(), func.name)
	hFile:fmt('if(!%s) return %s;\n',
		GetFuncPtrName(func, spec, options),
		GetStatusCodeName("LOAD_FAILED", spec, options))
end


function my_style.source.WriteMainLoaderFunc(hFile, specData, spec, options)
	local indexed = WriteAncillaryFuncs(hFile, specData, spec, options)

	--Write the function that calls the extension and core loaders.
	hFile:fmt("int %s(%s)\n",
		GetLoaderFuncName(spec, options),
		spec.GetLoaderParams())
	hFile:write("{\n")
	hFile:inc()

	if(options.version) then
		hFile:write("int numFailed = 0;\n")
	end

	hFile:write("ClearExtensionVars();\n")
	hFile:write("\n")

	--Load the extension, using runtime-facilities to tell what is available.
	if(indexed) then
		WriteInMainFuncLoader(hFile, indexed[1], spec, options)
		WriteInMainFuncLoader(hFile, indexed[3], spec, options)
		hFile:write("\n")
		hFile:write("ProcExtsFromExtList();\n")
	else
		local extListName, needLoad = spec.GetExtStringFuncName()
		if(needLoad) then
			for _, func in ipairs(specData.funcData.functions) do
				if(extListName == func.name) then
					extListName = func
				end
			end
			
			WriteInMainFuncLoader(hFile, extListName, spec, options)
			
			extListName = GetFuncPtrName(extListName, spec, options);
		end

		local function EnumResolve(enumName)
			return GetEnumName(specData.enumtable[enumName], spec, options)
		end
		
		hFile:write "\n"
		hFile:fmt("ProcExtsFromExtString((const char *)%s(%s));\n",
			extListName,
			spec.GetExtStringParamList(EnumResolve))
	end
	
	if(options.version) then
		hFile:fmt("numFailed = %s();\n",
			GetCoreLoaderFuncName(options.version, spec, options))
		hFile:write "\n"
		
		hFile:fmtblock([[
if(numFailed == 0)
	return %s;
else
	return %s + numFailed;
]],
			GetStatusCodeName("LOAD_SUCCEEDED", spec, options),
			GetStatusCodeName("LOAD_SUCCEEDED", spec, options))
	else
		hFile:fmt("return %s;\n",
			GetStatusCodeName("LOAD_SUCCEEDED", spec, options))
	end
	
	hFile:dec()
	hFile:write("}\n")
end

function my_style.source.WriteVersioningFuncs(hFile, specData, spec, options)
	--Only for GL
	if(options.spec ~= "gl") then
		return
	end
	
	hFile:fmt("static int g_major_version = 0;\n")
	hFile:fmt("static int g_minor_version = 0;\n")
	hFile:write "\n"
	
	if(tonumber(options.version) >= 3.0) then
		hFile:writeblock([[
static void GetGLVersion()
{
	glGetIntegerv(GL_MAJOR_VERSION, &g_major_version);
	glGetIntegerv(GL_MINOR_VERSION, &g_minor_version);
}
]])
	else
		hFile:writeblock(common.GetParseVersionFromString())
		hFile:write "\n"
		
		hFile:writeblock([[
static void GetGLVersion()
{
	ParseVersionFromString(&g_major_version, &g_minor_version, glGetString(GL_VERSION));
}
]])
	end
	
	hFile:write "\n"
	hFile:fmt("int %s()\n", DecorateFuncName("GetMinorVersion", spec, options))
	hFile:writeblock([[
{
	if(g_major_version == 0)
		GetGLVersion();
	return g_major_version;
}
]])
	hFile:write "\n"

	hFile:fmt("int %s()\n", DecorateFuncName("GetMajorVersion", spec, options))
	hFile:writeblock([[
{
	if(g_major_version == 0) //Yes, check the major version to get the minor one.
		GetGLVersion();
	return g_minor_version;
}
]])
	hFile:write "\n"
	
	hFile:fmt("int %s(int majorVersion, int minorVersion)\n",
		DecorateFuncName("IsVersionGEQ", spec, options))
	hFile:writeblock([[
{
	if(g_major_version == 0)
		GetGLVersion();
		
	if(majorVersion > g_major_version) return 1;
	if(majorVersion < g_major_version) return 0;
	if(minorVersion >= g_minor_version) return 1;
	return 0;
}
]])

end



--------------------------------------------------
-- Style retrieval machinery

local function Create()
	return common.DeepCopyTable(my_style)
end

return { Create = Create }
