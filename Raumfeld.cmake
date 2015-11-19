include("CMakeParseArguments")

add_subdirectory("raumfeld/imgtool")

set(raumfeld_imgcreate ${CMAKE_CURRENT_BINARY_DIR}/raumfeld/imgtool/imgcreate)
set(raumfeld_imginfo ${CMAKE_CURRENT_BINARY_DIR}/raumfeld/imgtool/imginfo)

# ::
#
#    raumfeld_set_version_in_rootfs(<version>)
#
# Sets the version number that is embedded in the rootfs. This is written
# to the file `raumfeld/rootfs/etc/raumfeld-version`.
#
# FIXME: currently the filesystems built by Buildroot will not be rebuilt
# when the version number is changed. You need to manually delete the
# generated rootfs files and rerun 'make' when changing the version number
# file.

set(RAUMFELD_VERSION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/raumfeld/rootfs/etc/raumfeld-version)

function(raumfeld_set_version_in_rootfs version)
    get_filename_component(dir ${RAUMFELD_VERSION_FILE} DIRECTORY)
    file(MAKE_DIRECTORY ${dir})

    # Instead of creating the file directly, we use configure_file() so that
    # if something changes ${version_file} manually, CMake will rerun next time
    # 'make' is run.
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/version.in ${version})
    configure_file(
        ${CMAKE_CURRENT_BINARY_DIR}/version.in
        ${RAUMFELD_VERSION_FILE}
    )
endfunction()

