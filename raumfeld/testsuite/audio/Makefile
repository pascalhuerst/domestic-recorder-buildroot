#CROSS=ARM

ifeq ($(CROSS),ARM)
OBJDIR = ./arm
else
OBJDIR = ./386
endif

common_OBJS = \
	$(OBJDIR)/main.o		\
	$(OBJDIR)/options.o		\
	$(OBJDIR)/p0-alsa-capture.o	\
	$(OBJDIR)/p0-alsa-tools.o	\
	$(OBJDIR)/p0-alsa.o		\
	$(OBJDIR)/p0-control.o		\
	$(OBJDIR)/p0-dbus-service.o	\
	$(OBJDIR)/p0-dsp.o		\
	$(OBJDIR)/p0-eq.o		\
	$(OBJDIR)/p0-feedback.o		\
	$(OBJDIR)/p0-generator.o	\
	$(OBJDIR)/p0-gst.o		\
	$(OBJDIR)/p0-input.o		\
	$(OBJDIR)/p0-manager.o		\
	$(OBJDIR)/p0-marshal.o		\
	$(OBJDIR)/p0-mixer.o		\
	$(OBJDIR)/p0-renderer.o		\
	$(OBJDIR)/p0-streamserver.o	\
	$(OBJDIR)/p0-transport.o

APP = p0-renderer

ifeq ($(CROSS),ARM)
ARCH=arm

CROSS_PREFIX      = $(HOME)/buildroot
CROSS_STAGING_DIR = $(CROSS_PREFIX)/build_arm/staging_dir
CROSS_INSTALL_DIR = $(HOME)/root.arm/p0-renderer

CROSS_GCC_VERSION = 4.3.3
CROSS_GCC         = usr/lib/gcc/arm-linux-uclibcgnueabi/$(CROSS_GCC_VERSION)

PKG_CONFIG_SYSROOT_DIR=CROSS_STAGING_DIR
PKG_CONFIG=$(CROSS_PREFIX)/build_arm/host_dir/usr/bin/pkg-config
PKG_CONFIG_PATH=$(CROSS_STAGING_DIR)/usr/lib/pkgconfig

EXTRA_CC_FLAGS = -nostdinc -D_REENTRANT -D_VERBOSE -D_DEBUG -D_POSIX -DP0ARMWORKAROUND\
 -I$(CROSS_STAGING_DIR)/$(CROSS_GCC)/include\
 -I$(CROSS_STAGING_DIR)/usr/include\
 -I$(CROSS_STAGING_DIR)/usr/include/linux

CC = $(CROSS_STAGING_DIR)/usr/bin/arm-linux-gcc
LD = $(CROSS_STAGING_DIR)/usr/bin/arm-linux-gcc

INSTALLDIR = $(CROSS_INSTALL_DIR)
INSTALLFILE = $(APP)

EXTRA_LDFLAGS = -nodefaultlibs -g3 -dynamic -L$(CROSS_STAGING_DIR)/$(CROSS_GCC) -lgcc_s -lpthread

else
INSTALLDIR = ./
INSTALLFILE = ./$(APP)

CC = gcc

endif

CFLAGS = `pkg-config --cflags $(PKGS)` -g -Wall $(EXTRA_CC_FLAGS)
LDFLAGS = `pkg-config --libs $(PKGS)` $(EXTRA_LDFLAGS)

RAUMFELD_DATA_DIR = `pkg-config --variable=raumfelddatadir raumfeld-1.0`

PKGS = raumfeld-1.0 gstreamer-0.10 alsa flac liboil-0.3 dbus-glib-1

CPPFLAGS = -DRAUMFELD_DATA_DIR=\"$(RAUMFELD_DATA_DIR)\"


all: $(OBJDIR)/$(APP) $(INSTALLFILE)

$(INSTALLFILE): $(OBJDIR)/$(APP)
	mkdir -p $(INSTALLDIR)
	cp -av $(OBJDIR)/$(APP) $(INSTALLDIR)

ifeq ($(CROSS),ARM)	
	cp -uavr ./xml $(INSTALLDIR)
endif

$(OBJDIR)/$(APP): $(common_OBJS)
	$(CC) $(LDFLAGS) $(common_OBJS)  $(LIBS) -o $@


GLIB_GENMARSHAL = glib-genmarshal

p0-marshal.h: p0-marshal.list
	$(GLIB_GENMARSHAL) --prefix=p0_marshal p0-marshal.list --header >> xgen-gmh \
	&& (cmp -s xgen-gmh $(@F) || cp xgen-gmh $(@F)) \
	&& rm -f xgen-gmh xgen-gmh~

p0-marshal.c: p0-marshal.h
	echo "#include \"p0-marshal.h\"" >> xgen-gmc \
	&& $(GLIB_GENMARSHAL) --prefix=p0_marshal p0-marshal.list --body >> xgen-gmc \
	&& cp xgen-gmc $(@F) \
	&& rm -f xgen-gmc xgen-gmc~


DBUS_BINDING_TOOL = dbus-binding-tool

p0-dbus-service.c: p0-dbus-service-glue.h

p0-dbus-service-glue.h: p0-dbus-service.xml
	$(DBUS_BINDING_TOOL) --mode=glib-server --prefix=p0 $< > $(@F)


$(OBJDIR)/%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CPPFLAGS) $(CFLAGS)


clean:
	rm -f $(common_OBJS)
	rm -f $(OBJDIR)/$(APP)

