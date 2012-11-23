
DTC=$(HOST_DIR)/usr/bin/dtc
MKCRAMFS=${HOST_DIR}/usr/bin/mkcramfs

TARGETS = am33xx-raumfeld-connector-0-0.dtb

all: clean $(TARGETS)

%.dtb: %.dts
	$(DTC) -o $(DESTDIR)$@ -O dtb $<

clean:
	@rm -f $(TARGETS)

.PHONY: all clean
