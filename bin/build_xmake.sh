#!/bin/bash
echo Starting build_xmake.sh

xmake build BeefBoot

PATH=/usr/local/bin:$PATH:$HOME/bin
SCRIPTPATH=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
ROOTPATH="$(dirname "$SCRIPTPATH")"
echo Building from $SCRIPTPATH
cd $SCRIPTPATH

# exit when any command fails
set -e

### LIBS ###

cd ../IDE/dist

ln -s -f $ROOTPATH/build/linux/x86_64/release/libBeefRT.a
ln -s -f $ROOTPATH/build/linux/x86_64/release/libBeefySysLib.so
ln -s -f $ROOTPATH/build/linux/x86_64/release/libIDEHelper.so
ln -s -f $ROOTPATH/build/linux/x86_64/release/libBeefRT.a ../../BeefLibs/Beefy2D/dist/libBeefRT.a
ln -s -f $ROOTPATH/build/linux/x86_64/release/libBeefySysLib.so ../../BeefLibs/Beefy2D/dist/libBeefySysLib.so
ln -s -f $ROOTPATH/build/linux/x86_64/release/libIDEHelper.so ../../BeefLibs/Beefy2D/dist/libIDEHelper.so

### RELEASE ###

echo Building BeefBuild_boot
LINKOPTS="-ldl -lpthread -lLLVM -lffi -lutf8proc -ljpeg -lpng -lfreetype -Wl,-rpath -Wl,\$ORIGIN"
../../build/linux/x86_64/release/BeefBoot --out="BeefBuild_boot" --src=../src --src=../../BeefBuild/src --src=../../BeefLibs/corlib/src --src=../../BeefLibs/Beefy2D/src --define=CLI --startup=BeefBuild.Program --linkparams="./libBeefRT.a ./libIDEHelper.so ./libBeefySysLib.so $LINKOPTS"
echo Building BeefBuild
./BeefBuild_boot -clean -proddir=../../BeefBuild -config=Release
echo Testing IDEHelper/Tests in BeefBuild
./BeefBuild -proddir=../../IDEHelper/Tests -test
