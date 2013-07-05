#############################################################
#
# raumfeld-extract
#
#############################################################

RAUMFELD_EXTRACT_MODULE = raumfeld-extract

RAUMFELD_EXTRACT_DEPENDENCIES = libarchive

$(eval $(raumfeld-autotools-package))
