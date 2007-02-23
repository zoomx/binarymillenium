CC=g++
#CCFLAGS=-g -Wall -fPIC
CCFLAGS=  -I../.. -c

# still compiles with these
#CCFLAGS+=  -D__WXMSW__
#CCFLAGS+= -mthreads -Wall -Wundef
#CCFLAGS+= -O2
#CCFLAGS+= -fno-strict-aliasing
#CCFLAGS+= -Wno-ctor-dtor-privacy 


CCFLAGS+= -DWXUSINGDLL 
CCFLAGS+=-I/home/lucasw/wxWidgets-2.8.0/lib/wx/include/msw-ansi-release-2.8 
CCFLAGS+=-I/usr/local/include/wx-2.8

#LDFLAGS=-Wl -shared
LDFLAGS = -Wl -shared -L/home/lucasw/wxWidgets-2.8.0/lib -mwindows  -lwx_msw_core-2.8 -lwx_base-2.8

 

 


all: objects
	$(CC) -o screencap.dll screencap.o $(LDFLAGS) 

objects: screencap.c
	$(CC) $(CCFLAGS) -o screencap.o screencap.c

clean: 
	- rm -f screencap.o screencap.dll *~

