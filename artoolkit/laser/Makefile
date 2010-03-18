ARDIR=/home/lucasw/other/sw/ARToolKit
INC_DIR= $(ARDIR)/include
LIB_DIR= $(ARDIR)/lib

IMDIR=/home/lucasw/other/sw/ImageMagick-6.4.9-6
#IMDIR=/home/lucasw/other/sw/ImageMagick-6.4.9-2
#IMINCDIR=$(IMDIR)/wand

BIN_DIR=.
#$(ARDIR)/bin

EXEC=arlaser

LDFLAG=-L/usr/X11R6/lib -L$(LIB_DIR) -L/home/lucasw/other/install/lib
LIBS= -lMagick++ -lARgsub -lARvideo -lAR -lglut -lGLU -lGL -lXi -lXmu -lX11 -lm
CFLAG= -O -I/usr/X11R6/include -g -I$(INC_DIR) -I$(IMDIR)

OBJS =
HEADDERS =

all: $(BIN_DIR)/$(EXEC)

$(BIN_DIR)/$(EXEC): $(EXEC).o $(OBJS)
	cc -o $(BIN_DIR)/$(EXEC) $(EXEC).o $(OBJS) $(LDFLAG) $(LIBS)

$(EXEC).o: $(EXEC).c $(HEADDERS)
	cc -c $(CFLAG) $(EXEC).c

clean:
	rm -f *.o
	rm -f $(BIN_DIR)/$(EXEC)

allclean:
	rm -f *.o
	rm -f $(BIN_DIR)/$(EXEC)
	rm -f Makefile
