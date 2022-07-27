#!/bin/bash

# Release Build of Beef on Unix Platforms
echo Starting build_release.sh

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

CMAKE_PREFIX_PATH=/usr/lib/llvm13/lib/cmake/llvm/ cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -S . -B jbuild -GNinja
cmake --build jbuild

cd IDE/dist

if [[ "$OSTYPE" == "darwin"* ]]; then
	LIBEXT=dylib
	LINKOPTS="-Wl,-no_compact_unwind -Wl,-rpath -Wl,@executable_path"
else
	LIBEXT=so
	LINKOPTS="-ldl -lpthread -Wl,-rpath -Wl,\$ORIGIN"
fi

ln -s -f $ROOTPATH/jbuild/Release/bin/libBeefRT.a libBeefRT.a
ln -s -f $ROOTPATH/jbuild/Release/bin/libBeefySysLib.$LIBEXT libBeefySysLib.$LIBEXT
ln -s -f $ROOTPATH/jbuild/Release/bin/libIDEHelper.$LIBEXT libIDEHelper.$LIBEXT

ln -s -f $ROOTPATH/jbuild/Release/bin/libBeefRT.a ../../BeefLibs/Beefy2D/dist/libBeefRT.a
ln -s -f $ROOTPATH/jbuild/Release/bin/libBeefySysLib.$LIBEXT ../../BeefLibs/Beefy2D/dist/libBeefySysLib.$LIBEXT
ln -s -f $ROOTPATH/jbuild/Release/bin/libIDEHelper.$LIBEXT ../../BeefLibs/Beefy2D/dist/libIDEHelper.$LIBEXT

### Beef Self-Hosted Code ###

echo Building BeefBuild_boot
../../jbuild/Release/bin/BeefBoot --out="BeefBuild_boot" --src=../src --src=../../BeefBuild/src --src=../../BeefLibs/corlib/src --src=../../BeefLibs/Beefy2D/src --define=CLI --startup=BeefBuild.Program --linkparams="./libBeefRT.a ./libIDEHelper.$LIBEXT ./libBeefySysLib.$LIBEXT $(< ../../IDE/dist/IDEHelper_libs.txt) $LINKOPTS"
echo Building BeefBuild
./BeefBuild_boot -clean -proddir=../../BeefBuild -config=Release
echo Testing IDEHelper/Tests in BeefBuild
./BeefBuild -proddir=../../IDEHelper/Tests -test
echo Building BeefIDE
./BeefBuild -proddir=.. -config=Release
