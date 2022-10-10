#include "BeefySysLib/Common.h"
#include "LinuxDebugger.h"
#include "Debugger.h"
#include "X86Target.h"

namespace Beefy
{
	class DbgMiniDump;
}

USING_NS_BF_DBG;
USING_NS_BF;
NS_BF_BEGIN

Beefy::Debugger* CreateDebugger32(DebugManager* debugManager, DbgMiniDump* miniDump)
{
	return NULL;
}

Beefy::Debugger* CreateDebugger64(DebugManager* debugManager, DbgMiniDump* miniDump)
{
	// custom X86 backend deactivated on linux for now,
	// since it has compile error when using distro-provided llvm package.
	// if (gX86Target == NULL)
		// gX86Target = new X86Target();
	return NULL;
}

NS_BF_END
