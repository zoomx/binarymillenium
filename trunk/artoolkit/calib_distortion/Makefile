ARDIR=/home/lucasw/other/sw/ARToolKit
INC_DIR= $(ARDIR)/include
LIB_DIR= $(ARDIR)/lib

IMDIR=/home/lucasw/other/sw//ImageMagick-6.4.3
#IMINCDIR=$(IMDIR)/wand

BIN_DIR=.
#$(ARDIR)/bin


LDFLAG=-L/usr/X11R6/lib -L$(LIB_DIR)
LIBS= -lARgsub_lite -lARvideo -lAR -lglut -lGLU -lGL -lXi -lXmu -lX11 -lm
CFLAG= -O -I/usr/X11R6/include -g -I$(INC_DIR) -I$(IMDIR)


all: $(BIN_DIR)/calib_dist

$(BIN_DIR)/calib_dist: calib_dist.o check_dist.o
	cc -o $(BIN_DIR)/calib_dist calib_dist.o check_dist.o\
	   $(LDFLAG) $(LIBS)

calib_dist.o: calib_dist.c calib_dist.h
	cc -c $(CFLAG) calib_dist.c

check_dist.o: check_dist.c calib_dist.h
	cc -c $(CFLAG) check_dist.c

clean:
	rm -f calib_dist.o check_dist.o
	rm -f $(BIN_DIR)/calib_dist

allclean:
	rm -f calib_dist.o check_dist.o
	rm -f $(BIN_DIR)/calib_dist
	rm -f Makefile
