#############################################################
#
# orc
#
#############################################################
ORC_VERSION = 0.4.14
ORC_SOURCE = orc-$(ORC_VERSION).tar.gz
ORC_SITE = http://code.entropywave.com/download/orc/
ORC_AUTORECONF = YES
ORC_INSTALL_STAGING = YES

$(eval $(call AUTOTARGETS,package,orc))
$(eval $(call AUTOTARGETS,package,orc,host))
