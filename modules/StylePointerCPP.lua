
local common = require "CommonStyle"

local my_style = {}
my_style.header = {}
my_style.source = {}

----------------------------------------------------
-- Global styling functions.
function my_style.WriteLargeHeading(hFile, headingName)
	hFile:write(string.rep("/", 6 + #headingName), "\n")
	hFile:write("// ", headingName, "\n")
	hFile:write(string.rep("/", 6 + #headingName), "\n")
end

function my_style.WriteSmallHeading(hFile, headingName)
	hFile:write("// ", headingName, "\n")
end

------------------------------------------------------
-- Header styling functions

function my_style.header.CreateFile(basename, options)
	local filename = basename .. ".hpp"
	return common.CreateFile(filename, options.indent), filename
end

	local function GenIncludeGuardName(hFile, spec, options)
		local str = "POINTER_CPP_GENERATED_HEADER" ..
			spec.GetIncludeGuardString() .. "_HPP"

		if(#options.prefix > 0) then
			return options.prefix:upper() .. "_" .. str
		end
		
		return str
	end

function my_style.header.WriteBeginIncludeGuard(hFile, spec, options)
	local inclGuard = GenIncludeGuardName(hFile, spec, options)
	
	hFile:fmt("#ifndef %s\n", inclGuard)
	hFile:fmt("#define %s\n", inclGuard)
end

function my_style.header.WriteEndIncludeGuard(hFile, spec, options)
	hFile:fmt("#endif //%s\n", GenIncludeGuardName(hFile, spec, options))
end

function my_style.header.WriteStdTypedefs(hFile, specData, spec, options)
	local defArray = common.GetStdTypedefs()
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
end

function my_style.header.WriteSpecTypedefs(hFile, specData, spec, options)
	hFile:push()
	common.WritePassthruData(hFile, specData.funcData.passthru)
	hFile:pop()
end

	local function StartNamespace(hFile, namespaceName)
		hFile:fmt("namespace %s\n", namespaceName or "")
		hFile:write("{\n")
		hFile:inc()
	end

	local function EndNamespace(hFile, namespaceName)
		hFile:dec()
		hFile:fmt("} //namespace %s\n", namespaceName or "")
	end

function my_style.header.WriteBeginDecl(hFile, spec, options)
	if(#options.prefix > 0) then
		StartNamespace(hFile, options.prefix)
	end
	StartNamespace(hFile, spec.FuncNamePrefix())
end

function my_style.header.WriteEndDecl(hFile, spec, options)
	EndNamespace(hFile, spec.FuncNamePrefix())
	if(#options.prefix > 0) then
		EndNamespace(hFile, options.prefix)
	end
end

	local extBlockNamespace = "exts"
	local extVariableTypeDefinition = [[
class LoadTest
{
private:
	//Safe bool idiom. Joy!
	typedef void (LoadTest::*bool_type)() const;
	void big_long_name_that_really_doesnt_matter() const {}
	
public:
	operator bool_type() const
	{
		return m_isLoaded ? &LoadTest::big_long_name_that_really_doesnt_matter : 0;
	}
	
	int GetNumMissing() const {return m_numMissing;}
	
	LoadTest() : m_isLoaded(false), m_numMissing(0) {}
	LoadTest(bool isLoaded, int numMissing) : m_isLoaded(isLoaded), m_numMissing(numMissing) {}
private:
	bool m_isLoaded;
	int m_numMissing;
};
]]

function my_style.header.WriteBeginExtVarDeclBlock(hFile, spec, options)
	StartNamespace(hFile, extBlockNamespace)
	hFile:writeblock(extVariableTypeDefinition)
	hFile:write("\n")
end

function my_style.header.WriteEndExtVarDeclBlock(hFile, spec, options)
	EndNamespace(hFile, extBlockNamespace)
end

	local function GenExtensionVarName(extName, spec, options)
		return "var_" .. extName;
	end

function my_style.header.WriteExtVariableDecl(hFile, extName,
	specData, spec, options)
	hFile:fmt("extern LoadTest %s;\n",
		GenExtensionVarName(extName, spec, options));
end

function my_style.header.WriteBeginEnumDeclBlock(hFile, spec, options)
	hFile:write("enum\n")
	hFile:write("{\n")
	hFile:inc()
end

function my_style.header.WriteEndEnumDeclBlock(hFile, spec, options)
	hFile:dec()
	hFile:write("};\n")
end

	local function GenEnumName(enum)
		--Note: some enumerators start with characters C++ forbids as initial
		--identifiers. If we detect such an enum, prefix it with `_`.
		--Also, certain identifiers can need it.
		local enumName = enum.name
		if(not enumName:match("^[a-zA-Z_]")) then
			enumName = "_" .. enumName
		end
		
		local badIdent = {"TRUE", "FALSE", "NO_ERROR", "WAIT_FAILED"}
		for _, ident in ipairs(badIdent) do
			if(enumName == ident) then
				enumName = enumName .. "_"
				break
			end
		end
		
		return enumName
	end

function my_style.header.WriteEnumDecl(hFile, enum, enumTable, spec, options)
	local enumName = GenEnumName(enum)
	local lenEnum = #enumName
	local numIndent = 33
	
	local numSpaces = numIndent - lenEnum
	if(numSpaces < 1) then
		numSpaces = 1
	end

	hFile:fmt("%s%s= %s,\n",
		enumName,
		string.rep(" ", numSpaces),
		common.ResolveEnumValue(enum, enumTable))
end

function my_style.header.WriteEnumPrevDecl(hFile, enum, enumTable, spec, options, extName)
	hFile:fmt("//%s taken from ext: %s\n", enum.name, extName)
end

function my_style.header.WriteBeginFuncDeclBlock(hFile, spec, options)
	--Block containing all spec function declarations.
end

function my_style.header.WriteEndFuncDeclBlock(hFile, spec, options)
	--Block containing all spec function declarations.
end

function my_style.header.WriteBeginExtFuncDeclBlock(hFile, extName, spec, options)
	--Block containing all spec function declarations for a particular extension.
	--Useful for include-guards around extension function pointers.
end

function my_style.header.WriteEndExtFuncDeclBlock(hFile, extName, spec, options)
	--Block containing all spec function declarations for a particular extension.
end

	local function GenFuncPtrName(func, spec, options)
		return func.name
	end

	local function GenFuncPtrTypedefName(func, spec, options)
		return "PFN" .. GenFuncPtrName(func, spec, options):upper()
	end

	local function WriteFuncPtrTypedefStmt(hFile, func, typemap, spec, options)
		hFile:fmt("typedef %s (%s *%s)(%s);\n",
			common.GetFuncReturnType(func, typemap),
			spec.GetCodegenPtrType(),
			GenFuncPtrTypedefName(func, spec, options),
			common.GetFuncParamList(func, typemap))
	end

	local function GenFuncPtrDefDirect(func, typemap, spec, options)
		return string.format("%s (%s *%s)(%s)",
			common.GetFuncReturnType(func, typemap),
			spec.GetCodegenPtrType(),
			GenFuncPtrName(func, spec, options),
			common.GetFuncParamList(func, typemap, true))
	end

	local function GenFuncPtrDefTypedef(func, typemap, spec, options)
		return string.format("%s %s",
			GenFuncPtrTypedefName(func, spec, options),
			GenFuncPtrName(func, spec, options))
	end

function my_style.header.WriteFuncDecl(hFile, func, typemap, spec, options)
	hFile:write("extern ",
		GenFuncPtrDefDirect(func, typemap, spec, options),
		";\n")
end

function my_style.header.WriteBeginSysDeclBlock(hFile, spec, options)
	StartNamespace(hFile, "sys")
end

function my_style.header.WriteEndSysDeclBlock(hFile, spec, options)
	EndNamespace(hFile, "sys")
end

function my_style.header.WriteUtilityDecls(hFile, spec, options)
	--Write declarations for public utility stuff. Enums for return values, etc.
end

function my_style.header.WriteMainLoaderFuncDecl(hFile, spec, options)
	hFile:fmt("%s::LoadTest LoadFunctions(%s);\n", extBlockNamespace, spec.GetLoaderParams())
end

function my_style.header.WriteVersioningFuncDecls(hFile, spec, options)
	hFile:writeblock([[
int GetMinorVersion();
int GetMajorVersion();
bool IsVersionGEQ(int majorVersion, int minorVersion);
]])
end

--------------------------------------------------
-- Source code styling functions.
function my_style.source.CreateFile(basename, options)
	return common.CreateFile(basename .. ".cpp", options.indent)
end

function my_style.source.WriteIncludes(hFile, spec, options)
	hFile:writeblock([[
#include <algorithm>
#include <vector>
#include <string.h>
#ifdef WIN32
#define strcasecmp(lhs, rhs) _stricmp((lhs), (rhs))
#endif
]])
end

function my_style.source.WriteBeginDef(hFile, spec, options)
	if(#options.prefix > 0) then
		StartNamespace(hFile, options.prefix)
	end
	StartNamespace(hFile, spec.FuncNamePrefix())
end

function my_style.source.WriteEndDef(hFile, spec, options)
	EndNamespace(hFile, spec.FuncNamePrefix())
	if(#options.prefix > 0) then
		EndNamespace(hFile, options.prefix)
	end
end

function my_style.source.WriteBeginExtVarDefBlock(hFile, spec, options)
	StartNamespace(hFile, extBlockNamespace)
end

function my_style.source.WriteEndExtVarDefBlock(hFile, spec, options)
	EndNamespace(hFile, extBlockNamespace)
end

function my_style.source.WriteExtVariableDef(hFile, extName,
	specData, spec, options)
	hFile:fmt("LoadTest %s;\n",
		GenExtensionVarName(extName, spec, options));
end

function my_style.source.WriteBeginExtFuncDefBlock(hFile, extName, spec, options)
	--Block containing the extension function definitions and load function
	--for the functions in the extension `extName`.
end

function my_style.source.WriteEndExtFuncDefBlock(hFile, extName, spec, options)
	--Block containing the extension function definitions and load function
	--for the functions in the extension `extName`.
end

function my_style.source.WriteFuncDef(hFile, func, typemap, spec, options)
	WriteFuncPtrTypedefStmt(hFile, func, typemap, spec, options)
	hFile:write(GenFuncPtrDefTypedef(func, typemap, spec, options),
		" = 0;\n")
end

	local function GenExtLoaderFuncName(extName, spec, options)
		return "Load_" .. extName;
	end

function my_style.source.WriteBeginExtLoaderBlock(hFile, extName, spec, options)
	hFile:fmt("static int %s()\n", GenExtLoaderFuncName(extName, spec, options))
	hFile:write("{\n")
	hFile:inc()
	hFile:write("int numFailed = 0;\n")
end

function my_style.source.WriteEndExtLoaderBlock(hFile, extName, spec, options)
	hFile:write "return numFailed;\n"
	hFile:dec()
	hFile:write("}\n")
end

function my_style.source.WriteExtFuncLoader(hFile, func, typemap, spec, options)
	hFile:fmt('%s = reinterpret_cast<%s>(%s("%s%s"));\n',
		GenFuncPtrName(func, spec, options),
		GenFuncPtrTypedefName(func, spec, options),
		common.GetProcAddressName(spec),
		spec.FuncNamePrefix(), func.name)
	hFile:fmt('if(!%s) ++numFailed;\n', GenFuncPtrName(func, spec, options))
end

function my_style.source.WriteBeginCoreFuncDefBlock(hFile, version, spec, options)
	--Block containing the core functions for `version`.
	--The block also contains the loading function for this version.
end

function my_style.source.WriteEndCoreFuncDefBlock(hFile, version, spec, options)
	--Block containing the core functions for `version`.
end

function my_style.source.WriteGetExtStringFuncDef(hFile, func, typemap,
	spec, options)
	WriteFuncPtrTypedefStmt(hFile, func, typemap, spec, options)
	hFile:write("static ", GenFuncPtrDefTypedef(func, typemap, spec, options),
		" = 0;\n")
end

	local function GenCoreLoaderFuncName(version, spec, options)
		return "LoadCoreFunctions"
	end

function my_style.source.WriteBeginCoreLoaderBlock(hFile, version, spec, options)
	hFile:fmt("static int %s()\n", GenCoreLoaderFuncName(version, spec, options))
	hFile:write("{\n")
	hFile:inc()
	hFile:write("int numFailed = 0;\n")

end

function my_style.source.WriteEndCoreLoaderBlock(hFile, version, spec, options)
	hFile:write "return numFailed;\n"
	hFile:dec()
	hFile:write("}\n")
end

function my_style.source.WriteCoreFuncLoader(hFile, func, typemap, spec, options)
	hFile:fmt('%s = reinterpret_cast<%s>(%s("%s%s"));\n',
		GenFuncPtrName(func, spec, options),
		GenFuncPtrTypedefName(func, spec, options),
		common.GetProcAddressName(spec),
		spec.FuncNamePrefix(), func.name)
		
	--Special hack for DSA_EXT functions in core functions.
	--They do not count against the loaded count.
	if(func.name:match("EXT$")) then
		hFile:write("//An EXT_direct_state_access-based function. Don't count it if it fails to load.\n")
	else
		hFile:fmt('if(!%s) ++numFailed;\n', GenFuncPtrName(func, spec, options))
	end
end

function my_style.source.WriteBeginSysDefBlock(hFile, spec, options)
	StartNamespace(hFile, "sys")
end

function my_style.source.WriteEndSysDefBlock(hFile, spec, options)
	EndNamespace(hFile, "sys")
end

function my_style.source.WriteUtilityDefs(hFile, specData, spec, options)
	--Write our mapping table definitions.
	StartNamespace(hFile)
	hFile:writeblock[[
typedef int (*PFN_LOADEXTENSION)();
struct MapEntry
{
	MapEntry(const char *_extName, exts::LoadTest *_extVariable)
		: extName(_extName)
		, extVariable(_extVariable)
		, loaderFunc(0)
		{}
		
	MapEntry(const char *_extName, exts::LoadTest *_extVariable, PFN_LOADEXTENSION _loaderFunc)
		: extName(_extName)
		, extVariable(_extVariable)
		, loaderFunc(_loaderFunc)
		{}
	
	const char *extName;
	exts::LoadTest *extVariable;
	PFN_LOADEXTENSION loaderFunc;
};

struct MapCompare
{
	MapCompare(const char *test_) : test(test_) {}
	bool operator()(const MapEntry &other) { return strcasecmp(test, other.extName) == 0; }
	const char *test;
};

]]

	--Write the table initialization function.
	hFile:write "void InitializeMappingTable(std::vector<MapEntry> &table)\n"
	hFile:write "{\n"
	hFile:inc()
	hFile:fmt("table.reserve(%i);\n", #options.extensions)
	for _, extName in ipairs(options.extensions) do
		if(#specData.extdefs[extName].funcs > 0) then
			hFile:fmt('table.push_back(MapEntry("%s", &exts::%s, %s));\n',
				spec.ExtNamePrefix() .. extName,
				GenExtensionVarName(extName, spec, options),
				GenExtLoaderFuncName(extName, spec, options))
		else
			hFile:fmt('table.push_back(MapEntry("%s", &exts::%s));\n',
				spec.ExtNamePrefix() .. extName,
				GenExtensionVarName(extName, spec, options))
		end
	end
	hFile:dec()
	hFile:write "}\n"
	hFile:write "\n"
	
	--Write the function to clear the extension variables.
	hFile:fmt("void ClearExtensionVars()\n")
	hFile:write("{\n")
	hFile:inc()
	for _, extName in ipairs(options.extensions) do
		hFile:fmt('exts::%s = exts::LoadTest();\n',
			GenExtensionVarName(extName, spec, options))
	end
	hFile:dec()
	hFile:write("}\n")
	hFile:write "\n"
	
	--Write a function that loads an extension by name. It is called when
	--processing, so it should also set the extension variable based on the load.
	hFile:writeblock([[
void LoadExtByName(std::vector<MapEntry> &table, const char *extensionName)
{
	std::vector<MapEntry>::iterator entry = std::find_if(table.begin(), table.end(), MapCompare(extensionName));
	
	if(entry != table.end())
	{
		if(entry->loaderFunc)
			(*entry->extVariable) = exts::LoadTest(true, entry->loaderFunc());
		else
			(*entry->extVariable) = exts::LoadTest(true, 0);
	}
}
]])
	EndNamespace(hFile)
	hFile:write "\n"
end

	local function GenQualifier(spec, options)
		local ret = ""
		if(#options.prefix > 0) then
			ret = options.prefix .. "::"
		end
		ret = ret .. spec.FuncNamePrefix() .. "::"
		return ret
	end

	local function GenQualifiedEnumName(enum, spec, options)
		return GenQualifier(spec, options) .. GenEnumName(enum, spec, options)
	end
	
	local function GenQualifiedFuncPtrName(func, spec, options)
		return GenQualifier(spec, options) .. GenFuncPtrName(func, spec, options)
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
static void ProcExtsFromExtList(std::vector<MapEntry> &table)
{
	GLint iLoop;
	GLint iNumExtensions = 0;
	]] .. GenQualifiedFuncPtrName(indexed[1], spec, options)
	.. [[(]] .. GenQualifiedEnumName(indexed[2], spec, options)
	.. [[, &iNumExtensions);

	for(iLoop = 0; iLoop < iNumExtensions; iLoop++)
	{
		const char *strExtensionName = (const char *)]] ..
		GenQualifiedFuncPtrName(indexed[3], spec, options) ..
		[[(]] .. GenQualifiedEnumName(indexed[4], spec, options) .. [[, iLoop);
		LoadExtByName(table, strExtensionName);
	}
}
]])
		else
			hFile:writeblock(common.GetProcessExtsFromStringFunc(
				"LoadExtByName(table, %s)", ", std::vector<MapEntry> &table"))
		end
		
		hFile:write "\n"

		return indexed
	end

	
	local function WriteInMainFuncLoader(hFile, func, spec, options)
		hFile:fmt('%s = reinterpret_cast<%s>(%s("%s%s"));\n',
			GenFuncPtrName(func, spec, options),
			GenFuncPtrTypedefName(func, spec, options),
			common.GetProcAddressName(spec),
			spec.FuncNamePrefix(), func.name)
		hFile:fmt('if(!%s) return exts::LoadTest();\n',
			GenFuncPtrName(func, spec, options))
	end

function my_style.source.WriteMainLoaderFunc(hFile, specData, spec, options)
	StartNamespace(hFile)
	local indexed = WriteAncillaryFuncs(hFile, specData, spec, options)
	EndNamespace(hFile)
	
	hFile:write "\n"
	
	hFile:fmt("exts::LoadTest LoadFunctions(%s)\n", spec.GetLoaderParams())
	hFile:write("{\n")
	hFile:inc()
	hFile:writeblock[[
ClearExtensionVars();
std::vector<MapEntry> table;
InitializeMappingTable(table);
]]
	hFile:write("\n")
	
	if(indexed) then
		WriteInMainFuncLoader(hFile, indexed[1], spec, options)
		WriteInMainFuncLoader(hFile, indexed[3], spec, options)
		hFile:write("\n")
		hFile:write("ProcExtsFromExtList(table);\n")
	else
		local extListName, needLoad = spec.GetExtStringFuncName()
		if(needLoad) then
			for _, func in ipairs(specData.funcData.functions) do
				if(extListName == func.name) then
					extListName = func
					break
				end
			end
			
			WriteInMainFuncLoader(hFile, extListName, spec, options)
			
			extListName = GenQualifiedFuncPtrName(extListName, spec, options);
		end

		local function EnumResolve(enumName)
			return GenQualifiedEnumName(specData.enumtable[enumName], spec, options)
		end
		
		hFile:write "\n"
		hFile:fmt("ProcExtsFromExtString((const char *)%s(%s), table);\n",
			extListName,
			spec.GetExtStringParamList(EnumResolve))
	end
	
	if(options.version) then
		hFile:write "\n"
		hFile:fmt("int numFailed = %s();\n",
			GenCoreLoaderFuncName(options.version, spec, options))
		
		hFile:write("return exts::LoadTest(true, numFailed);\n")
	else
		hFile:fmt("return exts::LoadTest(true, 0);\n")
	end


	hFile:dec()
	hFile:write("}\n")
end

function my_style.source.WriteVersioningFuncs(hFile, specData, spec, options)
	hFile:fmt("static int g_major_version = 0;\n")
	hFile:fmt("static int g_minor_version = 0;\n")
	hFile:write "\n"
	
	if(tonumber(options.version) >= 3.0) then
		hFile:writeblock([[
static void GetGLVersion()
{
	GetIntegerv(MAJOR_VERSION, &g_major_version);
	GetIntegerv(MINOR_VERSION, &g_minor_version);
}
]])
	else
		hFile:writeblock(common.GetParseVersionFromString())
		hFile:write "\n"
		
		hFile:writeblock([[
static void GetGLVersion()
{
	ParseVersionFromString(&g_major_version, &g_minor_version, GetString(VERSION));
}
]])
	end
	
	hFile:write "\n"
	hFile:writeblock([[
int GetMinorVersion()
{
	if(g_major_version == 0)
		GetGLVersion();
	return g_major_version;
}
]])
	hFile:write "\n"

	hFile:writeblock([[
int GetMajorVersion()
{
	if(g_major_version == 0) //Yes, check the major version to get the minor one.
		GetGLVersion();
	return g_minor_version;
}
]])
	hFile:write "\n"
	
	hFile:writeblock([[
bool IsVersionGEQ(int majorVersion, int minorVersion)
{
	if(g_major_version == 0)
		GetGLVersion();
		
	if(majorVersion > g_major_version) return true;
	if(majorVersion < g_major_version) return false;
	if(minorVersion >= g_minor_version) return true;
	return false;
}
]])

end


--------------------------------------------------
-- Style retrieval machinery

local function Create()
	return common.DeepCopyTable(my_style)
end

return { Create = Create }
