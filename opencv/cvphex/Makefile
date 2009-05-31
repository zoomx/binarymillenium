CC=g++
#CCFLAGS=-g -Wall -fPIC
CCFLAGS=  -I/home/lucasw/other/install/include/opencv   
CCFLAGS += -c
CCFLAGS +=  -I/usr/include/X11

LDFLAGS = -Wl -L/home/lucasw/other/install/lib/ -lcv -lhighgui 

FILES =\
	cvphex.o \
	module.o

EXEC = cvphex

all: $(EXEC)

$(EXEC): $(FILES)
	@echo building $@ with $(OBJS)
	$(CC) $(LDFLAGS) $(FILES) $(LIBS) -o $@ 

%.o: %.cpp
	@echo $@ depends on $<
	$(CC) $(CCFLAGS) -c $< -o $@ 

clean: 
	- rm -f cvphex.o cvphex.dll *~
