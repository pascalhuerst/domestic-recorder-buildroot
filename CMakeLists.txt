# Top level build logic for Raumfeld firmware builds.

# This replaces the older `build.sh` script.

cmake_minimum_required(VERSION 3.2)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

set(RAUMFELD_VERSION)

if(NOT RAUMFELD_VERSION)
    # We expect the caller to define this with -DRAUMFELD_VERSION.
    message(WARNING "RAUMFELD_VERSION not defined, defaulting to version 0.0")
    set(RAUMFELD_VERSION 0.0)
endif()

include("CMakeParseArguments")
include("Buildroot")
include("Raumfeld")

set(version ${RAUMFELD_VERSION})
raumfeld_set_version_in_rootfs(${version})

######################
## Top level targets
##

add_custom_target(all-arm ALL
    DEPENDS audioadapter-arm remotecontrol-arm)

add_custom_target(all-armada ALL
    DEPENDS audioadapter-armada base-armada)

add_custom_target(all-geode ALL
    DEPENDS base-geode)


#################
## 'arm' target
##

add_custom_target(audioadapter-arm
    DEPENDS images-audioadapter-arm binaries/updates-audioadapter-arm-${version}.tar)

add_custom_target(remotecontrol-arm
    DEPENDS images-remotecontrol-arm binaries/updates-remotecontrol-arm-${version}.tar)

buildroot_toolchain(
    buildroot-toolchain-arm
        CONFIG raumfeld/br2-toolchain-arm.config
)

buildroot_target(
    buildroot-initramfs-arm
        CONFIG raumfeld/br2-initramfs-arm.config
        OUTPUT images/uImage
        TOOLCHAIN buildroot-toolchain-arm
)

buildroot_target(
    buildroot-imgrootfs-arm
        CONFIG raumfeld/br2-imgrootfs-arm.config
        OUTPUT images/rootfs.ext2
        TOOLCHAIN buildroot-toolchain-arm
)

buildroot_target(
    buildroot-audioadapter-arm
        CONFIG raumfeld/br2-audioadapter-arm.config
        OUTPUT images/rootfs.tar.gz
        TOOLCHAIN buildroot-toolchain-arm
)

set(audioadapter_arm_image_types flash repair)
foreach(type ${audioadapter_arm_image_types})
    raumfeld_image_target(
        binaries/audioadapter-arm-${type}-${version}.img
            TARGET_TYPE audioadapter-arm-${type}

            KERNEL buildroot-initramfs-arm
            IMGROOTFS buildroot-imgrootfs-arm
            ROOTFS buildroot-audioadapter-arm
    )
endforeach()

add_custom_target(
    images-audioadapter-arm
    DEPENDS
        binaries/audioadapter-arm-flash-${version}.img
        binaries/audioadapter-arm-repair-${version}.img
)

# Raumfeld Connector, Raumfeld Stereo S, Raumfeld Stereo M, Raumfeld Stereo L,
# Raumfeld One M
set(audioadapter_arm_hardware_ids 3 4 6 7 8)

raumfeld_updates_target(
    binaries/updates-audioadapter-arm-${version}.tar
        TARGET_TYPE audioadapter-arm
        HARDWARE_IDS ${audioadapter_arm_hardware_ids}

        KERNEL buildroot-initramfs-arm
        ROOTFS buildroot-audioadapter-arm
)

buildroot_target(
    buildroot-remotecontrol-arm
        CONFIG raumfeld/br2-remotecontrol-arm.config
        OUTPUT images/rootfs.tar.gz
        TOOLCHAIN buildroot-toolchain-arm
)

raumfeld_image_target(
    binaries/remotecontrol-arm-flash-${version}.img
        TARGET_TYPE remotecontrol-arm-flash

        KERNEL buildroot-initramfs-arm
        IMGROOTFS buildroot-imgrootfs-arm
        ROOTFS buildroot-remotecontrol-arm
)

add_custom_target(
    images-remotecontrol-arm
    DEPENDS
        binaries/remotecontrol-arm-flash-${version}.img
)

# Raumfeld Controller
set(remotecontrol_arm_hardware_id 2)

