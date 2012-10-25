
dofile "glsdk/links.lua"

solution "test"
	configurations {"Debug", "Release"}
	defines {"_CRT_SECURE_NO_WARNINGS", "_SCL_SECURE_NO_WARNINGS"}

local tests =
{
	{name = "ptr_cpp"},
	{name = "glload_c", include = "include"},
}

local oldDir = os.getcwd()
for _, test in ipairs(tests) do
	os.chdir(path.getabsolute(test.name))
	
	project(test.name .. "_test")
		kind "ConsoleApp"
		language "c++"
		objdir("obj")
		files {"**.cpp"}
		files {"**.c"}
		files {"**.hpp"}
		files {"**.h"}
		
		if(test.include) then
			includedirs(test.include)
		end
		
		UseLibs {"freeglut"}
		
		configuration "windows"
			links {"glu32", "opengl32", "gdi32", "winmm", "user32"}
			
		configuration "linux"
			links {"GL", "GLU", "Xrandr", "X11"}
			
		configuration "Debug"
			targetsuffix "D"
			defines "_DEBUG"
			flags "Symbols"

		configuration "Release"
			defines "NDEBUG"
			flags {"OptimizeSpeed", "NoFramePointer", "ExtraWarnings", "NoEditAndContinue"};
	
	os.chdir(oldDir)
end
