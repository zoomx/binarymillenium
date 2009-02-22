libdir = @gphx_module_lib_dir@

PLUC=python @srcdir@/../../pluc.py

arboardmodule_auto.c: arboardmodule.spec arboardmodule.h
	$(PLUC) c @srcdir@/arboardmodule.spec

arboardmodule.h: arboardmodule.spec
	$(PLUC) h @srcdir@/arboardmodule.spec

lib_LTLIBRARIES = arboardmodule.la

arboardmodule_la_SOURCES = 	arboardmodule_auto.c \
				arboardmodule.c \
				arboardmodule.h \
				arboardmodule.spec \
				arboardmodule.xpm

arboardmodule_la_LDFLAGS = -module -avoid-version

INCLUDES = 	-I @srcdir@/../../../engine/src/engine \
		-I @srcdir@/../../../util/include \
		-I @srcdir@/../../../types/src/numbertype \
		-I @srcdir@/../../../types/src/positiontype 

DISTCLEANFILES = arboardmodule.h arboardmodule_auto.c
EXTRA_DIST = arboardmodule.dsp arboardmodule.mak arboardmodule.dep
