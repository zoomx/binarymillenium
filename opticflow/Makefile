CC=g++
#CCFLAGS=-g -Wall -fPIC
CCFLAGS=  -I../.. -I../../../other/install/include/opencv   
CCFLAGS += -c
CCFLAGS +=  -I/usr/include/X11

LDFLAGS = -Wl -shared -L../../../other/install/lib/ -lcv -lhighgui 

all: objects
	$(CC) -o opticflow.so opticflow.o $(LDFLAGS)

objects: opticflow.c
	$(CC) $(CCFLAGS) -o opticflow.o opticflow.c

clean: 
	- rm -f opticflow.o opticflow.dll *~
