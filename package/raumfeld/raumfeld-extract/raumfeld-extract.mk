#############################################################
#
# raumfeld-extract
#
#############################################################

RAUMFELD_EXTRACT_MODULE = raumfeld-extract

RAUMFELD_EXTRACT_DEPENDENCIES = host-pkgconf libarchive

$(eval $(raumfeld-autotools-package))
