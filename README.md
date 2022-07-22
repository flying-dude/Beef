# Porting the Beef IDE to Linux

The Beef proramming language ships with an IDE, that is currently only supported on Windows.
It already
[contains](https://github.com/beefytech/Beef/tree/master/BeefySysLib/platform/sdl)
the basic facilities for a Linux/Mac port of the Beef IDE.
It is a SDL-based rendering backend for the UI.
This fork attempts to bring these existing facilities to life on Linux platforms

## Build on Arch Linux

Prerequisites:

* Install xmake from AUR: https://aur.archlinux.org/packages/xmake

```
sudo pacman --sync llvm13 noto-fonts
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

