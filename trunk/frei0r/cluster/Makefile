CC=gcc
CCFLAGS=-Wall -fPIC -g -I../../ -c
LDFLAGS=-Wl -shared

all: objects
	$(CC) $(LDFLAGS) -o cluster.so cluster.o

objects: cluster.c
	$(CC) $(CCFLAGS) -o cluster.o cluster.c

clean: 
	- rm -f cluster.o cluster.so *~

