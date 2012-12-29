
local prelims =
{
	[[lua $<dir>MakeAllExts.lua -spec=gl $<dir>allgl.txt]],
	[[lua $<dir>MakeAllExts.lua -spec=wgl $<dir>allwgl.txt]],
	[[lua $<dir>MakeAllExts.lua -spec=glX $<dir>allglx.txt]],
}

local tests =
{
	[[lua $<dir>LoadGen.lua -spec=gl -version=3.3 -profile=core -style=pointer_cpp -stdext=gl_ubiquitous.txt $<dir>test/ptr_cpp/test]],
	[[lua $<dir>LoadGen.lua -spec=gl -version=3.3 -profile=core -style=pointer_c -stdext=gl_ubiquitous.txt $<dir>test/ptr_c/test]],
	[[lua $<dir>LoadGen.lua -spec=gl -version=3.3 -profile=compatibility -style=pointer_cpp -stdext=gl_ubiquitous.txt $<dir>test/ptr_cpp_comp/test]],
	[[lua $<dir>LoadGen.lua -spec=gl -version=3.3 -profile=compatibility -style=pointer_c -stdext=gl_ubiquitous.txt $<dir>test/ptr_c_comp/test]],
	[[lua $<dir>LoadGen.lua -spec=gl -version=3.3 -profile=compatibility -style=noload_cpp  -stdext=gl_ubiquitous.txt $<dir>test/noload_cpp/test]],
	[[lua $<dir>LoadGen.lua -spec=gl -version=3.3 -profile=compatibility -style=noload_cpp $<dir>test/noload_cpp_noext/test]],
}

local platTests =
{
	wgl =
	{
		[[lua $<dir>LoadGen.lua -spec=wgl -style=pointer_cpp -stdext=wgl_common.txt $<dir>test/ptr_cpp/test]],
		[[lua $<dir>LoadGen.lua -spec=wgl -style=pointer_c -stdext=wgl_common.txt $<dir>test/ptr_c/test]],
		[[lua $<dir>LoadGen.lua -spec=wgl -style=pointer_cpp -stdext=wgl_common.txt $<dir>test/ptr_cpp_comp/test]],
		[[lua $<dir>LoadGen.lua -spec=wgl -style=pointer_c -stdext=wgl_common.txt $<dir>test/ptr_c_comp/test]],
		[[lua $<dir>LoadGen.lua -spec=wgl -style=noload_cpp  -stdext=wgl_common.txt $<dir>test/noload_cpp/test]],
		[[lua $<dir>LoadGen.lua -spec=wgl -style=noload_cpp  -stdext=wgl_common.txt $<dir>test/noload_cpp_noext/test]],
	},
	
	glX =
	{
		[[lua $<dir>LoadGen.lua -spec=glX -style=pointer_cpp -stdext=glx_common.txt $<dir>test/ptr_cpp/test]],
		[[lua $<dir>LoadGen.lua -spec=glX -style=pointer_c -stdext=glx_common.txt $<dir>test/ptr_c/test]],
		[[lua $<dir>LoadGen.lua -spec=glX -style=pointer_cpp -stdext=glx_common.txt $<dir>test/ptr_cpp_comp/test]],
		[[lua $<dir>LoadGen.lua -spec=glX -style=pointer_c -stdext=glx_common.txt $<dir>test/ptr_c_comp/test]],
		[[lua $<dir>LoadGen.lua -spec=glX -style=noload_cpp -stdext=glx_common.txt $<dir>test/noload_cpp/test]],
		[[lua $<dir>LoadGen.lua -spec=glX -style=noload_cpp -stdext=glx_common.txt $<dir>test/noload_cpp_noext/test]],
	},
}

local glXTests = {}

local baseDir = arg[0]:match("^(.*[\\/])")
baseDir = baseDir or "./"

local function ExecTests(testList)
	for _, test in ipairs(testList) do
		test = test:gsub("%$<dir>", baseDir)
		print(test)
		os.execute(test)
	end
end

if(arg[1]) then
	assert(platTests[arg[1]], "Invalid platform " .. arg[1])
end

ExecTests(prelims)
ExecTests(tests)
if(arg[1]) then
	ExecTests(platTests[arg[1]])
end

