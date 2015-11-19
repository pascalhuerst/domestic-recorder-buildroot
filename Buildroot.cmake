#.rst:
# Buildroot.cmake
# ---------------
#
# Wraps the Buildroot build system inside a CMake build system.
#
# This may be useful if you have multiple Buildroot builds which depend on each
# other, and you want to drive them from one place.
#
# It provides two commands: buildroot_target and buildroot_toolchain. See below
# for documentation.
#
# This module only works when used in a CMakeLists.txt that is in the top
# directory of a Buildroot source tree.

if(("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}") AND
    ("${CMAKE_GENERATOR}" STREQUAL "Unix Makefiles"))
    message(FATAL_ERROR "Please run CMake with a work directory that is not "
                        "the top of the repo. Otherwise, the generated "
                        "Makefile will overwrite Buildroot's Makefile.")
endif()


# ::
#
#     buildroot_target(<name>
#                      CONFIG <buildroot_config_file>
#                      OUTPUT <output_files>
#                      [TOOLCHAIN <buildroot_target_name>])
#
# Creates a target called <name> which runs a Buildroot build of the
# given config file.
#
# This function expects to be called from a CMakeLists.txt file that is in the
# top level of a Buildroot repository.
#
# The build is run in a subdirectory of the current binary directory, named
# "${name}". This means you can add multiple different buildroot targets.
# It does not clean this directory before running the build, you should do this
# yourself if you want a clean build -- there is a ${name}-clean target created
# which you can use for that.
#
# The output of the 'make' command is written to a .log file in the build
# directory, named for the target. This is a convenience for debugging
# errors in the individual Buildroot builds.
#
# This expects `support/scripts/config` to be available. It's available as
# scripts/config in the Linux source tree, but Buildroot doesn't seem to ship
# it by default.
#
# If TOOLCHAIN is specified, the BR2_TOOLCHAIN_EXTERNAL config flag must be
# enabled in buildroot_config_file, along with
# BR2_TOOLCHAIN_EXTERNAL_PREINSTALLED=y and BR2_TOOLCHAIN_EXTERNAL_CUSTOM=y.
# The BR2_TOOLCHAIN_PATH will be updated to point to the host/usr/bin directory
# in the build output of buildroot_target_name.
#
# The target that is created does not get added to the ALL target, won't be
# built by default. If you need that, do something like this (assuming you called
# buildroot_target() with name'foo'):
#
#   add_custom_target(all-foo ALL DEPENDS foo)
#
function(buildroot_target name)
    # The undocumented MAKE_TARGET option is used by buildroot_toolchain()
    # internally.

    set(one_value_keywords CONFIG TOOLCHAIN)
    set(multi_value_keywords OUTPUT)
    cmake_parse_arguments(BR "" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN})

    if(BR_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unparsed arguments to buildroot_target: ${BR_UNPARSED_ARGUMENTS}")
    endif()

    # Sets build_dir, buildroot_download_dir, config_commands
    _buildroot_common_setup(${name})

    set(output_files)
    foreach(output ${BR_OUTPUT})
        list(APPEND output_files ${build_dir}/${output})
    endforeach()
    list(GET output_files 0 first_output_file)

    if(BR_TOOLCHAIN)
        # External toolchain configuration
        get_target_property(toolchain_path ${BR_TOOLCHAIN} BUILDROOT_HOST_TOOLS_PREFIX)
        list(APPEND config_commands --set-str BR2_TOOLCHAIN_EXTERNAL_PATH ${toolchain_path})
        set(toolchain_depends ${BR_TOOLCHAIN})
    endif()

    _buildroot_prepare_config(${build_dir} ${BR_CONFIG} ${config_commands})

    _buildroot_make(all ${name} ${build_dir} "${output_files}" "" "${toolchain_depends}"
                    "Building Buildroot config ${BR_CONFIG} to produce ${first_output_file}")

    # Actual target
    add_custom_target(${name}
        DEPENDS ${output_files}
        SOURCES ${BR_CONFIG}
    )

    set_target_properties(${name} PROPERTIES
        BUILDROOT_BUILD_DIR
            ${build_dir}
        BUILDROOT_OUTPUT
            ${first_output_file}
        BUILDROOT_HOST_TOOLS_PREFIX
            ${build_dir}/host/usr
    )

    _buildroot_clean_target(${name} ${build_dir})
endfunction()

# ::
#
#     buildroot_toolchain(<name>
#                         CONFIG <buildroot_config_file)
#
# Creates a target called <name> which builds a Buildroot toolchain using the
# given config file.
#
# See the generic buildroot_target() for more information on wrapping Buildroot
# with CMake.
#
function(buildroot_toolchain name)
    set(one_value_keywords CONFIG)
    cmake_parse_arguments(BR_TOOLCHAIN "" "${one_value_keywords}" "" ${ARGN})

    if(BR_TOOLCHAIN_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unparsed arguments to buildroot_toolchain: ${BR_TOOLCHAIN_UNPARSED_ARGUMENTS}")
    endif()

    # Sets build_dir, buildroot_download_dir, config_commands
    _buildroot_common_setup(${name})

    # Config preparation. This uses scripts/config from the Linux source tree.
    _buildroot_prepare_config(${build_dir} ${BR_TOOLCHAIN_CONFIG} ${config_commands})

    # Toolchain builds don't have a single output file that we can watch. It's
    # actually important to not specify files from inside host/usr/ as outputs,
    # because Make will delete those files if something goes wrong, but
    # Buildroot doesn't track all the files it creates, so that file will then
    # just be gone forever and you will be confused and your build will be
    # broken.
    #
    # Instead, we run 'make toolchain' unconditionally, but we also create a
    # tar.gz of the build output (anticipating the implementation of artifact
    # sharing!), and the actual ${name} target depends on that artifact. This
    # saves us rerunning 'make' all the time, which is good because 'make' in
    # the Buildroot repo is pretty slow.
    set(outputs "")
    set(check_files ${build_dir}/host/usr/libexec/gcc)
    set(extra_depends "")

    _buildroot_make(toolchain ${name} ${build_dir} "${outputs}" "${check_files}" "${extra_depends}"
                    "Building Buildroot toolchain from config ${BR_TOOLCHAIN_CONFIG}")

    # Now create an artifact ...
    set(toolchain_artifact ${CMAKE_CURRENT_BINARY_DIR}/${name}.tar.gz)
    add_custom_command(
        OUTPUT ${toolchain_artifact}
        COMMAND
            tar -c -z -f ${toolchain_artifact} .
        WORKING_DIRECTORY
            ${build_dir}/host
        DEPENDS
            ${CMAKE_CURRENT_BINARY_DIR}/${name}.stamp
        VERBATIM
    )

    # Actual target
    add_custom_target(${name}
        DEPENDS ${toolchain_artifact}
        SOURCES ${BR_TOOLCHAIN_CONFIG}
    )

    set_target_properties(${name} PROPERTIES
        BUILDROOT_OUTPUT ${toolchain_artifact}
        BUILDROOT_HOST_TOOLS_PREFIX ${build_dir}/host/usr
    )

    _buildroot_clean_target(${name} ${build_dir})
endfunction()

## ::
##
## Properties set by this module

define_property(TARGET PROPERTY "BUILDROOT_BUILD_DIR"
    BRIEF_DOCS "Path to the directory that contains all Buildroot build output for this build."
    FULL_DOCS "x"
    )

define_property(TARGET PROPERTY "BUILDROOT_HOST_TOOLS_PREFIX"
    BRIEF_DOCS "Path to host tools prefix (/usr) within the Buildroot build output"
    FULL_DOCS "x"
    )

define_property(TARGET PROPERTY "BUILDROOT_OUTPUT"
    BRIEF_DOCS "Path to the main output file product by this target."
    FULL_DOCS "x"
    )


## ::
##
## Internal helper functions and macros.

macro(_buildroot_common_setup target_name)
    # Set some variables used in buildroot_target() and buildroot_toolchain().

    set(build_dir ${CMAKE_CURRENT_BINARY_DIR}/${target_name})
    file(MAKE_DIRECTORY ${build_dir})

    # Buildroot downloads nearly 700MB of source code, it makes sense to share
    # this between each of the builds. We use the BR2_DL_DIR setting to do that.
    set(buildroot_download_dir ${CMAKE_CURRENT_BINARY_DIR}/dl)
    file(MAKE_DIRECTORY ${buildroot_download_dir})

    set(config_commands)

    # It's possible to set BR2_DL_DIR in the environment, but the value
    # from the .config file seems to override, which is a bit useless.
    list(APPEND config_commands --set-str BR2_DL_DIR ${buildroot_download_dir})
endmacro()

function(_buildroot_prepare_config build_dir input commands)
    # Config preparation. This uses scripts/config from the Linux source tree.
    add_custom_command(
        OUTPUT ${build_dir}/.config
        COMMAND
            cp ${input} ${build_dir}/.config
        COMMAND
            env CONFIG_=BR2_ support/scripts/config --file ${build_dir}/.config ${config_commands}
        DEPENDS ${input}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        VERBATIM
    )
endfunction()

function(_buildroot_make buildroot_target cmake_target_name build_dir outputs check_files extra_depends comment)
    set(build_log ${CMAKE_CURRENT_BINARY_DIR}/${cmake_target_name}.log)

    if(NOT outputs)
        # If there's no specific output that we can look for, create a stamp.
        set(stamp ${CMAKE_CURRENT_BINARY_DIR}/${cmake_target_name}.stamp)
        set(stamp_command COMMAND date > ${stamp})
        set(outputs ${stamp})
    else()
        set(stamp_command)
    endif()

    add_custom_command(
        OUTPUT ${outputs}
        COMMAND
            support/scripts/buildroot-make-wrapper ${build_dir} ${buildroot_target} ${build_log}

        ${stamp_command}

        # Sanity check -- CMake itself doesn't seem to generate rules that would
        # check if the command actually creates the output that it's meant to.
        COMMAND
            support/scripts/check-target-created-files ${name} ${outputs} ${check_files}

        WORKING_DIRECTORY
            ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS
            ${build_dir}/.config ${extra_depends}
        COMMENT ${comment}
        VERBATIM
    )
endfunction()

function(_buildroot_clean_target name build_dir)
    add_custom_target(
        ${name}-clean
        COMMAND
            echo FIXME: I'm not actually doing the clean!!! (just for development)
            echo rm -Rf ${build_dir}
        VERBATIM
    )
endfunction()

