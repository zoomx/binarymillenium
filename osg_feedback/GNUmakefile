TOPDIR = ../..
include $(TOPDIR)/Make/makedefs 

CXXFILES =\
	osgprerender.cpp\
#	drawing.cpp\


#-lcapturemodule -lframebuffertype -lnumbertype
LIBS     +=  -losgProducer -lProducer -losgText -losgGA -losgDB -losgUtil -losg $(GL_LIBS) $(X_LIBS) $(OTHER_LIBS) 
LIBS     += -L/cygdrive/c/lucasw/wxWidgets-2.8.0/lib/wx  
LIBS     +=  -lwx_base-2.8 -lwx_msw_core-2.8 
#wxwindows libs
#LIBS     += -L/cygdrive/c/lucasw/wxWidgets-2.8.0/lib/wx -lgdi32 -lwx_msw_core-2.8 
#LIBS     += -lz -lrpcrt4 -loleaut32 -lole32 -luuid -lwinspool -lwinmm -lshell32 -lcomctl32 -lcomdlg32 -lctl3d32 -ladvapi32 -lwsock32 -lgdi32 -lkernel32 -luser32 -lwx_msw_core-2.8  -lwx_base-2.8      -lpng -lz -ljpeg -ltiff     -lz -lrpcrt4 -loleaut32 -lole32 -luuid -lwinspool -lwinmm -lshell32 -lcomctl32 -lcomdlg32 -lctl3d32 -ladvapi32 -lwsock32 -lgdi32 -lkernel32 -luser32 

INSTFILES = \
	$(CXXFILES)\
	GNUmakefile.inst=GNUmakefile

EXEC = osgprerender

INC +=  $(X_INC) -DOS_WIN32 -I/cygdrive/c/lucasw/wxWidgets-2.8.0/lib/wx/include/msw-ansi-release-2.8 -I/cygdrive/c/lucasw/wxWidgets-2.8.0/include

include $(TOPDIR)/Make/makerules 
