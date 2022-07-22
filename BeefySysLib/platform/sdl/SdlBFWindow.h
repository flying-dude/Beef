#pragma once

#include "BFWindow.h"

struct SDL_Window;

NS_BF_BEGIN;

class SdlBFWindow : public BFWindow
{
public:
	SDL_Window*				mSDLWindow;
	bool					mIsMouseInside;
	int						mModalCount;

public:
	SdlBFWindow(BFWindow* parent, const StringImpl& title, int x, int y, int width, int height, int windowFlags);
	~SdlBFWindow();

	virtual void*			GetUnderlying() override { NOT_IMPL_WARN; return nullptr; }
	virtual void			Destroy() override { NOT_IMPL_WARN; }
	virtual bool			TryClose() override;
	virtual void			SetTitle(const char* title) override;
	virtual void			SetForeground() override { NOT_IMPL_WARN; }
	virtual void			LostFocus(BFWindow* newFocus) override { NOT_IMPL_WARN; }
	virtual void			SetMinimumSize(int minWidth, int minHeight, bool clientSized) override;
	virtual void			GetPosition(int* x, int* y, int* width, int* height, int* clientX, int* clientY, int* clientWidth, int* clientHeight) override;
	virtual void			GetPlacement(int* normX, int* normY, int* normWidth, int* normHeight, int* showKind) override;
	virtual void			Resize(int x, int y, int width, int height, int showKind) override { NOT_IMPL_WARN; }
	virtual void			SetClientPosition(int x, int y) override;
	virtual void			SetMouseVisible(bool isMouseVisible) override;
	virtual void			SetAlpha(float alpha, uint32 destAlphaSrcMask, bool isMouseVisible) override;

	virtual BFMenu*			AddMenuItem(BFMenu* parent, int insertIdx, const char* text, const char* hotKey, BFSysBitmap* bitmap, bool enabled, int checkState, bool radioCheck) override;
	virtual void			ModifyMenuItem(BFMenu* item, const char* text, const char* hotKey, BFSysBitmap* bitmap, bool enabled, int checkState, bool radioCheck) override;
	virtual void			RemoveMenuItem(BFMenu* item) override;
};

NS_BF_END;
