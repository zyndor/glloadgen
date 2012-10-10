--Initialization text for the 'wgl' spec header.

return [[
#ifdef __wglext_h_
#error Attempt to include auto-generated WGL header after wglext.h
#endif

#define __wglext_h_

#ifndef WIN32_LEAN_AND_MEAN
	#define WIN32_LEAN_AND_MEAN 1
#endif
#ifndef NOMINMAX
	#define NOMINMAX
#endif
#include <windows.h>

#ifdef GLE_FUNCPTR
#undef GLE_FUNCPTR
#endif /*GLE_FUNCPTR*/
#define GLE_FUNCPTR WINAPI

]]
