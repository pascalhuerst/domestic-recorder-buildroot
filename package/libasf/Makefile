
GCC ?= gcc
DESTDIR ?= /usr/local
PACKAGE_DIR ?= $(DESTDIR)

OBJDIR = obj

LIBNAME = libasf

HEADERS=\
	src/asf.h \
	src/asfint.h \
	src/byteio.h \
	src/compat.h \
	src/data.h \
	src/debug.h \
	src/guid.h \
	src/header.h \
	src/parse.h \
	src/utf.h

SRC =\
	src/asf.c \
	src/byteio.c \
	src/data.c \
	src/guid.c \
	src/header.c \
	src/parse.c

OBJS= $(patsubst %.c, $(OBJDIR)/%.o, $(SRC))

COMPILE_C = @echo "compiling $@";\
	$(GCC) -Isrc -c -MD -fPIC -o $@ $< $(CFLAGS);


.PHONY: libasf.pc

all: MKDIR $(LIBNAME)


$(LIBNAME): $(OBJS)
	@echo "link static library $@.a"
	@$(AR) crs $(OBJDIR)/$(LIBNAME).a $(OBJS)
	@echo "link shared library $@.so"
	@$(GCC) -fPIC -shared -o  $(OBJDIR)/$(LIBNAME).so $(OBJS)


$(OBJDIR)/%.o: %.c
	$(COMPILE_C)


MKDIR:
	@echo "Making directories..."
	@mkdir -p $(OBJDIR)/src


clean:
	rm -f $(OBJS)
	rm -f $(OBJDIR)/$(LIBNAME).a
	rm -rf $(OBJDIR)


libasf.pc: libasf.pc.in
	sed -e "s%@PREFIX@%$(PACKAGE_DIR)%" libasf.pc.in > $(OBJDIR)/libasf.pc


install: all libasf.pc
	mkdir -p $(DESTDIR)/usr/lib/
	mkdir -p $(DESTDIR)/usr/include/asf/
	mkdir -p $(DESTDIR)/usr/lib/pkgconfig/
	cp $(OBJDIR)/$(LIBNAME).a $(DESTDIR)/usr/lib/
	cp $(OBJDIR)/$(LIBNAME).so $(DESTDIR)/usr/lib/
	cp -r $(HEADERS) $(DESTDIR)/usr/include/asf/
	cp $(OBJDIR)/libasf.pc $(DESTDIR)/usr/lib/pkgconfig/


install-exec: all
	mkdir -p $(DESTDIR)/usr/lib/
	cp $(OBJDIR)/$(LIBNAME).so $(DESTDIR)/usr/lib/


