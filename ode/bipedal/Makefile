CC=gcc
ODEDIR = /home/lucasw/other/sw/ode-0.9
CCFLAGS += -c -DHAVE_CONFIG_H -I. -I$(ODEDIR)/include -I$(ODEDIR)/include/ode -MD -MP -MF -MT

LDFLAGS = $(ODEDIR)/ode/src/libode.a -ldrawstuff -lGL -lGLU -lXmu -lXi -lX11  -lstdc++ -lm -lpthread  -lstdc++ -lm -lpthread -L$(ODEDIR)/drawstuff/src -L$(ODEDIR)/ode/src
#-shared  

all: objects
	$(CC) -o bipedal bipedal.o  $(LDFLAGS)

objects: bipedal.c 
	$(CC) $(CCFLAGS) -o bipedal.o bipedal.c

#clean: 
#	- rm -f fgrxtx.o fgrxtx.dll atan_fixed.o *~
