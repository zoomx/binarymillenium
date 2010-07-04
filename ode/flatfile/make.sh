#!/bin/bash

ODEDIR=/home/lucasw/other2/ode-0.11.1
FILE=flatfile
EXEC=ode_flatfile

#g++ -c -DHAVE_CONFIG_H -I. -I$ODEDIR/ode/src -I$ODEDIR/include -DDRAWSTUFF_TEXTURE_PATH="\"$ODEDIR/drawstuff/textures\"" -DdTRIMESH_ENABLED -DdSINGLE  -g -O2 -MT $FILE.o -MD -MP -MF -o $FILE.o $FILE.cpp
g++ -c -o $FILE.o -DHAVE_CONFIG_H -I. -I$ODEDIR/ode/src -I$ODEDIR/include -DDRAWSTUFF_TEXTURE_PATH="\"$ODEDIR/drawstuff/textures\"" -DdTRIMESH_ENABLED -DdSINGLE -g -O2 $FILE.cpp

FILE=utility

windres $ODEDIR/drawstuff/src/resources.rc -o resources.o

g++ -c -o $FILE.o -DHAVE_CONFIG_H -I. -I$ODEDIR/ode/src -I$ODEDIR/include -DDRAWSTUFF_TEXTURE_PATH="\"$ODEDIR/drawstuff/textures\"" -DdTRIMESH_ENABLED -DdSINGLE -g -O2 $FILE.cpp

/bin/sh $ODEDIR/libtool --tag=CXX   --mode=link g++  -g -O2   -o ode_flatfile.exe flatfile.o utility.o $ODEDIR/drawstuff/src/libdrawstuff.la $ODEDIR/ode/src/libode.la -lglu32 -lopengl32 resources.o -lm  -lpthread

g++ -g -O2 -o $EXEC flatfile.o utility.o resources.o  $ODEDIR/drawstuff/src/.libs/libdrawstuff.a -lwinmm -lgdi32 $ODEDIR/ode/src/.libs/libode.a -lglu32 -lopengl32 -lpthread
