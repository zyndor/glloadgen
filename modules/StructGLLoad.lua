
local struct = require "Structure"

--Common set of header stuff.
local common_ext_struct =
{ type="group",
	{ type="filter", name="EnumsPerExtInGroup", optional=true, cond="enum-iter",
		{ type="enum-iter",
			{ type="write", name="Enumerator(hFile, enum, enumTable, spec, options, enumSeen)", },
		},
		{ type="blank", cond="enum-iter"},
	},
	{ type="block", name="FuncTypedefs(hFile, spec, options)", optional=true, cond="func-iter",
		{ type="func-iter",
			{ type="write", name="FuncTypedef(hFile, func, typemap, spec, options)", },
		},
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
			{ type="block", name="ExtVariables(hFile, spec, options)", optional=true,
				{ type="ext-iter",
					{ type="write", name="ExtVariable(hFile, extName, spec, options)" },
				},
			},
			{ type="blank"},
			{ type="filter", name="EnumsAllAtOnce", optional=true,
				{ type="block", name="Enumerators(hFile, spec, options)",
					{ type="ext-iter",
						{ type="enum-iter",
							{ type="write", name="Enumerator(hFile, enum, enumTable, spec, options, enumSeen)", },
						},
					},
				},
				{ type="blank"},
			},

			{ type="ext-iter",
				common_ext_struct,
			},
		},
	},
}

local decl_header_struct =
{ type="group",
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
						{ type="filter", name="VersionHasCoreEnums(version, specData, spec, options)",
							{ type="block", name="Enumerators(hFile, spec, options)", optional=true,
								{ type="enum-iter",
									{ type="filter", name="CoreEnum(enum)",
										{ type="write", name="Enumerator(hFile, enum, enumTable, spec, options, enumSeen)", },
									},
								},
							},
							{ type="blank", cond="enum-iter"},
						},
						{ type="block", name="FuncTypedefs(hFile, spec, options)", optional=true, cond="func-iter",
							{ type="func-iter",
								{ type="filter", name="CoreFunc(func)",
									{ type="write", name="FuncTypedef(hFile, func, typemap, spec, options)", },
								},
							},
						},
						{ type="blank", cond="func-iter"},
						{ type="func-iter",
							{ type="filter", name="CoreFunc(func)",
								{ type="write", name="FuncDecl(hFile, func, typemap, spec, options)", },
							},
						},
						{ type="blank", cond="func-iter"},
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
						{ type="filter", name="VersionHasCompEnums(version, specData, spec, options)",
							{ type="block", name="Enumerators(hFile, spec, options)", optional=true,
								{ type="enum-iter",
									{ type="filter", name="CompEnum(enum)",
										{ type="write", name="Enumerator(hFile, enum, enumTable, spec, options, enumSeen)", },
									},
								},
							},
						},
						{ type="blank", cond="enum-iter"},
						{ type="block", name="FuncTypedefs(hFile, spec, options)", optional=true, cond="func-iter",
							{ type="func-iter",
								{ type="filter", name="CompFunc(func)",
									{ type="write", name="FuncTypedef(hFile, func, typemap, spec, options)", },
								},
							},
						},
						{ type="blank", cond="func-iter"},
						{ type="func-iter",
							{ type="filter", name="CompFunc(func)",
								{ type="write", name="FuncDecl(hFile, func, typemap, spec, options)", },
							},
						},
						{ type="blank", cond="func-iter"},
					},
				},
			},
		},
	},
},
},

}