# ::
#
#    raumfeld_image_target(<filename>
#                          TARGET_TYPE <type>
#                          KERNEL <buildroot_target>
#                          IMGROOTFS <buildroot_target>
#                          ROOTFS <buildroot_target>
#                          [DEVICE_TREE <buildroot_target>])
#
# Creates a single image suitable for flashing a Raumfeld device.
#
# The TARGET_TYPE keyword is a Raumfeld-specific keyword understood by the
# raumfeld/imgcreate.sh program. See that program for more details.
#
# The KERNEL, IMGROOTFS and ROOTFS keywords should each name a target created
# with the buildroot_target() command, that build a suitable uImage,
# rootfs.ext2 and rootfs.tar.gz respectively.
#
# The DEVICE_TREE keyword is a bit special, because currently the raumfeld-dts
# package is built within another Buildroot target. Whatever target you pass
# needs to have the RAUMFELD_DEVICE_TREE_DIR target property set to point to
# the directory that conatins dts.cramfs and dts/*.dtb.
#
# Example:
#
#   raumfeld_image_target(binaries/audioadapter-armada-flash.img
#                         TARGET_TYPE audioadapter-armada-flash
#                         KERNEL buildroot-initramfs-armada
#                         IMGROOTFS buildroot-imgrootfs-armada
#                         ROOTFS buildroot-audioadapter-armada
#                         DEVICE_TREE buildroot-audioadapter-armada)
#
function(raumfeld_image_target filename)
    set(one_value_keywords DEVICE_TREE KERNEL IMGROOTFS ROOTFS TARGET_TYPE)
    cmake_parse_arguments(RAUMFELD "" "${one_value_keywords}" "" ${ARGN})

    if(RAUMFELD_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unparsed arguments to raumfeld_image_target: ${RAUMFELD_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT IS_ABSOLUTE ${filename})
        set(filename ${CMAKE_CURRENT_BINARY_DIR}/${filename})
    endif()

    set(extra_args)

    get_target_property(kernel_file ${RAUMFELD_KERNEL} BUILDROOT_OUTPUT)
    get_target_property(imgrootfs_file ${RAUMFELD_IMGROOTFS} BUILDROOT_OUTPUT)
    get_target_property(rootfs_file ${RAUMFELD_ROOTFS} BUILDROOT_OUTPUT)

    if(RAUMFELD_DEVICE_TREE)
        get_target_property(dts_directory ${RAUMFELD_DEVICE_TREE} RAUMFELD_DEVICE_TREE_DIR)
        if(NOT dts_directory)
            message(FATAL_ERROR "Target ${RAUMFELD_DEVICE_TREE} does not have RAUMFELD_DEVICE_TREE_DIR property set.")
        endif()
        list(APPEND extra_args --dts-dir=${dts_directory})
    endif()

    # This is a bit ugly -- we assume that the audioadapter/remotecontrol/base
    # images contain genext2fs (i.e. BR2_HOST_GENEXT2FS is enabled in the
    # config). Nicer than requiring it on the host, though, as it isn't
    # generally packaged anywhere.
    get_target_property(host_tools_prefix ${RAUMFELD_ROOTFS} BUILDROOT_HOST_TOOLS_PREFIX)
    set(genext2fs ${host_tools_prefix}/bin/genext2fs)

    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/binaries)

    add_custom_command(
        OUTPUT
            ${filename}
        COMMAND
            env
                GENEXT2FS=${genext2fs}
                IMGCREATE=${raumfeld_imgcreate}
                IMGINFO=${raumfeld_imginfo}
            ${CMAKE_CURRENT_SOURCE_DIR}/raumfeld/imgcreate.sh
                --output-file=${filename}
                --target=${RAUMFELD_TARGET_TYPE}
                --kernel=${kernel_file}
                --base-rootfs-img=${imgrootfs_file}
                --target-rootfs-tgz=${rootfs_file}
                --download-dir=${CMAKE_CURRENT_BINARY_DIR}/dl
                ${extra_args}
        DEPENDS
            # We must depend on all files AND all targets here.
            #
            # If we don't depend on the targets, and parallel Make is used,
            # each Buildroot build will be started multiple times in parallel,
            # causing disaster. See: https://cmake.org/Bug/view.php?id=10082
            #
            # File level dependencies of custom targets are not propagated
            # automatically, so we need to manually list the files here as well.
            # Otherwise, changes/rebuilds in the Buildroot output files
            # wouldn't cause the images to be rebuilt.
            #
            ${RAUMFELD_KERNEL} ${kernel_file}
            ${RAUMFELD_IMGROOTFS} ${imgrootfs_file}
            ${RAUMFELD_ROOTFS} ${rootfs_file}
            # FIXME: we don't know the names of the device tree files,
            # so can't list them here.
            ${RAUMFELD_DEVICE_TREE}

            # These are "normal" targets (not custom targets) so we can depend
            # on them in the usual way.
            ${raumfeld_imgcreate}
            ${raumfeld_imginfo}
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_SOURCE_DIR}
    )
endfunction()

