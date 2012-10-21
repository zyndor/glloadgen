
local struct = require "Structure"

--Common set of header stuff.
local common_ext_struct =
{ type="group",
	{ type="enum-iter",
		{ type="write", name="Enumerator(hFile, enum, enumTable, spec, options)", },
	},
	{ type="blank", cond="enum-iter"},
	{ type="func-iter",
		{ type="write", name="FuncTypedef(hFile, func, typemap, spec, options)", },
	},
	{ type="blank", cond="func-iter"},
	{ type="func-iter",
		{ type="write", name="FuncDecl(hFile, func, typemap, spec, options)", },
	},
	{ type="blank", cond="func-iter"},
}

--Extension file.
local ext_file_struct =
{ type="file", style="ext_hdr", name="GetFilename(basename, spec, options)",
	{ type="block", name="IncludeGuard",
		{ type="blank"},
		{ type="write", name="Typedefs(hFile, specData, spec, options)",},
		{ type="blank"},
		{ type="block", name="Extern(hFile, spec, options)",
			{ type="ext-iter",
				{ type="write", name="ExtVariable(hFile, extName, spec, options)" },
			},
			{ type="blank"},
			{ type="ext-iter",
				common_ext_struct,
			},
		},
	},
}


local my_struct =
{
-- Internal header files.
{ type="enum-seen",
{ type="func-seen",
	--Write the type header file.
	{ type="file", style="type_hdr", name="GetFilename(basename, spec, options)",
		{ type="block", name="IncludeGuard(hFile, spec, options)",
			{ type="write", name="Init(hFile, spec, options)"},
			{ type="write", name="StdTypedefs(hFile, spec, options)"},
			{ type="write", name="PassthruTypedefs(hFile, specData, spec, options)"},
		},
	},
	
	--Write the extension file
	ext_file_struct,
	
	--For each version, write files containing just the core declarations.
	{ type="version-iter",
		{ type="filter", name="VersionHasCore(version, specData, spec, options)",
			{ type="file", style="core_hdr", name="GetFilename(basename, version, spec, options)",
				{ type="block", name="IncludeGuard(hFile, version, spec, options)",
					{ type="blank"},
					{ type="block", name="Extern(hFile, spec, options)",
						common_ext_struct,
					},
				},
			},
		},
	},
	
	--For each version, write files containing core declarations that were removed.
	{ type="version-iter",
		{ type="filter", name="VersionHasRemoved(version, specData, spec, options)",
			{ type="file", style="core_hdr", name="GetFilenameRem(basename, version, spec, options)",
				{ type="block", name="IncludeGuardRem(hFile, version, spec, options)",
					{ type="blank"},
					{ type="block", name="Extern(hFile, spec, options)",
						common_ext_struct,
					},
				},
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