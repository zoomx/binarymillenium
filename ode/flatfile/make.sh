#!/bin/bash

ODEDIR=/home/lucasw/other2/ode-0.11.1
FILE=flatfile

g++ -DHAVE_CONFIG_H -I. -I$ODEDIR/ode/src  -I$ODEDIR/include -DDRAWSTUFF_TEXTURE_PATH="\"$ODEDIR/drawstuff/textures\"" -DdTRIMESH_ENABLED -DdSINGLE  -g -O2 -MT $FILE.o -MD -MP -MF -c -o $FILE.o $FILE.cpp

FILE=utility

#g++ -DHAVE_CONFIG_H -I. -I$ODEDIR/ode/src  -I$ODEDIR/include -DDRAWSTUFF_TEXTURE_PATH="\"$ODEDIR/drawstuff/textures\"" -DdTRIMESH_ENABLED -DdSINGLE  -g -O2 -MT $FILE.o -MD -MP -MF -c -o $FILE.o $FILE.cpp

