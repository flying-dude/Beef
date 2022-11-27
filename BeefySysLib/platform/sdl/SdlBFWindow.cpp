#include "SdlBFApp.h"
#include "GLRenderDevice.h"
#include "SDL.h"

USING_NS_BF;

SdlBFWindow::SdlBFWindow(BFWindow* parent, const StringImpl& title, int x, int y, int width, int height, int windowFlags)
{
	int sdlWindowFlags = 0;
	if (windowFlags & BFWINDOW_RESIZABLE)
		sdlWindowFlags |= SDL_WINDOW_RESIZABLE;
	sdlWindowFlags |= SDL_WINDOW_OPENGL;

#ifdef BF_PLATFORM_FULLSCREEN
	sdlWindowFlags |= SDL_WINDOW_FULLSCREEN;
#endif

	mSDLWindow = SDL_CreateWindow(title.c_str(), x, y, width, height, sdlWindowFlags);

	if (!SDL_GL_CreateContext(mSDLWindow))
	{
		BF_FATAL(StrFormat("Unable to create OpenGL context: %s", SDL_GetError()).c_str());
		SDL_Quit();
		exit(2);
	}

	glEnable(GL_BLEND);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

#ifndef BF_PLATFORM_OPENGL_ES2
	glEnableClientState(GL_INDEX_ARRAY);
#endif

	//glEnableClientState(GL_VERTEX_ARRAY);
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	//glEnableClientState(GL_COLOR_ARRAY);

	mIsMouseInside = false;
	mRenderWindow = new GLRenderWindow((GLRenderDevice*)gBFApp->mRenderDevice, mSDLWindow);
	mRenderWindow->mWindow = this;
	gBFApp->mRenderDevice->AddRenderWindow(mRenderWindow);

	if (parent != NULL)
		parent->mChildren.push_back(this);
}

SdlBFWindow::~SdlBFWindow()
{
	if (mSDLWindow != NULL)
		TryClose();
}

bool SdlBFWindow::TryClose()
{
	SdlBFApp* app = (SdlBFApp*)gBFApp;
	SdlWindowMap::iterator itr = app->mSdlWindowMap.Find(SDL_GetWindowID(mSDLWindow));
	app->mSdlWindowMap.Remove(itr);

	SDL_DestroyWindow(mSDLWindow);
	mSDLWindow = NULL;
	return true;
}

void SdlBFWindow::GetPosition(int* x, int* y, int* width, int* height, int* clientX, int* clientY, int* clientWidth, int* clientHeight)
{
	SDL_GetWindowPosition(mSDLWindow, x, y);
	SDL_GetWindowSize(mSDLWindow, width, height);
	*clientWidth = *width;
	*clientHeight = *height;
}

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

void SdlBFWindow::SetClientPosition(int x, int y)
{
	SDL_SetWindowPosition(mSDLWindow, x, y);

	if (mMovedFunc != NULL)
		mMovedFunc(this);
}

void SdlBFWindow::SetAlpha(float alpha, uint32 destAlphaSrcMask, bool isMouseVisible)
{
	// Not supported
}

BFMenu* SdlBFWindow::AddMenuItem(BFMenu* parent, int insertIdx, const char* text, const char* hotKey, BFSysBitmap* bitmap, bool enabled, int checkState, bool radioCheck)
{
	NOT_IMPL_WARN;
	return nullptr;
}

void SdlBFWindow::ModifyMenuItem(BFMenu* item, const char* text, const char* hotKey, BFSysBitmap* bitmap, bool enabled, int checkState, bool radioCheck)
{
	NOT_IMPL_WARN;
}

void SdlBFWindow::RemoveMenuItem(BFMenu* item)
{
	NOT_IMPL_WARN;
}

void SdlBFWindow::SetTitle(const char* title) {
	SDL_SetWindowTitle(mSDLWindow, title);
}

void SdlBFWindow::SetMinimumSize(int minWidth, int minHeight, bool clientSized) {
	// note: don't know what parameter "clientSized" does.
	SDL_SetWindowMinimumSize(mSDLWindow, minWidth, minHeight);
}

void SdlBFWindow::SetMouseVisible(bool isMouseVisible) {
	SDL_ShowCursor(isMouseVisible ? SDL_ENABLE : SDL_DISABLE);
}
