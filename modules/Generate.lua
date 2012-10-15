--[[ Exports a table containing the following functions:

---- Generate

It creates a header/source file pair in accord with a standard algorithm and with the options it is given. It is given the options generated from GetOptions.
]]

local Specs = require "Specs"
local Styles = require "Styles"
local LoadSpec = require "LoadLuaSpec"
local util = require "util"

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
	
	--For each version we are told to export, write the Functions.
	if(options.version) then
		hFile:write("\n")
		style.WriteSmallHeading(hFile, "Core Functions")
	else
		--No version to export
		return
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
	header.WriteBeginIncludeGuard(hFile, spec, options)
	hFile:write("\n")
	
	--Spec-specific initialization comes next. Generally macros and #includes.
	hFile:rawwrite(spec.GetHeaderInit())
	
	--Write the standard typedefs.
	header.WriteStdTypedefs(hFile, specData, spec, options)
	
	--Write the typedefs from the spec.
	header.WriteSpecTypedefs(hFile, specData, spec, options)
	
	--Write any declaration scoping start.
	header.WriteBeginDecl(hFile, spec, options)
	
	--Write the extension variable declarations.
	style.WriteLargeHeading(hFile, "Extension variable declarations")
	for _, ext in ipairs(options.extensions) do
		header.WriteExtVariableDecl(hFile, ext, specData, spec, options)
	end
	hFile:write("\n")
	
	--Write all enumerators.
	style.WriteLargeHeading(hFile, "Enumerators")
	header.WriteBeginEnumDeclBlock(hFile, spec, options)

	WriteEnumerators(hFile, options, spec, style, specData)
	
	header.WriteEndEnumDeclBlock(hFile, spec, options)
	
	--Write all function declarations
	style.WriteLargeHeading(hFile, "Functions")
	header.WriteBeginFuncDeclBlock(hFile, spec, options)

	WriteFunctionDecls(hFile, options, spec, style, specData)
	
	header.WriteEndFuncDeclBlock(hFile, spec, options)
	
	--Write the function loading stuff.
	style.WriteLargeHeading(hFile, "Loading Functions")
	header.WriteUtilityDecls(hFile, spec, options)
	hFile:write("\n")
	header.WriteMainLoaderFuncDecl(hFile, spec, options)
	if(options.version) then
		hFile:write("\n")
		header.WriteVersioningFuncDecls(hFile, spec, options)
	end
	
	--Write any declaration scoping end.
	header.WriteEndDecl(hFile, spec, options)
	
	--Ending includeguard.
	header.WriteEndIncludeGuard(hFile, spec, options)
	hFile:write("\n")
	hFile:close()
	
	return filename
end



