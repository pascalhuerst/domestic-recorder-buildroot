#############################################################
#
# master-process
#
#############################################################

MASTER_PROCESS_DEPENDENCIES = host-pkgconf host-libglib2 libraumfeldcpp

$(eval $(raumfeld-cross-package))
