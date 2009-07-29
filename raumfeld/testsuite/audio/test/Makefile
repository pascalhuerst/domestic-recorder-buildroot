#CROSS=ARM

ifeq ($(CROSS),ARM)
OBJDIR = ./arm
else
OBJDIR = ./386
endif

APP=p0-audiotest

common_OBJS =   $(OBJDIR)/testmain.o \
		$(OBJDIR)/testplayback.o\
		$(OBJDIR)/testcapture.o\
		$(OBJDIR)/p0-alsa-tools.o\
		$(OBJDIR)/p0-dsp.o\
		$(OBJDIR)/p0-eq.o

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

EXTRA_LDFLAGS = -nodefaultlibs -g3 -dynamic -L$(CROSS_STAGING_DIR)/$(CROSS_GCC) -lgcc_s -lpthread  \
 -L$(CROSS_STAGING_DIR)lib\
 -L$(CROSS_STAGING_DIR)/usr/lib\ 

else
INSTALLDIR = ./
INSTALLFILE = ./$(APP)

CC = gcc
RAUMFELD_DATA_DIR = `pkg-config --variable=raumfelddatadir raumfeld-1.0`
endif

PKGS = raumfeld-1.0 alsa liboil-0.3

LDFLAGS = -lasound -loil-0.3 -lgobject-2.0 -lglib-2.0 -lgmodule-2.0 -lgthread-2.0 $(EXTRA_LDFLAGS)

CFLAGS = `pkg-config --cflags $(PKGS)` -g -Wall $(EXTRA_CC_FLAGS)

RAUMFELD_DATA_DIR = `pkg-config --variable=raumfelddatadir raumfeld-1.0`


CPPFLAGS = -DRAUMFELD_DATA_DIR=\"$(RAUMFELD_DATA_DIR)\"


all: $(OBJDIR)/$(APP) $(INSTALLFILE) 

$(INSTALLFILE): $(OBJDIR)/$(APP)
	mkdir -p $(INSTALLDIR)
	cp -av $(OBJDIR)/$(APP) $(INSTALLDIR)
ifdef  $CROSS
	cp -avr ./xml $(INSTALLDIR)
endif

$(OBJDIR)/$(APP): $(common_OBJS)
	$(CC) $(LDFLAGS) $(common_OBJS)  $(LIBS) -o $@


$(OBJDIR)/%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CPPFLAGS) $(CFLAGS)

$(OBJDIR)/%.o: ../%.c $(DEPS)
	$(CC) -c -o $@ $< $(CPPFLAGS) $(CFLAGS)

clean:
	rm -f $(common_OBJS)
	rm -f $(OBJDIR)/$(APP)