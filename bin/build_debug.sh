#!/bin/bash

# Debug Build of Beef on Unix Platforms
echo Starting build_debug.sh

PATH=/usr/local/bin:$PATH:$HOME/bin
SCRIPTPATH=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
ROOTPATH="$(dirname "$SCRIPTPATH")"
echo Building from $SCRIPTPATH
cd $SCRIPTPATH

# Exit When Any Command Fails
set -e

# Print Executed Commands to Shell
set -x

### Build libffi ###

if [ ! -f ../BeefySysLib/third_party/libffi/Makefile ]; then
	echo Building libffi...
	cd ../BeefySysLib/third_party/libffi
	./configure
	make
	cd $SCRIPTPATH
fi

### Beef C++ Code ###

cd ..

CMAKE_PREFIX_PATH=/usr/lib/llvm13/lib/cmake/llvm/ cmake -DCMAKE_BUILD_TYPE=Debug -S . -B jbuild_d -GNinja
cmake --build jbuild_d

cd IDE/dist

if [[ "$OSTYPE" == "darwin"* ]]; then
	LIBEXT=dylib
	LINKOPTS="-Wl,-no_compact_unwind -Wl,-rpath -Wl,@executable_path"
else
	LIBEXT=so
	LINKOPTS="-ldl -lpthread -Wl,-rpath -Wl,\$ORIGIN"
fi

ln -s -f $ROOTPATH/jbuild_d/Debug/bin/libBeefRT_d.a libBeefRT_d.a
ln -s -f $ROOTPATH/jbuild_d/Debug/bin/libBeefySysLib_d.$LIBEXT libBeefySysLib_d.$LIBEXT
ln -s -f $ROOTPATH/jbuild_d/Debug/bin/libIDEHelper_d.$LIBEXT libIDEHelper_d.$LIBEXT

ln -s -f $ROOTPATH/jbuild_d/Debug/bin/libBeefRT_d.a ../../BeefLibs/Beefy2D/dist/libBeefRT_d.a
ln -s -f $ROOTPATH/jbuild_d/Debug/bin/libBeefySysLib_d.$LIBEXT ../../BeefLibs/Beefy2D/dist/libBeefySysLib_d.$LIBEXT
ln -s -f $ROOTPATH/jbuild_d/Debug/bin/libIDEHelper_d.$LIBEXT ../../BeefLibs/Beefy2D/dist/libIDEHelper_d.$LIBEXT

# quickfix: it still wants the release build of the RT here?
ln -s -f $ROOTPATH/jbuild_d/Debug/bin/libBeefRT_d.a libBeefRT.a

### Beef Self-Hosted Code ###

echo Building BeefBuild_bootd
../../jbuild_d/Debug/bin/BeefBoot --out="BeefBuild_bootd" --src=../src --src=../../BeefBuild/src --src=../../BeefLibs/corlib/src --src=../../BeefLibs/Beefy2D/src --define=CLI --define=DEBUG --startup=BeefBuild.Program --linkparams="./libBeefRT_d.a ./libIDEHelper_d.$LIBEXT ./libBeefySysLib_d.$LIBEXT $(< ../../IDE/dist/IDEHelper_libs_d.txt) $LINKOPTS"
echo Building BeefBuild_d
./BeefBuild_bootd -clean -proddir=../../BeefBuild -config=Debug
echo Testing IDEHelper/Tests in BeefBuild_d
./BeefBuild_d -proddir=../../IDEHelper/Tests -test
echo Building BeefIDE_d
./BeefBuild_d -proddir=.. -config=Debug
