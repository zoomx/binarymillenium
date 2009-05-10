CC=g++
#CCFLAGS=-g -Wall -fPIC
CCFLAGS=  -I/home/lucasw/other/install/include/opencv   
CCFLAGS += -c
CCFLAGS +=  -I/usr/include/X11

LDFLAGS = -Wl -L/home/lucasw/other/install/lib/ -lcv -lhighgui 

all: objects
	#$(CC) -o contours.so contours.o $(LDFLAGS)
	$(CC) -o contours contours.o $(LDFLAGS)

objects: contours.c
	$(CC) $(CCFLAGS) -o contours.o contours.c

clean: 
	- rm -f contours.o contours.dll *~
