# Build on Linux Using Distro-LLVM

The Linux build of Beef currently requires compiling LLVM on your own system first,
which takes a long time (several hours).

You can find here a CMake configuration that uses the LLVM libraries provided by your Linux distribution instead,
which greatly reduces the time required to build and run Beef on your Linux machine.

Keep in mind that Beef currently still requires LLVM13, wheras most distributions already have upgraded to LLVM14.
So try install an explicit "llvm13" package instead of the default one (see below for Arch Linux).

You may have to set an explicit `CMAKE_PREFIX_PATH` for CMake being able to find the correct LLVM version.
See script `bin/build_release.sh` for how this works.

## Build on Arch Linux

Execute the steps below to create a **release build** on Arch Linux:

```
sudo pacman --sync --needed llvm13 clang noto-fonts sdl2 freetype2 libglvnd
git clone https://github.com/flying-dude/Beef
Beef/bin/build_release.sh
Beef/IDE/dist/BeefBuild -help
```

And for a **debug build**:

```
Beef/bin/build_debug.sh
Beef/IDE/dist/BeefBuild_d -help
```
