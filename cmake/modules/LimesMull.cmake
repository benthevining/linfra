# ======================================================================================
#  __    ____  __  __  ____  ___
# (  )  (_  _)(  \/  )( ___)/ __)
#  )(__  _)(_  )    (  )__) \__ \
# (____)(____)(_/\/\_)(____)(___/
#
#  This file is part of the Limes open source library and is licensed under the terms of the GNU Public License.
#
#  Commercial licenses are available; contact the maintainers at ben.the.vining@gmail.com to inquire for details.
#
# ======================================================================================

#[=======================================================================[.rst:

LimesMull
------------------

This module provides utilities for setting up mutation testing using the Mull Clang compiler plugin.

Mull is only available when using Clang on MacOS or Linux, and only supports Clang versions 11-14.

This module creates an interface target called ``mull::flags``, which defines all necessary compiler flags
for using Mull. The :command:`mull_add_test` command links your target to ``mull::flags`` automatically.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: MULL_ENABLE

Boolean variable that indicates whether mutation testing using Mull is enabled. Off by default.

.. cmake:variable:: MULL_CONFIG_FILE

Path to a ``mull.yml`` configuration file to be used for running Mull tests. If you don't provide your own,
linfra will use a default one.

.. cmake:variable:: MULL_CLANG_VERSION

Major version of Clang being used. Mull only supports Clang versions 11-14. If this value is not explicitly
defined, it will be parsed from ``CMAKE_CXX_COMPILER_VERSION``.

.. cmake:variable:: MULL_PROGRAM

Path to the Mull runner executable.

.. cmake:variable:: MULL_PLUGIN

Path to the Mull compiler plugin binary.

#]=======================================================================]

include_guard (GLOBAL)

include (CMakeDependentOption)

set (mull_description
     "Enable mutation testing with mull. This is only supported on MacOS with Clang.")

cmake_dependent_option (MULL_ENABLE "${mull_description}" OFF
                        "APPLE;CMAKE_CXX_COMPILER_ID MATCHES \".*Clang\"" OFF)

if (MULL_ENABLE)
    __mull_internal_parse_clang_version ()
    __mull_internal_validate_clang_version ()

    if (MULL_ENABLE)
        __mull_internal_find_components ()

        if (MULL_ENABLE)
            add_library (mull_flags INTERFACE)
            add_library (mull::flags ALIAS mull_flags)

            target_compile_options (mull_flags INTERFACE -fexperimental-new-pass-manager
                                                         "-fpass-plugin=${MULL_PLUGIN}" -g)

            if ("${MULL_CLANG_VERSION}" EQUAL 11)
                target_compile_options (mull_flags INTERFACE -O1)
            endif ()
        endif ()
    endif ()
endif ()