# ::
#
#   raumfeld_updates_target(<filename>
#                           TARGET_TYPE <type>
#                           HARDWARE_IDS <id> [<id> ...]
#                           KERNEL <buildroot_target>
#                           ROOTFS <buildroot_target>
#                           [DEVICE_TREE <buildroot_target>])
#
# Create a tar archive of update images for a set of Raumfeld devices.
#
# The TARGET_TYPE keyword is a Raumfeld-specific keyword understood by the
# raumfeld/updatecreate.sh program. See that program for more details.
#
# One Raumfeld target can be used in more than one Raumfeld device. An update
# image and associated metadata file will be produced for each device ID listed
# in HARDWARE_IDS. The list of IDs is maintained in raumfeld/updatecreate.sh
# and (in core.git) libraumfeld/raumfeld/platform.h.
#
# The KERNEL, IMGROOTFS and ROOTFS keywords should each name a target created
# with the buildroot_target() command, that build a suitable uImage,
# rootfs.ext2 and rootfs.tar.gz respectively.
#
# The DEVICE_TREE keyword is a bit special, because currently the raumfeld-dts
# package is built within another Buildroot target. Whatever target you pass
# needs to have the RAUMFELD_DEVICE_TREE_DIR target property set to point to
# the directory that conatins dts.cramfs and dts/*.dtb.
#
# Example:
#
#   raumfeld_update_target(
#       binaries/updates-audioadapter-armada-${version}.tar
#           TARGET_TYPE audioadapter-armada
#           HARDWARE_IDS 9 10 11 12 13 14 16 17
#
#           KERNEL buildroot-initramfs-armada
#           ROOTFS buildroot-audioadapter-armada
#           DEVICE_TREE buildroot-audioadapter-armada
#   )
#
# This is an example of the file listing inside the generated tar archive:
#
#   10.updates
#   11.updates
#   12.updates
#   13.updates
#   14.updates
#   16.updates
#   17.updates
#   732c99f090468808d60d82a3229f3e504016c52bc5092468721953c7d740b5e5
#   732c99f090468808d60d82a3229f3e504016c52bc5092468721953c7d740b5e5.sign
#   9.updates
function(raumfeld_updates_target filename)
    set(one_value_keywords DEVICE_TREE KERNEL ROOTFS TARGET_TYPE)
    set(multi_value_keywords HARDWARE_IDS)
    cmake_parse_arguments(RAUMFELD "" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN})

    if(RAUMFELD_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unparsed arguments to raumfeld_updates_target: ${RAUMFELD_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT RAUMFELD_KERNEL OR NOT RAUMFELD_ROOTFS)
        message(FATAL_ERROR "Required arguments to raumfeld_updates_target not all set.")
    endif()

    if(NOT IS_ABSOLUTE ${filename})
        set(filename ${CMAKE_CURRENT_BINARY_DIR}/${filename})
    endif()

    set(extra_args)

    get_target_property(kernel_file ${RAUMFELD_KERNEL} BUILDROOT_OUTPUT)
    get_target_property(rootfs_file ${RAUMFELD_ROOTFS} BUILDROOT_OUTPUT)

    if(RAUMFELD_DEVICE_TREE)
        get_target_property(dts_directory ${RAUMFELD_DEVICE_TREE} RAUMFELD_DEVICE_TREE_DIR)
        if(NOT dts_directory)
            message(FATAL_ERROR "Target ${RAUMFELD_DEVICE_TREE} does not have RAUMFELD_DEVICE_TREE_DIR property set.")
        endif()
        list(APPEND extra_args --dts-dir=${dts_directory})
    endif()

    string(REPLACE ";" "," hardware_ids_comma_list "${RAUMFELD_HARDWARE_IDS}")

    # We assume that the rootfs build includes the Buildroot 'host-fakeroot'
    # package, which is required by updatecreate.sh.
    get_target_property(host_tools_prefix ${RAUMFELD_ROOTFS} BUILDROOT_HOST_TOOLS_PREFIX)

    add_custom_command(
        OUTPUT
            ${filename}
        COMMAND
            ${CMAKE_CURRENT_SOURCE_DIR}/raumfeld/updatecreate.sh
                --buildroot-host-tools-prefix=${host_tools_prefix}
                --output-file=${filename}
                --hardware-ids=${hardware_ids_comma_list}
                --target=${RAUMFELD_TARGET_TYPE}
                --targz=${rootfs_file}
                --kexec=${kernel_file}
                ${extra_args}
        DEPENDS
            # We must depend on all files AND all targets here.
            #
            # If we don't depend on the targets, and parallel Make is used,
            # each Buildroot build will be started multiple times in parallel,
            # causing disaster. See: https://cmake.org/Bug/view.php?id=10082
            #
            # File level dependencies of custom targets are not propagated
            # automatically, so we need to manually list the files here as well.
            # Otherwise, changes/rebuilds in the Buildroot output files
            # wouldn't cause the images to be rebuilt.
            #
            ${BUILDROOT_KERNEL} ${kernel_file}
            ${BUILDROOT_ROOTFS} ${rootfs_file}
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_SOURCE_DIR}
    )
endfunction()
