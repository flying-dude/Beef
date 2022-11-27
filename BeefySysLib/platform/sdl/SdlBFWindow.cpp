#include "SdlBFApp.h"
#include "GLRenderDevice.h"
#include "SDL.h"

USING_NS_BF;

void SdlBFWindow::GetPlacement(int* normX, int* normY, int* normWidth, int* normHeight, int* showKind) {
	// TODO get correct rect values
	NOT_IMPL_WARN;

	// compute *showKind
	Uint32 flags = SDL_GetWindowFlags(mSDLWindow);
	if (flags & SDL_WINDOW_MAXIMIZED)
		*showKind = 2;
	else if (flags & SDL_WINDOW_MINIMIZED)
		*showKind = 1;
	else
		*showKind = 0;
}

void SdlBFWindow::ModifyMenuItem(BFMenu* item, const char* text, const char* hotKey, BFSysBitmap* bitmap, bool enabled, int checkState, bool radioCheck)
{
	NOT_IMPL_WARN;
}

void SdlBFWindow::SetTitle(const char* title) {
	SDL_SetWindowTitle(mSDLWindow, title);
}

void SdlBFWindow::SetMinimumSize(int minWidth, int minHeight, bool clientSized) {
	SDL_SetWindowMinimumSize(mSDLWindow, minWidth, minHeight);
}

void SdlBFWindow::SetMouseVisible(bool isMouseVisible) {
	SDL_ShowCursor(isMouseVisible ? SDL_ENABLE : SDL_DISABLE);
}
