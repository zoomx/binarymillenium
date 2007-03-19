TOPDIR = .
include $(TOPDIR)/Make/makedefs 

CXXFILES =\
	GliderManipulator.cpp\
	line.cpp\
	osgviewer.cpp
	

LIBS     += -losgProducer -lProducer -losgText -losgGA -losgDB -losgUtil -losg $(GL_LIBS) $(X_LIBS) $(OTHER_LIBS) 

INSTFILES = \
	$(CXXFILES)\
	GNUmakefile.inst=GNUmakefile

EXEC = osgviewer

INC +=  $(X_INC) 

include $(TOPDIR)/Make/makerules 