raumfeld_updates_target(
    binaries/updates-remotecontrol-arm-${version}.tar
        TARGET_TYPE remotecontrol-arm
        HARDWARE_IDS ${remotecontrol_arm_hardware_id}

        KERNEL buildroot-initramfs-arm
        ROOTFS buildroot-remotecontrol-arm
)

####################
## 'armada' target
##

add_custom_target(audioadapter-armada
    DEPENDS images-audioadapter-armada binaries/updates-audioadapter-armada-${version}.tar)

add_custom_target(base-armada
    DEPENDS images-base-armada binaries/updates-base-armada-${version}.tar)

buildroot_toolchain(
    buildroot-toolchain-armada
        CONFIG raumfeld/br2-toolchain-armada.config
)

buildroot_target(
    buildroot-initramfs-armada
        CONFIG raumfeld/br2-initramfs-armada.config
        OUTPUT images/uImage
        TOOLCHAIN buildroot-toolchain-armada
)

buildroot_target(
    buildroot-imgrootfs-armada
        CONFIG raumfeld/br2-imgrootfs-armada.config
        OUTPUT images/rootfs.ext2
        TOOLCHAIN buildroot-toolchain-armada
)

buildroot_target(
    buildroot-audioadapter-armada
        CONFIG raumfeld/br2-audioadapter-armada.config
        OUTPUT
            images/rootfs.tar.gz
            images/dts.cramfs
            # Also, lots of other files in images/dts/ which we ignore here...
        TOOLCHAIN buildroot-toolchain-armada
)
get_target_property(buildroot_audioadapter_armada_build_dir buildroot-audioadapter-armada BUILDROOT_BUILD_DIR)
set_target_properties(buildroot-audioadapter-armada PROPERTIES
    RAUMFELD_DEVICE_TREE_DIR ${buildroot_audioadapter_armada_build_dir}/images)

set(audioadapter_armada_image_types final flash repair)
foreach(type ${audioadapter_armada_image_types})
    raumfeld_image_target(
        binaries/audioadapter-armada-${type}-${version}.img
        TARGET_TYPE audioadapter-armada-${type}

        KERNEL buildroot-initramfs-armada
        IMGROOTFS buildroot-imgrootfs-armada
        ROOTFS buildroot-audioadapter-armada
        DEVICE_TREE buildroot-audioadapter-armada
    )
endforeach()

add_custom_target(
    images-audioadapter-armada
    DEPENDS
        binaries/audioadapter-armada-final-${version}.img
        binaries/audioadapter-armada-flash-${version}.img
        binaries/audioadapter-armada-repair-${version}.img
)

# Raumfeld Connector 2, Raumfeld Stereo Cubes, Raumfeld One M 2, Raumfeld
# Stereo L 2, Raumfeld One S, Raumfeld Stereo M 2, Raumfeld Expand 2, Raumfeld
# Soundbar, Raumfeld Sounddeck
set(audioadapter_armada_hardware_ids 9 10 11 12 13 14 16 17)

raumfeld_updates_target(
    binaries/updates-audioadapter-armada-${version}.tar
        TARGET_TYPE audioadapter-armada
        HARDWARE_IDS ${audioadapter_armada_hardware_ids}

        KERNEL buildroot-initramfs-armada
        ROOTFS buildroot-audioadapter-armada
        DEVICE_TREE buildroot-audioadapter-armada
)

buildroot_target(
    buildroot-base-armada
        CONFIG raumfeld/br2-base-armada.config
        OUTPUT
            images/rootfs.tar.gz
            images/dts.cramfs
            # Also, lots of other files in images/dts/ which we ignore here...
        TOOLCHAIN buildroot-toolchain-armada
)
get_target_property(buildroot_base_armada_build_dir buildroot-base-armada BUILDROOT_BUILD_DIR)
set_target_properties(buildroot-base-armada PROPERTIES
    RAUMFELD_DEVICE_TREE_DIR ${buildroot_base_armada_build_dir}/images)

