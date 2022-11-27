# Porting the Beef IDE to Linux

The Beef proramming language ships with an IDE, that is currently only supported on Windows.
It already
[contains](https://github.com/beefytech/Beef/tree/master/BeefySysLib/platform/sdl)
the basic facilities for a Linux/Mac port of the Beef IDE.
It is a SDL-based rendering backend for the UI.
This fork attempts to bring these existing facilities to life on Linux platforms

## Regression November 2022

The project still builds the C++ code but fails when building the self-hosted components of the system.

```
$ xmake
Building: BeefBuild_boot
[******************************]
TIMING: Beef compiling: 65.4s
Comptime execution time: 0.45s
Linking IDE/dist/BeefBuild_boot...
SUCCESS
Building: BeefBuild
SdlBFApp.cpp :: 39 :: warning :: On-demand loading of libSDL is not yet supported on Linux.
SdlBFApp.cpp :: 40 :: warning :: Use dlopen() instead of LoadLibraryA. See header NotWin.h
NotWin.h :: 218 :: warning :: NOT IMPLEMENTED: LoadLibraryA
LoadLibraryA: Use dlopen() on Linux.
error: execv(IDE/dist/BeefBuild_boot -proddir=BeefBuild -config=Release) failed(-1)
```

The code was recently
[refactored](https://github.com/beefytech/Beef/commit/7293fed046f5f113262d234fab17d7e34025f92c#diff-5bf8db506926a1015f86b15a7bb4e07283f6fe51166f3551dc3cf4ba1ad1fa5fR33)
to support loading SDL on-demand at runtime.
This feature is not yet implemented on Linux.
However, SDL is only for graphics and should not be invoked when running the build script.

## Build on Arch Linux

Prerequisites:

* Install xmake from AUR: https://aur.archlinux.org/packages/xmake

```
sudo pacman --sync --needed llvm13 clang noto-fonts sdl2 freetype2 libglvnd
git clone --branch xmake https://github.com/flying-dude/Beef
cd Beef
xmake build libffi
xmake
./IDE/dist/BeefIDE
```

This is work in progress.
Currently you can compile the IDE and display the main SDL window of the IDE.

Here is how it looks right now:

![Screenshot](BeefIDE-Linux.png)

