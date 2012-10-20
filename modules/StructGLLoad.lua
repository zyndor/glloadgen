
local struct = require "Structure"

local my_struct =
{
-- Internal header files.
{ type="enum-seen",
{ type="func-seen",
	--Write the type header file.
	{ type="file", style="type_hdr", name="GetFilename(basename, spec, options)",
	},
	
	--Write the extension file
	{ type="file", style="ext_hdr", name="GetFilename(basename, spec, options)",
	},
	
	--For each version, write files containing just the core declarations.
	{ type="version-iter",
		{ type="file", style="core_hdr", name="GetFilename(basename, version, spec, options)",
		},
	},
	
	--For each version, write files containing core declarations that were removed.
	{ type="version-iter",
		{ type="filter", name="VersionHasRemoved(version, specData, spec, options)",
			{ type="file", style="core_hdr", name="GetFilenameRem(basename, version, spec, options)",
			},
		},
	},
},
},

	--Main header files.
	{ type="version-iter",
		{ type="file", style="incl_hdr", name="VersionFilenameCore(basename, version, spec, options)",
			{ type="block", name="IncludeGuardCore(hFile, version, spec, options)",
				{ type="blank" },
				{ type="write", name="IncludeIntType(hFile, spec, options)"},
				{ type="write", name="IncludeIntExts(hFile, spec, options)"},
				{ type="blank" },
				{ type="sub-version-iter",
					{ type="write", name="IncludeIntVersionCore(hFile, sub_version, spec, options)"},
					{ type="blank", last=true, },
				},
			},
		},
	},

	--Compatibility headers.
	{ type="version-iter",
		{ type="filter", name="HasCompatibility(version, specData, spec, options)",
			{ type="file", style="incl_hdr", name="VersionFilenameComp(basename, version, spec, options)",
				{ type="block", name="IncludeGuardComp(hFile, version, spec, options)",
					{ type="blank" },
					{ type="write", name="IncludeIntType(hFile, spec, options)"},
					{ type="write", name="IncludeIntExts(hFile, spec, options)"},
					{ type="blank" },
					{ type="sub-version-iter",
						{ type="write", name="IncludeIntVersionCore(hFile, sub_version, spec, options)"},
						{ type="write", name="IncludeIntVersionComp(hFile, sub_version, specData, spec, options)"},
						{ type="blank", last=true, },
					},
				},
			},
		},
	},

	--Header that includes everything.
	{ type="file", style="incl_hdr", name="AllFilename(basename, spec, options)",
		{ type="block", name="IncludeGuardAll(hFile, spec, options)",
			{ type="blank" },
			{ type="write", name="IncludeIntType(hFile, spec, options)"},
			{ type="write", name="IncludeIntExts(hFile, spec, options)"},
			{ type="blank" },
			{ type="version-iter",
				{ type="write", name="IncludeIntVersionCore(hFile, version, spec, options)"},
				{ type="write", name="IncludeIntVersionComp(hFile, version, specData, spec, options)"},
				{ type="blank", last=true, },
			},
		},
	},

	--Header to load things.
	{ type="file", style="load_hdr", name="GetFilename(basename, spec, options)",
	},
	
	--Source file.
	{ type="file", style="source", name="GetFilename(basename, spec, options)",
	},
}


my_struct = struct.BuildStructure(my_struct)

return my_struct