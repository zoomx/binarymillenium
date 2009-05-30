CC=g++
#CCFLAGS=-g -Wall -fPIC
CCFLAGS=  -I/home/lucasw/other/install/include/opencv   
CCFLAGS += -c
CCFLAGS +=  -I/usr/include/X11

LDFLAGS = -Wl -L/home/lucasw/other/install/lib/ -lcv -lhighgui 

all: objects
	#$(CC) -o cvphex.so cvphex.o $(LDFLAGS)
	$(CC) -o cvphex cvphex.o $(LDFLAGS)

objects: cvphex.cpp
	$(CC) $(CCFLAGS) -o cvphex.o cvphex.cpp

clean: 
	- rm -f cvphex.o cvphex.dll *~
