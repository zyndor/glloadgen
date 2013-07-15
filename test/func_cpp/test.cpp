

#include <iostream>
#include "gl_test.hpp"
#include <GL/freeglut.h>

int main(int argc, char* argv[])
{
	// FreeGLUT stuff init stuff
	glutInit(&argc, argv);
	glutInitContextVersion(3, 1);
	glutInitContextProfile(GLUT_CORE_PROFILE);

	// this works but shouldn't
	bool load = gl::sys::LoadFunctions();
	std::cout << "Loaded: " << (load ? "True" : "False") << std::endl;
	gl::GetString(gl::VERSION); // no crash at glGetString

	// works as intended
	int winID = glutCreateWindow("Engine2 Test");
	load = gl::sys::LoadFunctions();  
	std::cout << gl::GetString(gl::VERSION) << std::endl;
	glutDestroyWindow(winID);

	return 0;
}
