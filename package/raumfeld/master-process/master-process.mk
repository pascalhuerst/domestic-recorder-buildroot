#############################################################
#
# master-process
#
#############################################################

MASTER_PROCESS_DEPENDENCIES = host-pkgconf host-libglib2 libraumfeld

$(eval $(raumfeld-cross-package))
