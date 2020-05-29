#!/bin/bash

export distro_name=vala-time-tracker-0.1.0

export target=`pwd`/distro/$distro_name/
echo $target
export DESTDIR=$target

echo $DESTDIR
ninja -C build install

export dlls=`ldd $target/bin/*.exe | grep -i mingw | grep -P -o "/.*?.dll " | sort | uniq `

for x in $dlls
do
echo $x
cp $x $target/bin/
done
cp -r  /mingw64/lib/gdk-pixbuf-2.0 $target/lib/

#
cp -r /mingw64/share/glib-2.0 $target/share/
rsync -avz --include "*/" --include-from=icon-patterns.txt --exclude "*" /mingw64/share/icons/Adwaita $target/share/icons/
gtk-update-icon-cache-3.0.exe $DESTDIR/share/icons/hicolor/
gtk-update-icon-cache-3.0.exe $DESTDIR/share/icons/Adwaita/

cd distro
zip -r ../$distro_name.zip $distro_name
