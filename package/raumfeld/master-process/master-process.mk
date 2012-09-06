#############################################################
#
# master-process
#
#############################################################

MASTER_PROCESS_DEPENDENCIES = host-pkg-config host-libglib2 libraumfeld

$(eval $(raumfeld-cross-package))
