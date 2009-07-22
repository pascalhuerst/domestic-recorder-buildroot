RM = rm -f
CC = $(CROSS)gcc
LD = $(CROSS)ld
INCLUDES = 
WARNS = -Werror-implicit-function-declaration
CFLAGS = -g -O0 -Wall -MD -D_REENTRANT $(WARNS) $(INCLUDES)
LDFLAGS = -g -dynamic -lgcc 

TARGETS = imginfo imgcreate

ifneq ($(CROSS),)
	CFLAGS += -I/home/daniel/src/buildroot-arm11/build_arm/root/usr/include/ \
		  -I/home/daniel/src/buildroot-arm11/build_arm/staging_dir/lib/gcc/arm-linux-uclibcgnueabi/4.1.2/include/ \
		  -I/home/daniel/src/buildroot-arm11/build_arm/staging_dir/include \
		  -nostdinc
	LDFLAGS += \
		   -L/home/daniel/src/buildroot-arm11/build_arm/root/lib \
		   -L/home/daniel/src/buildroot-arm11/build_arm/root/usr/lib \
		   -nodefaultlibs
else
endif

CFLAGS += -I.

OBJS = 	$(SUBDIR_OBJS)		\
	img.o			\
	sha256.o

all: $(TARGETS)

imginfo: imginfo.o $(OBJS)
	$(CC) $(LDFLAGS) $^ -o $@

imgcreate: imgcreate.o $(OBJS)
	$(CC) $(LDFLAGS) $^ -o $@

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@
	
clean::
	$(RM) $(TARGETS) *.o *.d core

-include $(wildcard *.d) dummy	

