--[[ Exports a table containing the following functions:

---- LoadSpec

Given a specification type, it loads the spec and returns the spec data, exactly as from LoadLuaSpec.

It is given the following parameters:

- options: The options list, as culled from GetOptions.


---- Generate

It creates a header/source file pair in accord with a standard algorithm and with the options it is given.

It is given the following parameters:

- options: The options list, as culled from GetOptions.
- specData: The data as loaded with LoadSpec
]]

local Specs = require "_Specs"
local Styles = require "_Styles"
require "_LoadLuaSpec"
require "_util"

local function WriteEnumsFromList(hFile, enumList, enumSeen, listName,
	options, spec, style, specData)
	local header = style.header
	
	for _, enum in ipairs(enumList) do
		if(not enumSeen[enum.name]) then
			header.WriteEnumDecl(hFile, enum,
				specData.enumtable, spec, options)
			enumSeen[enum.name] = listName
		else
			header.WriteEnumPrevDecl(hFile, enum,
				specData.enumtable, spec, options,
				enumSeen[enum.name])
		end
	end
end

local function WriteEnumsForExt(hFile, extName, enumSeen, options, spec,
	style, specData)
	local header = style.header
	
	if(#specData.extdefs[extName].enums > 0) then
		style.WriteSmallHeading(hFile, spec.ExtNamePrefix() .. extName)
		
		WriteEnumsFromList(hFile, specData.extdefs[extName].enums,
			enumSeen, extName, options, spec, style, specData)
		
		hFile:write("\n")
		return true
	end
	
	return false
end

local function GetCoreEnumerators(core, specData, spec, options, version)
	--Only remove from core profile.
	if(options.profile ~= "core") then
		return core.enums
	end

	local targetVersion = tonumber(options.version)
	local enumList = {};
	for i, enum in ipairs(core.enums) do
		local bShouldWrite = true;
		
		if(enum.removed and tonumber(enum.removed) <= targetVersion) then
			bShouldWrite = false
		end

		--Very oddball logic to handle ARB_tessellation_shader's
		--ability to bring back GL_QUADS.
		--Remove the enumeration if all of the following
		--	The enum is from a core extension
		--	That extension is not core for the version we're writing
		if(enum.extensions) then
			for _, ext in ipairs(enum.extensions) do
				if(specData.coreexts[ext] and
					tonumber(specData.coreexts[ext].version) <= targetVersion) then
					bShouldWrite = false
				end
			end
		end

		if(bShouldWrite) then
			enumList[#enumList + 1] = enum;
		end
	end
	return enumList
end

local function WriteEnumerators(hFile, options, spec, style, specData)
	local header = style.header

	local extSeen = {}
	local enumSeen = {}
	
	--For each extension, write its enumerators.
	for _, extName in ipairs(options.extensions) do
		if(not extSeen[extName]) then
			extSeen[extName] = true
			WriteEnumsForExt(hFile, extName, enumSeen,
				options, spec, style, specData)
		end
	end
	
	hFile:write("\n")
	
	--For each version we are told to export, write the enumerators.
	if(options.version) then
		style.WriteSmallHeading(hFile, "Core Enumerators")
	end
	local coreExts = spec.GetCoreExts()
	for _, version in ipairs(spec.GetVersions()) do
		if(tonumber(version) <= tonumber(options.version)) then
			--Write any core extensions for that version.
			if(coreExts[version]) then
				for _, extName in ipairs(coreExts[version]) do
					if(not extSeen[extName]) then
						extSeen[extName] = true
						WriteEnumsForExt(
							hFile, extName, enumSeen,
							options, spec, style, specData)
					end
				end
			end
			
			--Write the actual core enumerators.
			local enumList = GetCoreEnumerators(specData.coredefs[version],
				specData, spec, options, version)
				
			if(#enumList > 0) then
				style.WriteSmallHeading(hFile, "Version " .. version)
				
				WriteEnumsFromList(hFile, enumList, enumSeen,
					version, options, spec, style, specData)

				hFile:write("\n")
			end
		end
	end
end

local function WriteFuncDeclsFromList(hFile, funcList, funcSeen,
	listName, options, spec, style, specData)
	local header = style.header
	
	for _, func in ipairs(funcList) do
		if(not funcSeen[func.name]) then
			header.WriteFuncDecl(hFile, func, specData.typemap, spec, options)
			funcSeen[func.name] = listName
		end
	end
end

local function WriteFuncDeclsForExt(hFile, extName, funcSeen, options, spec,
	style, specData)
	local header = style.header
	if(#specData.extdefs[extName].funcs > 0) then
		style.WriteSmallHeading(hFile, spec.ExtNamePrefix() .. extName)
		
		header.WriteBeginExtFuncDeclBlock(hFile, extName, spec, options)
		WriteFuncDeclsFromList(hFile, specData.extdefs[extName].funcs,
			funcSeen, extName, options, spec, style, specData)
		header.WriteEndExtFuncDeclBlock(hFile, extName, spec, options)
		hFile:write("\n")
	end
end

local function GetCoreFunctions(core, specData, spec, options, version)
	--Only remove from core profile.
	if(options.profile ~= "core") then
		return core.func
	end

	local targetVersion = tonumber(options.version)
	local funcList = {};
	for i, func in ipairs(core.funcs) do
		local bShouldWrite = true;
		
		if(func.deprecated and tonumber(func.deprecated) <= targetVersion) then
			bShouldWrite = false
		end

		--Fortuantely, a function can't be both from a version and an extension
		if(func.category and not string.match(func.category, "^VERSION")) then
			bShouldWrite = false
		end

		if(bShouldWrite) then
			funcList[#funcList + 1] = func;
		end
	end
	return funcList
end

local function WriteFunctionDecls(hFile, options, spec, style, specData)
	local header = style.header
	style.WriteSmallHeading(hFile, "Extension Functions")

	local extSeen = {}
	local funcSeen = {}
	
	--For each extension, write their function declarations.
	for _, extName in ipairs(options.extensions) do
		if(not extSeen[extName]) then
			extSeen[extName] = true
			WriteFuncDeclsForExt(hFile, extName, funcSeen, options,
				spec, style, specData)
		end
	end
	
	hFile:write("\n")
	
	--For each version we are told to export, write the Functions.
	if(options.version) then
		style.WriteSmallHeading(hFile, "Core Functions")
	end
	
	local coreExts = spec.GetCoreExts()
	for _, version in ipairs(spec.GetVersions()) do
		if(tonumber(version) <= tonumber(options.version)) then
			--Write any core extensions for that version.
			if(coreExts[version]) then
				for _, extName in ipairs(coreExts[version]) do
					if(not extSeen[extName]) then
						extSeen[extName] = true
						WriteFuncDeclsForExt(hFile, extName, funcSeen,
							options, spec, style, specData)
					end
				end
			end
			
			--Write the actual core functions, if any.
			local funcList = GetCoreFunctions(specData.coredefs[version],
				specData, spec, options, version)
				
			if(#funcList > 0) then
				style.WriteSmallHeading(hFile, "Version " .. version)
				
				WriteFuncDeclsFromList(hFile, funcList, funcSeen,
					version, options, spec, style, specData)

				hFile:write("\n")
			end
		end
	end
end

local function BuildHeader(options, spec, style, specData, basename)
	local header = style.header
	local hFile, filename = header.CreateFile(basename, options)
	
	--Start include-guards.
	--IGs are built from style and spec data. The spec provides a string that
	--the style uses in constructing it.
	local inclGuard =
		header.MakeIncludeGuard(options.prefix, spec.GetIncludeGuardString())
	
	hFile:fmt("#ifndef %s\n", inclGuard)
	hFile:fmt("#define %s\n", inclGuard)
	hFile:write("\n")
	
	--Spec-specific initialization comes next. Generally macros and #includes.
	hFile:rawwrite(spec.GetHeaderInit())
	
	--Write the standard typedefs.
	header.WriteStdTypedefs(hFile, specData, options)
	
	--Write the typedefs from the spec.
	header.WriteSpecTypedefs(hFile, specData, options)
	
	--Write any declaration scoping start.
	header.WriteBeginDecl(hFile, specData, options)
	
	--Write the extension variable declarations.
	style.WriteLargeHeading(hFile, "Extension variable declarations")
	for _, ext in ipairs(options.extensions) do
		header.WriteExtVariableDecl(hFile, ext, specData, spec, options)
	end
	hFile:write("\n")
	
	--Write all enumerators.
	style.WriteLargeHeading(hFile, "Enumerators")
	header.WriteBeginEnumDeclBlock(hFile, specData, options)

	WriteEnumerators(hFile, options, spec, style, specData)
	
	header.WriteEndEnumDeclBlock(hFile, specData, options)
	
	--Write all function declarations
	style.WriteLargeHeading(hFile, "Functions")
	header.WriteBeginFuncDeclBlock(hFile, specData, options)

	WriteFunctionDecls(hFile, options, spec, style, specData)
	
	header.WriteEndFuncDeclBlock(hFile, specData, options)
	
	--Write the function loading stuff.
	style.WriteLargeHeading(hFile, "Loading Functions")
	header.WriteStatusCodeDecl(hFile, spec, options)
	hFile:write("\n")
	header.WriteFuncLoaderDecl(hFile, spec, options)
	if(options.version) then
		hFile:write("\n")
		header.WriteVersioningDecls(hFile, spec, options)
	end
	
	--Write any declaration scoping end.
	header.WriteEndDecl(hFile, specData, options)
	
	--Ending includeguard.
	hFile:fmt("#endif //%s\n", inclGuard)
	hFile:close()
	
	return filename
end

local function Generate(options, specData)
	--Extract the path and base-filename from the options.
	local simplename = options.outname:match("([^\\/]+)$")
	local dir = options.outname:match("^(.*[\\/])")
	
	assert(simplename,
		"There is no filename in the path '" .. options.outname .. "'")

	local spec = Specs.GetSpec(options.spec)
	local style = Styles.GetStyle(options.style)

	--Compute the filename, minus style-specific suffix.
	local basename = dir .. spec:FilePrefix() .. simplename
	
	BuildHeader(options, spec, style, specData, basename)
end

local function LoadSpec(options)
	local specfile =
	{
		gl = "glspec.lua",
		glX = "glxspec.lua",
		wgl = "wglspec.lua",
	}
	
	local specFileLoc = GetSpecFilePath();
	return LoadLuaSpec(specFileLoc .. specfile[options.spec])
end



return
{
	Generate = Generate,
	LoadSpec = LoadSpec,
}
