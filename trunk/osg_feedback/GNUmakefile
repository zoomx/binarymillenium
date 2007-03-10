TOPDIR = ../..
include $(TOPDIR)/Make/makedefs 

CXXFILES =\
	osgprerender.cpp\
#	drawing.cpp\


#-lcapturemodule -lframebuffertype -lnumbertype
LIBS     +=  -losgProducer -lProducer -losgText -losgGA -losgDB -losgUtil -losg $(GL_LIBS) $(X_LIBS) $(OTHER_LIBS) 

# uncomment in windows
#LIBS     += -L/cygdrive/c/lucasw/wxWidgets-2.8.0/lib/wx  
#LIBS     +=  -lwx_base-2.8 -lwx_msw_core-2.8 
#INC +=  -DUSEWX $(X_INC) -DOS_WIN32 -I/cygdrive/c/lucasw/wxWidgets-2.8.0/lib/wx/include/msw-ansi-release-2.8 -I/cygdrive/c/lucasw/wxWidgets-2.8.0/include

INSTFILES = \
	$(CXXFILES)\
	GNUmakefile.inst=GNUmakefile

EXEC = osgprerender


include $(TOPDIR)/Make/makerules 