set (MULL_CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/../mull.yml" CACHE FILEPATH "mull config file")

mark_as_advanced (MULL_ENABLE MULL_CONFIG_FILE)

if (NOT (MULL_ENABLE AND MULL_PROGRAM AND TARGET mull::flags))
    set (MULL_ENABLE OFF CACHE BOOL "${mull_description}" FORCE)
endif ()

#[=======================================================================[.rst:

Creating mutation tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. command:: mull_add_test

    ::

        mull_add_test (<executableTarget>
                       TEST_NAME <name>
                       REPORT_DIR <dir>)

Creates a test to execute ``<executableTarget>`` under the Mull runner. Calling this function
also links ``<executableTarget>`` to ``mull::flags``, to compile it using the Mull compiler plugin.

This function simply does nothing if Mull is unavailable or if ``MULL_ENABLE`` is off.

``<executableTarget>`` must be an existing executable target.

Options:

``TEST_NAME``
 Name of the test to create.

``REPORT_DIR``
 Directory in which to output textual reports from Mull.

TODO: passing additional arguments to executable?

#]=======================================================================]
function (mull_add_test executableTarget)

    if (NOT TARGET "${executableTarget}")
        message (
            FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target ${executableTarget} does not exist!")
    endif ()

    if (NOT MULL_ENABLE)
        return ()
    endif ()

    set (oneVal TEST_NAME REPORT_DIR)

    cmake_parse_arguments (LIMES "" "${oneVal}" "" ${ARGN})

    target_link_libraries ("${executableTarget}" PRIVATE mull::flags)

    add_test (NAME "${LIMES_TEST_NAME}"
              COMMAND "${MULL_PROGRAM}" --report-dir "${LIMES_REPORT_DIR}"
                      "$<TARGET_FILE:${executableTarget}>")

    set_property (TEST "${test_name}" APPEND PROPERTY ENVIRONMENT "MULL_CONFIG=${MULL_CONFIG_FILE}")
    set_property (TEST "${test_name}" APPEND PROPERTY LABELS Mutation)

    message (VERBOSE "Configured mull mutation tests for target ${executableTarget}")

endfunction ()

#

# parse the major version of Clang into MULL_CLANG_VERSION
function (__mull_internal_parse_clang_version)

    if (MULL_CLANG_VERSION)
        return ()
    endif ()

    if (NOT CMAKE_CXX_COMPILER_VERSION)
        message (
            WARNING
                "CMAKE_CXX_COMPILER_VERSION is not defined. To configure mull mutation testing, define either CMAKE_CXX_COMPILER_VERSION or MULL_CLANG_VERSION."
            )
        return ()
    endif ()

    string (FIND "${CMAKE_CXX_COMPILER_VERSION}" "." dot_idx)

    if ("${dot_idx}" EQUAL "-1")
        string (LENGTH "${CMAKE_CXX_COMPILER_VERSION}" version_string_length)

        if (NOT ("${version_string_length}" EQUAL 2))
            message (
                WARNING
                    "CMAKE_CXX_COMPILER_VERSION appears to be in an unknown format: '${CMAKE_CXX_COMPILER_VERSION}'. Please explicitly define MULL_CLANG_VERSION to the major version of Clang being used."
                )
            unset (dot_idx)
            unset (version_string_length)
            return ()
        endif ()

        unset (version_string_length)

        set (clang_version_init "${CMAKE_CXX_COMPILER_VERSION}")
    else ()
        string (SUBSTRING "${CMAKE_CXX_COMPILER_VERSION}" 0 "${dot_idx}" clang_version_init)
    endif ()

    unset (dot_idx)

    set (MULL_CLANG_VERSION "${clang_version_init}" CACHE STRING
                                                          "Major version of Clang being used")

    mark_as_advanced (MULL_CLANG_VERSION)

    unset (clang_version_init)

    message (VERBOSE "mull - clang version: ${MULL_CLANG_VERSION}")
    message (CONFIGURE_LOG "mull - clang version: ${MULL_CLANG_VERSION}")

endfunction ()

# sets MULL_ENABLE to off in the parent scope if detected clang version is invalid
function (__mull_internal_validate_clang_version)

    if (NOT MULL_CLANG_VERSION)
        set (MULL_ENABLE OFF PARENT_SCOPE)
        return ()
    endif ()

    if (NOT ("${MULL_CLANG_VERSION}" GREATER_EQUAL 11 AND "${MULL_CLANG_VERSION}" LESS_EQUAL 14))
        message (
            WARNING
                "mull only supports Clang versions 11, 12, 13, and 14. Incompatible Clang version detected: ${MULL_CLANG_VERSION}"
            )
        set (MULL_ENABLE OFF PARENT_SCOPE)
    endif ()

endfunction ()

# searches for mull frontend runner and compiler plugin, and sets MULL_ENABLE to off in the parent
# scope if not found
function (__mull_internal_find_components)

    # frontend runner
    set (mull_program_name "mull-runner-${MULL_CLANG_VERSION}")

    find_program (MULL_PROGRAM "${mull_program_name}" DOC "mull frontend executable")

    # compiler plugin
    set (mull_plugin_name "mull-ir-frontend-${MULL_CLANG_VERSION}")

    find_file (MULL_PLUGIN NAMES "/usr/local/lib/${mull_plugin_name}" "~/lib/${mull_plugin_name}"
               DOC "Path to the mull compiler plugin binary")

    mark_as_advanced (MULL_PROGRAM MULL_PLUGIN)

    if (NOT (MULL_PROGRAM AND MULL_PLUGIN))
        set (MULL_ENABLE OFF PARENT_SCOPE)
    endif ()

endfunction ()
