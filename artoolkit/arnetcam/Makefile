ARDIR=/home/lucasw/other/sw/ARToolKit
INC_DIR= $(ARDIR)/include
LIB_DIR= $(ARDIR)/lib

IMDIR=/home/lucasw/other/sw/ImageMagick-6.4.9-6
#IMINCDIR=$(IMDIR)/wand

BIN_DIR=.
#$(ARDIR)/bin

EXEC=arlaser

LDFLAG= -L/home/lucasw/other/install/lib -L/usr/X11R6/lib -L$(LIB_DIR) $(shell curl-config --libs) 
LIBS= -lMagick++ -lARgsub -lARvideo -lAR -lglut -lGLU -lGL -lXi -lXmu -lX11 -lm
CFLAG= -O -I/usr/X11R6/include -g -I$(INC_DIR) -I$(IMDIR) $(shell curl-config --cflags)


OBJS = loadimage.o
HEADDERS =

all: $(BIN_DIR)/$(EXEC)

$(BIN_DIR)/$(EXEC): $(EXEC).o $(OBJS)
	cc -o $(BIN_DIR)/$(EXEC) $(EXEC).o $(OBJS) $(LDFLAG) $(LIBS)

loadimage.o: loadimage.c
	cc -c $(CFLAG) loadimage.c

$(EXEC).o: $(EXEC).c $(HEADDERS)
	cc -c $(CFLAG) $(EXEC).c 

clean:
	rm -f *.o
	rm -f $(BIN_DIR)/$(EXEC)

allclean:
	rm -f *.o
	rm -f $(BIN_DIR)/$(EXEC)
	rm -f Makefile