set(base_armada_image_types final flash repair)
foreach(type ${base_armada_image_types})
    raumfeld_image_target(
        binaries/base-armada-${type}-${version}.img
            TARGET_TYPE base-armada-${type}

            KERNEL buildroot-initramfs-armada
            IMGROOTFS buildroot-imgrootfs-armada
            ROOTFS buildroot-base-armada
            DEVICE_TREE buildroot-base-armada
    )
endforeach()

add_custom_target(
    images-base-armada
    DEPENDS
        binaries/base-armada-final-${version}.img
        binaries/base-armada-flash-${version}.img
        binaries/base-armada-repair-${version}.img
)

# Raumfeld Expand 2
set(base_armada_hardware_id 15)

raumfeld_updates_target(
    binaries/updates-base-armada-${version}.tar
        TARGET_TYPE base-armada
        HARDWARE_IDS ${base_armada_hardware_id}

        KERNEL buildroot-initramfs-armada
        ROOTFS buildroot-base-armada
        DEVICE_TREE buildroot-base-armada
)

###################
## 'geode' target
##

add_custom_target(base-geode
    DEPENDS images-base-geode binaries/updates-base-geode-${version}.tar)

buildroot_toolchain(
    buildroot-toolchain-geode
        CONFIG raumfeld/br2-toolchain-geode.config
)

buildroot_target(
    buildroot-initramfs-geode
        CONFIG raumfeld/br2-initramfs-geode.config
        OUTPUT images/bzImage
        TOOLCHAIN buildroot-toolchain-geode
)

buildroot_target(
    buildroot-imgrootfs-geode
        CONFIG raumfeld/br2-imgrootfs-geode.config
        OUTPUT images/rootfs.ext2
        TOOLCHAIN buildroot-toolchain-geode
)

buildroot_target(
    buildroot-base-geode
        CONFIG raumfeld/br2-base-geode.config
        OUTPUT images/rootfs.tar.gz
        TOOLCHAIN buildroot-toolchain-geode
)

set(base_geode_image_types flash repair)
foreach(type ${base_geode_image_types})
    raumfeld_image_target(
        binaries/base-geode-${type}-${version}.img
            TARGET_TYPE base-geode-${type}

            KERNEL buildroot-initramfs-geode
            IMGROOTFS buildroot-imgrootfs-geode
            ROOTFS buildroot-base-geode
    )
endforeach()

add_custom_target(
    images-base-geode
    DEPENDS
        binaries/base-geode-flash-${version}.img
        binaries/base-geode-repair-${version}.img
)

# Raumfeld Expand
set(base_geode_hardware_id 5)

raumfeld_updates_target(
    binaries/updates-base-geode-${version}.tar
        TARGET_TYPE base-geode
        HARDWARE_IDS ${base_geode_hardware_id}

        KERNEL buildroot-initramfs-geode
        ROOTFS buildroot-base-geode
)


# Wrapper for the Buildroot 'raumfeld-dirclean' targets. These are used to
# update and rebuild the modules from core. This 'raumfeld-dirclean' target
# should no longer be needed when we split the core.git modules out of the
# Buildroot build process.

add_custom_target(raumfeld-dirclean)

set(targets_building_core
    buildroot-initramfs-arm
    buildroot-imgrootfs-arm
    buildroot-audioadapter-arm
    buildroot-remotecontrol-arm
    buildroot-initramfs-armada
    buildroot-imgrootfs-armada
    buildroot-audioadapter-armada
    buildroot-base-armada
    buildroot-initramfs-geode
    buildroot-imgrootfs-geode
    buildroot-base-geode)

foreach(target ${targets_building_core})
    get_target_property(build_dir ${target} BUILDROOT_BUILD_DIR)
    get_target_property(build_output ${target} BUILDROOT_OUTPUT)
    add_custom_target(${target}-raumfeld-dirclean
        COMMAND
            [ -e ${build_dir}/Makefile ] && make O=${build_dir} raumfeld-dirclean || true
        COMMAND
            rm --force ${build_output}
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_SOURCE_DIR}
        VERBATIM
    )
    add_dependencies(raumfeld-dirclean ${target}-raumfeld-dirclean)
endforeach()
