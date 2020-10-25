# Vala Time Tracker
----------------------

## Installing on Windows

1. Setup an MSYS2 environment on your machine:
http://www.msys2.org/

2. Update your environment:
```
pacman -Syu
```

3. Clone this git repository:
```
4. Install the required packages from pkglist.txt:
```
pacman -S --needed - < required-packages.txt
```

5. Fire up meson and ninja:
```
cd vala-time-tracker
meson build
ninja -C build
```

6. Test the build:
```
cd build/src/
./TimeTracker.exe
```

7. Install to /mingw64:
```
ninja -C build install
```

8. Build a zippable distro:
```
sh build-distro.sh

```
