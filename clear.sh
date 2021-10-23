#!/bin/sh

. ./setenv.sh

rm -f src/$PACKAGE_PATH/R.java
rm -f assets/*
rm -f *.out
rm -f -r bin
mkdir bin
chmod a+w+r+x bin
rm -f -r lib
mkdir lib
chmod a+w+r+x lib
rm -f -r libs
mkdir libs
chmod a+w+r+x libs
rm -f -r obj
mkdir obj
chmod a+w+r+x obj