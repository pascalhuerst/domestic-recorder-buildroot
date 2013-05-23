
DTC=$(HOSTDIR)/usr/bin/dtc

TARGETS = \
	am33xx-raumfeld-connector-0-0.dtb	\
	am33xx-raumfeld-cube-0-0.dtb		\
	am33xx-raumfeld-one-0-0.dtb

all: clean $(TARGETS)

%.dtb: %.dts
	$(DTC) -o $(DESTDIR)$@ -O dtb $<

clean:
	@rm -f $(TARGETS)

.PHONY: all clean
