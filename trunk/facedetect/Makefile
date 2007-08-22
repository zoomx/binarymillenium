CC=g++
#CCFLAGS=-g -Wall -fPIC
CCFLAGS=  -I../.. -I/home/lucasw/other/install/include/opencv   
CCFLAGS += -c
CCFLAGS +=  -I/usr/include/X11

LDFLAGS = -Wl -shared -L/home/lucasw/other/install/lib/ -lcv -lhighgui 

all: objects
	$(CC) -o facedetect.so facedetect.o $(LDFLAGS)

objects: facedetect.c
	$(CC) $(CCFLAGS) -o facedetect.o facedetect.c

clean: 
	- rm -f facedetect.o facedetect.dll *~
