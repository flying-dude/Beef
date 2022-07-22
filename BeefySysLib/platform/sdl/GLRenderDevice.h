#pragma once

#include "Common.h"

#ifdef BF_PLATFORM_OPENGL_ES2
#include "SDL_opengles2.h"
#else
#include "SDL_opengl.h"
#endif

#include "gfx/Shader.h"
#include "gfx/Texture.h"
#include "gfx/RenderDevice.h"
#include "gfx/DrawLayer.h"

#include <map>
#include <vector>

struct SDL_Window;

NS_BF_BEGIN;

class Vertex3D : public DefaultVertex3D
{
};

class BFApp;
class GLRenderDevice;

class GLTexture : public Texture
{
public:
	GLRenderDevice*			mRenderDevice;
	GLuint					mGLTexture;
	GLuint					mGLTexture2;
	//IGL10RenderTargetView*	mGLRenderTargetView;

public:
	GLTexture();
	~GLTexture();

	virtual void			PhysSetAsTarget();
};

class GLShaderParam : public ShaderParam
{
public:
	GLint					mGLVariable;

public:
	GLShaderParam();
	~GLShaderParam();

	virtual void			SetTexture(Texture* texture) override;
	virtual void			SetFloat4(float x, float y, float z, float w) override;
};

typedef std::map<String, GLShaderParam*> GLShaderParamMap;

class GLShader : public Shader
{
public:
	//IGL10Effect*			mGLEffect;

	GLuint mGLVertexShader;
	GLuint mGLFragmentShader;
	GLuint mGLProgram;
	GLint mAttribPosition;
	GLint mAttribTexCoord0;
	GLint mAttribColor;
	GLint mAttribTex0;
	GLint mAttribTex1;
	
	GLShaderParamMap		mParamsMap;	

public:
	GLShader();
	~GLShader();
	
	virtual ShaderParam*	GetShaderParam(const StringImpl& name) override;
};

class GLDrawBatch : public DrawBatch
{
public:
	//IGL10Buffer*			mGLBuffer;

public:
	GLDrawBatch(int minVtxSize = 0, int minIdxSize = 0);
	~GLDrawBatch();

	virtual void			Lock();
	virtual void			Draw();

	virtual void Render(RenderDevice* renderDevice, RenderWindow* renderWindow) override { NOT_IMPL_WARN; }
};

class GLDrawLayer : public DrawLayer
{
public:
	virtual DrawBatch*		CreateDrawBatch() override;
	virtual DrawBatch*		AllocateBatch(int minVtxCount, int minIdxCount) override;

	// TODO this method is unused and should probably be deleted.
	/*virtual*/ void			FreeBatch(DrawBatch* drawBatch) /*override*/;

	virtual RenderCmd* CreateSetTextureCmd(int textureIdx, Texture* texture) override;
	virtual void SetShaderConstantData(int usageIdx, int slotIdx, void* constData, int size) override { NOT_IMPL_WARN; }

public:
	GLDrawLayer();
	~GLDrawLayer();
};

class GLRenderWindow : public RenderWindow
{
public:
	SDL_Window*				mSDLWindow;
	GLRenderDevice*			mRenderDevice;
	//IGLGISwapChain*			mGLSwapChain;
	//IGL10Texture2D*		mGLBackBuffer;
	//IGL10RenderTargetView*	mGLRenderTargetView;
	bool					mResizePending;
	int						mPendingWidth;
	int						mPendingHeight;		

public:
	virtual void			PhysSetAsTarget();

public:
	GLRenderWindow(GLRenderDevice* renderDevice, SDL_Window* sdlWindow);
	~GLRenderWindow();

	void					SetAsTarget() override;
	void					Resized() override;
	virtual void			Present() override;

	void					CopyBitsTo(uint32* dest, int width, int height);
};

typedef std::vector<GLDrawBatch*> GLDrawBatchVector;

class GLRenderDevice : public RenderDevice
{
public:
	//IGLGIFactory*			mGLGIFactory;
	//IGL10Device*			mGLDevice;
	//IGL10BlendState*		mGLNormalBlendState;
	//IGL10BlendState*		mGLAdditiveBlendState;
	//IGL10RasterizerState*	mGLRasterizerStateClipped;
	//IGL10RasterizerState*	mGLRasterizerStateUnclipped;

	GLuint					mGLVertexBuffer;
	GLuint					mGLIndexBuffer;
	GLuint					mBlankTexture;

	bool					mHasVSync;

	GLDrawBatchVector		mDrawBatchPool;
    GLDrawBatch*            mFreeBatchHead;

public:
	virtual void			PhysSetAdditive(bool additive);
	virtual void			PhysSetShader(Shader* shaderPass);
	virtual void			PhysSetRenderWindow(RenderWindow* renderWindow);

	virtual void			PhysSetRenderState(RenderState* renderState) override { NOT_IMPL_WARN; }
	virtual void			PhysSetRenderTarget(Texture* renderTarget) override;

public:
	GLRenderDevice();
	virtual ~GLRenderDevice();
	bool					Init(BFApp* app) override;

	void					FrameStart() override;
	void					FrameEnd() override;

	virtual Texture*				LoadTexture(ImageData* imageData, int flags) override;
	virtual Texture*					CreateDynTexture(int width, int height) override { NOT_IMPL; }
	Texture*				CreateRenderTarget(int width, int height, bool destAlpha) override;
	virtual Shader* LoadShader(const StringImpl& fileName, VertexDefinition* vertexDefinition) override;
};

// copied from platform/win for now
class GLSetTextureCmd : public RenderCmd
{
public:
	int						mTextureIdx;
	Texture*				mTexture;

public:
	virtual void Render(RenderDevice* renderDevice, RenderWindow* renderWindow) override;
};

NS_BF_END;
