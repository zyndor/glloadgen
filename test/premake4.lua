
dofile "glsdk/links.lua"

solution "loadtest"
	configurations {"Debug", "Release"}
	defines {"_CRT_SECURE_NO_WARNINGS", "_SCL_SECURE_NO_WARNINGS"}

	
project("loadtest")
	kind "ConsoleApp"
	language "c++"
	objdir("obj")
	files {"*.cpp"}
	files {"*.c"}
	files {"*.hpp"}
	files {"*.h"}

	UseLibs {"freeglut"}
	
	configuration "windows"
		defines "WIN32"
		links {"glu32", "opengl32", "gdi32", "winmm", "user32"}
		
	configuration "linux"
		links {"GL", "GLU", "Xrandr"}
		
	configuration "Debug"
		targetsuffix "D"
		defines "_DEBUG"
		flags "Symbols"

	configuration "Release"
		defines "NDEBUG"
		flags {"OptimizeSpeed", "NoFramePointer", "ExtraWarnings", "NoEditAndContinue"};
