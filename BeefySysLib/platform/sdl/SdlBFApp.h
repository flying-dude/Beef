#pragma once

#include "BFApp.h"
#include <map>

NS_BF_BEGIN;

struct SdlBFWindow;
class RenderDevice;

typedef std::map<String, uint32> StringToUIntMap;
typedef std::map<uint32, SdlBFWindow*> SdlWindowMap;

class SdlBFApp : public BFApp
{
public:
	bool					mInMsgProc;
	StringToUIntMap			mClipboardFormatMap;
	SdlWindowMap			mSdlWindowMap;

protected:
	virtual void			Draw() override;
	virtual void			PhysSetCursor() override;

	uint32					GetClipboardFormat(const StringImpl& format);
	SdlBFWindow*			GetSdlWindowFromId(uint32 id);

public:
	SdlBFApp();
	virtual ~SdlBFApp();

	virtual void			Init() override;
	virtual void			Run() override;

	virtual BFWindow*		CreateNewWindow(BFWindow* parent, const StringImpl& title, int x, int y, int width, int height, int windowFlags) override;
	virtual DrawLayer*		CreateDrawLayer(BFWindow* window) override;

	virtual void*			GetClipboardData(const StringImpl& format, int* size) override;
	virtual void			ReleaseClipboardData(void* ptr) override;
	virtual void			SetClipboardData(const StringImpl& format, const void* ptr, int size, bool resetClipboard) override;

	virtual BFSysBitmap*	LoadSysBitmap(const wchar_t* fileName) override;
	virtual void            GetDesktopResolution(int& width, int& height) override;
	virtual void            GetWorkspaceRect(int& x, int& y, int& width, int& height) override;
};

NS_BF_END;
