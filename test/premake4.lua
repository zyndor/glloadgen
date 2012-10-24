
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
	
	files {"glload/*.cpp"}
	files {"glload/*.c"}
	files {"glload/*.hpp"}
	files {"glload/*.h"}

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