local include_header_struct =
{ type="group",
	--Main header files.
	{ type="version-iter",
		{ type="file", style="incl_hdr", name="VersionFilenameCore(basename, version, spec, options)",
			{ type="block", name="IncludeGuardCore(hFile, version, spec, options)",
				{ type="blank" },
				{ type="write", name="IncludeIntType(hFile, spec, options)"},
				{ type="write", name="IncludeIntExts(hFile, spec, options)"},
				{ type="blank" },
				{ type="sub-version-iter",
					{ type="write", name="IncludeIntVersionCore(hFile, sub_version, specData, spec, options)"},
					{ type="blank", last=true, },
				},
			},
		},
	},

	--Compatibility headers.
	{ type="version-iter",
		{ type="filter", name="VersionHasCompProfile(version)",
			{ type="file", style="incl_hdr", name="VersionFilenameComp(basename, version, spec, options)",
				{ type="block", name="IncludeGuardComp(hFile, version, spec, options)",
					{ type="blank" },
					{ type="write", name="IncludeIntType(hFile, spec, options)"},
					{ type="write", name="IncludeIntExts(hFile, spec, options)"},
					{ type="blank" },
					{ type="sub-version-iter",
						{ type="write", name="IncludeIntVersionCore(hFile, sub_version, specData, spec, options)"},
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
				{ type="write", name="IncludeIntVersionCore(hFile, version, specData, spec, options)"},
				{ type="write", name="IncludeIntVersionComp(hFile, version, specData, spec, options)"},
				{ type="blank", last=true, },
			},
		},
	},
}


local function CoreLoaderStruct(funcFilter)
	return
	{ type="group",
		{ type="core-ext-iter",
			{ type="func-iter",
				{ type="filter", name= funcFilter .. "(func)",
					{ type="write", name="LoadFunctionCore(hFile, func, typemap, spec, options)", },
				},
			},
		},
		{ type="func-iter",
			{ type="filter", name=funcFilter .. "(func)",
				{ type="write", name="LoadFunctionCore(hFile, func, typemap, spec, options)", },
			},
		},
	}
end


local source_c_struct = 
{ type="group",
	{ type="write", name="Includes(hFile, spec, options)" },
	{ type="blank"},
	{ type="write", name="PointerLoading(hFile, specData, spec, options)" },
	{ type="blank"},
	{ type="ext-iter",
		{ type="write", name="ExtVariable(hFile, extName, spec, options)" },
	},
	{ type="blank"},
	{ type="func-seen",
		--Write the extension functions and ext loaders.
		{ type="ext-iter",
			{ type="func-iter",
				{ type="write", name="FuncDef(hFile, func, typemap, spec, options)", },
			},
			{ type="blank", cond="func-iter"},
			{ type="block", name="LoadExtensionFuncs(hFile, extName, spec, options)", cond="func-iter",
				{ type="func-iter",
					{ type="write", name="LoadFunction(hFile, func, typemap, spec, options)", },
				},
			},
			{ type="blank", cond="func-iter"},
		},
		{ type="blank"},
		--Write the core functions (not already written) and the individual core loaders.
		{ type="version-iter",
			{ type="func-iter",
				{ type="write", name="FuncDefCond(hFile, func, typemap, spec, options, funcSeen)", },
			},
		},
		{ type="blank", cond="version-iter"},
		{ type="version-iter",
			{ type="filter", name="VersionHasCoreFuncs(version, specData, spec, options)",
				{ type="block", name="LoadCoreFuncs(hFile, version, spec, options)",
					CoreLoaderStruct("CoreFunc"),

				},
				{ type="blank"},
			},
			{ type="filter", name="VersionHasCompFuncs(version, specData, spec, options)",
				{ type="block", name="LoadCoreFuncsComp(hFile, version, spec, options)",
					CoreLoaderStruct("CompFunc"),
				},
			},
		},
		{ type="blank", cond="version-iter"},
	},
	
	--Write the aggregate core loaders (ie: load all for version X and below)
	{ type="version-iter",
		{ type="block", name="LoadAllCoreFunc(hFile, version, spec, options)",
			{ type="sub-version-iter",
				{ type="filter", name="VersionHasCoreFuncs(sub_version, specData, spec, options)",
					{ type="write", name="CallCoreLoad(hFile, sub_version, spec, options)" },
				},
				{ type="filter", name="VersionHasCompProfile(version)", neg=true,
					{ type="filter", name="VersionHasCompFuncs(sub_version, specData, spec, options)",
						{ type="write", name="CallCoreCompLoad(hFile, sub_version, spec, options)" },
					},
				},
			},
		},
		{ type="blank" },
		{ type="filter", name="VersionHasCompProfile(version)",
			{ type="block", name="LoadAllCoreCompFunc(hFile, version, spec, options)",
				{ type="sub-version-iter",
					{ type="filter", name="VersionHasCoreFuncs(sub_version, specData, spec, options)",
						{ type="write", name="CallCoreLoad(hFile, sub_version, spec, options)" },
					},
					{ type="filter", name="VersionHasCompFuncs(sub_version, specData, spec, options)",
						{ type="write", name="CallCoreCompLoad(hFile, sub_version, spec, options)" },
					},
				},
			},
			{ type="blank" },
		},
	},

	--Write the main loading function.
	{ type="write", name="MainLoadPrelim(hFile, specData, spec, options)", },
	{ type="blank", },
	{ type="write", name="MainLoader(hFile, specData, spec, options)", },
	{ type="blank", },
	{ type="write", name="MainExtraFuncs(hFile, specData, spec, options)", cond="version-iter" },
}

local source_cpp_struct = 
{ type="group",
}

local my_struct =
{
	{ type="group",
		decl_header_struct,
		
		include_header_struct,
		
		--Header to load things.
		{ type="file", style="load_hdr", name="GetFilename(basename, spec, options)",
			{ type="block", name="IncludeGuard(hFile, spec, options)",
				{ type="write", name="LoaderDecl(hFile, spec, options)" },
			}
		},
		
		--Source file.
		{ type="file", style="source", name="GetFilename(basename, spec, options)",
			source_c_struct,
		},
	},
	
	{ type="group", style="cpp",
		decl_header_struct,
		
		include_header_struct,
		
		--Header to load things.
		{ type="file", style="load_hdr", name="GetFilename(basename, spec, options)",
			{ type="block", name="IncludeGuard(hFile, spec, options)",
				{ type="write", name="LoaderDecl(hFile, spec, options)" },
			}
		},
		
		--Source file.
		{ type="file", style="source", name="GetFilename(basename, spec, options)",
			source_cpp_struct,
		},
	},
}


my_struct = struct.BuildStructure(my_struct)

return my_struct