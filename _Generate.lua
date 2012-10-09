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

local function BuildHeader(options, spec, style, specData, basename)
	local header = style.header
	local hFile = header.CreateFile(basename, options)
	
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
	
	--Ending includeguard.
	hFile:fmt("#endif //%s\n", inclGuard)
	hFile:close()
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
