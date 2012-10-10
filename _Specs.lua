--[[ This module contains all of the spec-specific constructs (except where specs and styles overlap. That is, where styles have to do spec-specific work).

This module has a function called GetSpec which is given the spec name and returns a table containing functions/data that can be evaluated to do different jobs. This "class" contains:

- FilePrefix: nullary function that returns the filename prefix for this spec type.

- PlatformSetup: Takes a file and writes out platform-specific setup stuff.

- GetHeaderInit: Nullary function that returns a string to be written to the beginning of a header, just after the include guards.

- DeclPrefix: nullary function that returns the name of a prefix string for declarations.
]]

require "_util"

local gl_spec = {}
local wgl_spec = {}
local glx_spec = {}

local specTbl =
{
	gl = gl_spec,
	wgl = wgl_spec,
	glX = glx_spec,
}

-------------------------------------------------
-- Spec-specific functions.


---FilePrefix
function gl_spec.FilePrefix() return "gl_" end
function wgl_spec.FilePrefix() return "wgl_" end
function glx_spec.FilePrefix() return "glx_" end

local function LoadRun(spec, name)
	return dofile(GetDataFilePath() .. spec.FilePrefix() .. name .. ".lua")
end

--Include-guard string.
function gl_spec.GetIncludeGuardString() return "OPENGL" end
function wgl_spec.GetIncludeGuardString() return "WINDOWSGL" end
function glx_spec.GetIncludeGuardString() return "GLXWIN" end

--Declaration prefix.
function gl_spec.DeclPrefix() return "ogl_" end
function wgl_spec.DeclPrefix() return "wgl_" end
function glx_spec.DeclPrefix() return "glx_" end

--Extension name prefix.
function gl_spec.ExtNamePrefix() return "GL_" end
function wgl_spec.ExtNamePrefix() return "WGL" end
function glx_spec.ExtNamePrefix() return "GLX" end

--Enumerator name prefix. This is for defining "proper" GL enumerators.
function gl_spec.EnumNamePrefix() return "GL_" end
function wgl_spec.EnumNamePrefix() return "WGL" end
function glx_spec.EnumNamePrefix() return "GLX" end

--Function name prefix. This is for defining "proper" GL function names.
function gl_spec.FuncNamePrefix() return "gl" end
function wgl_spec.FuncNamePrefix() return "wgl" end
function glx_spec.FuncNamePrefix() return "glX" end

--Parameters given to the loader. No (), just the internals.
function gl_spec.GetLoaderParams() return "" end
function wgl_spec.GetLoaderParams() return "HDC *hdc" end
function glx_spec.GetLoaderParams() return "Display *display, int screen" end

local fileProps =
{
	{"GetHeaderInit", "init"},
	{"GetVersions", "versions"},
	{"GetCoreExts", "coreexts"},
}

--Header initialization.
for key, spec in pairs(specTbl) do
	for _, props in ipairs(fileProps) do
		spec[props[1]] = function()
			return dofile(GetDataFilePath() .. spec:FilePrefix() ..
				"spec" .. props[2] .. ".lua")
		end
	end
end

--Get version numbers


--------------------------------------------------
-- Spec retrieval machinery
local function CopyTable(tbl)
	local ret = {}
	for key, value in pairs(tbl) do
		ret[key] = value
	end
	return ret
end

local function GetSpec(spec)
	local spec_tbl = specTbl[spec]
	assert(spec_tbl, "Unknown specification " .. spec)
	return CopyTable(spec_tbl)
end

return { GetSpec = GetSpec }
