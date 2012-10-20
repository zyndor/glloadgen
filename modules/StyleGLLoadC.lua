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

-----------------------------------------------------------
-- Extension header.
local ext_hdr = {}

function ext_hdr.GetFilename(basename, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory .. glload.GetExtsHeaderBasename(spec, options)
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


-----------------------------------------------------------
-- Include header
local incl_hdr = {}

function incl_hdr.VersionFilenameCore(basename, version, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory .. spec.FilePrefix() .. version .. ".h"
end

function incl_hdr.VersionFilenameComp(basename, version, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory .. spec.FilePrefix() .. version .. "_comp.h"
end

function incl_hdr.AllFilename(basename, spec, options)
	local basename, dir = util.ParsePath(basename)
	return dir .. glload.headerDirectory .. spec.FilePrefix() .. "all.h"
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

function my_style.FilterHasCompatibility(version, specData, spec, options)
	if(tonumber(version) >= 3.1) then
		return true
	else
		return false
	end
end

local function Create()
	return common.DeepCopyTable(my_style), struct
end

return { Create = Create }
