## Build on Arch Linux

Prerequisites:

1) Install xmake from AUR: https://aur.archlinux.org/packages/xmake
2) Install with pacman: llvm13, noto-fonts

```
git clone https://github.com/flying-dude/Beef
cd Beef
xmake build libffi
xmake
./IDE/dist/BeefIDE
```
