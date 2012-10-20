
local util = require "util"

local data = {}

data.internalPrefix = "_int_"
data.headerDirectory = ""
data.sourceDirectory = ""

function data.GetTypeHeaderBasename(spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. "type.h"
end

function data.GetExtsHeaderBasename(spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. "exts.h"
end

function data.GetCoreHeaderBasename(version, spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. version .. ".h"
end

function data.GetRemHeaderBasename(version, spec, options)
	return data.internalPrefix .. spec.FilePrefix() .. version .. "_rem.h"
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

return data
