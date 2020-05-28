ldd distro/bin/*.exe | grep -i mingw | grep -P -o "/.*?.dll " | sort | uniq 