local function WriteFuncDefsFromList(hFile, funcList, funcSeen,
	listName, options, spec, style, specData)
	local source = style.source
	
	local loaded = {}
	for _, func in ipairs(funcList) do
		if(not funcSeen[func.name]) then
			source.WriteFuncDef(hFile, func, specData.typemap, spec, options)
			funcSeen[func.name] = listName
			loaded[#loaded + 1] = func
		end
	end
	
	return loaded
end

local function WriteExtFuncLoaderFromList(hFile, funcList,
	options, spec, style, specData)
	local source = style.source
	
	for _, func in ipairs(funcList) do
		source.WriteExtFuncLoader(hFile, func, specData.typemap, spec, options)
	end
end

local function WriteCoreFuncLoaderFromList(hFile, funcList,
	options, spec, style, specData)
	local source = style.source
	
	for _, func in ipairs(funcList) do
		source.WriteCoreFuncLoader(hFile, func, specData.typemap, spec, options)
	end
end

local function WriteFuncDefsForExt(hFile, extName, funcSeen, options, spec,
	style, specData)
	local source = style.source

	if(#specData.extdefs[extName].funcs > 0) then
		style.WriteSmallHeading(hFile, spec.ExtNamePrefix() .. extName)
		
		source.WriteBeginExtFuncDefBlock(hFile, extName, spec, options)
		local loaded = WriteFuncDefsFromList(hFile,
			specData.extdefs[extName].funcs, funcSeen, extName,
			options, spec, style, specData)
		
		hFile:write("\n")
		source.WriteBeginExtLoaderBlock(hFile, extName, spec, options)
		WriteExtFuncLoaderFromList(hFile, loaded, options,
			spec, style, specData)
		source.WriteEndExtLoaderBlock(hFile, extName, spec, options)
		
		source.WriteEndExtFuncDefBlock(hFile, extName, spec, options)
		hFile:write("\n")
	end
end

local function WriteFuncDefsForCoreExt(hFile, extName, funcSeen, options, spec,
	style, specData)
	local source = style.source

	if(#specData.extdefs[extName].funcs > 0) then
		style.WriteSmallHeading(hFile, spec.ExtNamePrefix() .. extName)
		
		local loaded = WriteFuncDefsFromList(hFile,
			specData.extdefs[extName].funcs, funcSeen, extName,
			options, spec, style, specData)
		hFile:write("\n")
	end
end

local function WriteFunctionDefs(hFile, options, spec, style, specData)
	local source = style.source
	
	style.WriteSmallHeading(hFile, "Extension Functions")

	local extSeen = {}
	local funcSeen = {}
	
	--For each extension, write their function pointer definitions.
	for _, extName in ipairs(options.extensions) do
		if(not extSeen[extName]) then
			extSeen[extName] = true
			WriteFuncDefsForExt(hFile, extName, funcSeen, options,
				spec, style, specData)
		end
	end
	
	--For each version we are told to export, write the function pointer definitions.
	if(options.version) then
		hFile:write("\n")
		style.WriteSmallHeading(hFile, "Core Functions")
	else
		--No version to export, so don't bother.
		return
	end
	
	--Write the core function definitions, maintaining a list of everything
	--that was written.
	local coreExts = spec.GetCoreExts()
	local bWrittenBeginCore = false
	for _, version in ipairs(spec.GetVersions()) do
		if(tonumber(version) <= tonumber(options.version)) then
			--Write any core extensions for that version.
			if(coreExts[version]) then
				for _, extName in ipairs(coreExts[version]) do
					if(not extSeen[extName]) then
						if(not bWrittenBeginCore) then
							source.WriteBeginCoreFuncDefBlock(hFile, options.version, spec, options)
							bWrittenBeginCore = true
						end
						extSeen[extName] = true
						WriteFuncDefsForCoreExt(hFile, extName, funcSeen,
							options, spec, style, specData)
					end
				end
			end
			
			--Write the actual core functions, if any.
			local funcList = GetCoreFunctions(specData.coredefs[version],
				specData, spec, options, version)
				
			if(#funcList > 0) then
				if(not bWrittenBeginCore) then
					source.WriteBeginCoreFuncDefBlock(hFile, options.version, spec, options)
					bWrittenBeginCore = true
				end
				style.WriteSmallHeading(hFile, "Version " .. version)
				
				WriteFuncDefsFromList(hFile, funcList, funcSeen,
					version, options, spec, style, specData)

				hFile:write("\n")
			end
		end
	end
	
	if(bWrittenBeginCore) then
		--Now, write the function that loads the core version. Include
		--ALL core extensions, not just the ones we wrote.
		--This allows us to build an accurate count of what core stuff is missing.
		source.WriteBeginCoreLoaderBlock(hFile, options.version, spec, options)
		for _, version in ipairs(spec.GetVersions()) do
			if(tonumber(version) <= tonumber(options.version)) then
				if(coreExts[version]) then
					source.WriteBeginExtFuncDefBlock(hFile, extName, spec, options)

					for _, extName in ipairs(coreExts[version]) do
						WriteCoreFuncLoaderFromList(hFile,
							specData.extdefs[extName].funcs,
							options, spec, style, specData)
					end
					
					source.WriteEndExtFuncDefBlock(hFile, extName, spec, options)

				end
				
				--Write the actual core functions, if any.
				local funcList = GetCoreFunctions(specData.coredefs[version],
					specData, spec, options, version)
					
				if(#funcList > 0) then
					WriteCoreFuncLoaderFromList(hFile,
						funcList, options, spec, style, specData)
				end
			end
		end
		source.WriteEndCoreLoaderBlock(hFile, options.version, spec, options)
		
		source.WriteEndCoreFuncDefBlock(hFile, options.version, spec, options)
	end
	
	local function FindFuncName(funcName)
		for _, func in ipairs(specData.funcData.functions) do
			if(func.name == funcName) then
				return func
			end
		end
		
		return nil
	end
	
	--Write the function declaration needed to load the extension string.
	--But only if it's available in the spec data and hasn't already been written.
	local funcExtString = FindFuncName(spec.GetExtStringFuncName())
	if(funcExtString and not funcSeen[spec.GetExtStringFuncName()]) then
		hFile:write("\n")
		source.WriteGetExtStringFuncDef(hFile, funcExtString,
			specData.typemap, spec, options)
	end
end

local function BuildSource(options, spec, style, specData, basename,
	hdrFilename)
	local source = style.source
	local hFile, filename = source.CreateFile(basename, options)
	
	--Write the header inclusions
	source.WriteIncludes(hFile, spec, options)
	hFile:fmt('#include "%s"\n', hdrFilename:match("([^\\/]+)$"))
	hFile:write("\n")

	--Write the function that loads a function pointer, given a name.
	hFile:writeblock(spec.GetLoaderFunc())
	hFile:write("\n")
	
	--Write any definitions scoping start.
	source.WriteBeginDef(hFile, spec, options)
	
	--Write the extension variable definitions.
	style.WriteLargeHeading(hFile, "Extension variable definitions")
	for _, ext in ipairs(options.extensions) do
		source.WriteExtVariableDef(hFile, ext, specData, spec, options)
	end
	hFile:write("\n")
	
	--Write all of the loader definitions.
	style.WriteLargeHeading(hFile, "Function Definitions and Loaders")
	WriteFunctionDefs(hFile, options, spec, style, specData)
	hFile:write("\n")
	
	--Write utility definitions needed by the loader.
	source.WriteUtilityDefs(hFile, specData, spec, options)
	hFile:write "\n"
	
	--Write the main loading function which loads everything.
	source.WriteMainLoaderFunc(hFile, specData, spec, options)
	hFile:write "\n"
	
	--Write any additional functions that load other things.
   	if(options.version) then
        source.WriteVersioningFuncs(hFile, specData, spec, options)
        hFile:write "\n"
	end

	--Write any definitions scoping end.
	source.WriteEndDef(hFile, spec, options)

	return filename
end

local function Generate(options)
	--Load the spec data.
	local spec = Specs.GetSpec(options.spec)
	local specData = spec.LoadSpec()
	
	--Verify that every extension in `options.extensions` is a real extension.
	local badExts = {}
	for _, extName in ipairs(options.extensions) do
		if(not specData.extdefs[extName]) then
			badExts[#badExts + 1] = extName
		end
	end
	
	if(#badExts > 0) then
		io.stdout:write("The following extensions are not in the spec ", options.spec, ":\n")
		for _, extName in ipairs(badExts) do
			io.stdout:write("\t", extName, "\n")
		end
		return
	end

	--Extract the path and base-filename from the options.
	local simplename = options.outname:match("([^\\/]+)$")
	local dir = options.outname:match("^(.*[\\/])")
	dir = dir or "./"
	
	assert(simplename,
		"There is no filename in the path '" .. options.outname .. "'")

	local style = Styles.GetStyle(options.style)

	--Compute the filename, minus style-specific suffix.
	local basename = dir .. spec:FilePrefix() .. simplename
	
	local hdrFilename = BuildHeader(options, spec, style, specData, basename)
	local srcFilename = BuildSource(options, spec, style, specData, basename,
		hdrFilename)
end

return
{
	Generate = Generate,
}
