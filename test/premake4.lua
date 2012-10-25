
dofile "glsdk/links.lua"

solution "test"
	configurations {"Debug", "Release"}
	defines {"_CRT_SECURE_NO_WARNINGS", "_SCL_SECURE_NO_WARNINGS"}

local testDirs = {"ptr_cpp"}

local oldDir = os.getcwd()
for _, testDir in ipairs(testDirs) do
	os.chdir(path.getabsolute(testDir))
	
	project(testDir .. "_test")
		kind "ConsoleApp"
		language "c++"
		objdir("obj")
		files {"**.cpp"}
		files {"**.c"}
		files {"**.hpp"}
		files {"**.h"}
		
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
	
	os.chdir(testDir)
end
