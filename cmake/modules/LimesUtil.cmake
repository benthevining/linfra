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

LimesUtil
------------------

This module provides some general utility functions.

#]=======================================================================]

include_guard (GLOBAL)

#[=======================================================================[.rst:

.. command:: limes_default_project_options

    ::

        limes_default_project_options()

This macro sets some recommended project-wide settings:

* Adds ``${PROJECT_NAME}`` to this directory's ``LABELS`` property
* If using Emscripten, adds options to enable C++ exceptions (for this directory and below)
* If ``PROJECT_IS_TOP_LEVEL`` and you're building for iOS, this macro sets the ``XCODE_EMIT_EFFECTIVE_PLATFORM_NAME`` global property to ``OFF``
* This macro sets ``CMAKE_CXX_VISIBILITY_PRESET`` to ``hidden`` and ``CMAKE_VISIBILITY_INLINES_HIDDEN`` to ``ON`` for this directory and below
* This macro disables Xcode code signing for this directory and below

This macro should be called in your top-level CMakeLists.txt. For example:

.. code:: cmake

    cmake_minimum_required (VERSION 3.25 FATAL_ERROR)

    project (Foo ...)

    add_subdirectory (linfra)

    limes_default_project_options()

#]=======================================================================]
macro (limes_default_project_options)

    set_property (DIRECTORY APPEND PROPERTY LABELS "${PROJECT_NAME}")

    set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_CLEAN_FILES "${CMAKE_CURRENT_LIST_DIR}/logs"
                                            "${CMAKE_CURRENT_LIST_DIR}/deploy")

    if (EMSCRIPTEN)
        add_compile_options (-sNO_DISABLE_EXCEPTION_CATCHING -fexceptions)
        add_link_options (-fexceptions)
    endif ()

    if (PROJECT_IS_TOP_LEVEL AND IOS)
        # iOS tests won't work if this property is ON
        set_property (GLOBAL PROPERTY XCODE_EMIT_EFFECTIVE_PLATFORM_NAME OFF)
    endif ()

    set (CMAKE_CXX_VISIBILITY_PRESET hidden)
    set (CMAKE_VISIBILITY_INLINES_HIDDEN ON)

    set (CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO")
    set (CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
    set (CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")

endmacro ()

#[=======================================================================[.rst:

.. command:: limes_copy_dlls

    ::

        limes_copy_dlls (<target>)

On Windows, adds a post-build step to copy the ``<target>`` 's runtime DLLs into the same directory as the
executable file that ``<target>`` will produce. This solves the infamous problem of Windows executables
failing to run due to being unable to locate the necessary DLLs. You should use this function with any test
executables that you will be running from the build tree (:command:`limes_configure_test_target` calls this
for you).

On all platforms, a fatal error is issued if ``<target>`` does not exist as a target.

#]=======================================================================]
function (limes_copy_dlls target)
    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target ${target} does not exist!")
    endif ()

    if (WIN32)
        add_custom_command (
            TARGET "${target}" POST_BUILD
            COMMAND "${CMAKE_COMMAND}" -E copy -t "$<TARGET_FILE_DIR:${target}>"
                    "$<TARGET_RUNTIME_DLLS:${target}>" USES_TERMINAL COMMAND_EXPAND_LISTS)
    endif ()
endfunction ()

#[=======================================================================[.rst:

.. command:: limes_configure_app_bundle

    ::

        limes_configure_app_bundle (<target>
                                    BUNDLE_ID <id>
                                    VERSION_MAJOR <majorVersion>
                                    FULL_VERSION <fullVersion>)

Configures ``<target>`` to be built as a ``.app`` bundle on MacOS. ``<target>`` should be an executable target.
This function configures some details for the generated plist, disables Xcode signing, and also calls
:command:`limes_copy_dlls` for you.

Options:

``BUNDLE_ID``
 Bundle identifier to use for the application.

``VERSION_MAJOR``
 Major version number of the application.

``FULL_VERSION``
 Full version string for the application.

On platforms like iOS and Android, only application bundles can be installed and run. This function is designed
to be used with test executables, to configure them to be runnable on the current platform's simulators, devices,
etc. :command:`limes_configure_test_target` calls this function internally.

#]=======================================================================]
function (limes_configure_app_bundle target)

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target ${target} does not exist!")
    endif ()

    set (oneVal BUNDLE_ID VERSION_MAJOR FULL_VERSION)

    cmake_parse_arguments (LIMES "" "${oneVal}" "" ${ARGN})

    if (NOT LIMES_BUNDLE_ID)
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - argument BUNDLE_ID is required!")
    endif ()

    if (NOT LIMES_VERSION_MAJOR AND NOT LIMES_VERSION_MAJOR EQUAL 0)
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - argument VERSION_MAJOR is required!")
    endif ()

    if (NOT LIMES_FULL_VERSION)
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - argument FULL_VERSION is required!")
    endif ()

    if (LIMES_UNPARSED_ARGUMENTS)
        message (
            AUTHOR_WARNING
                "${CMAKE_CURRENT_FUNCTION} - unparsed arguments: ${LIMES_UNPARSED_ARGUMENTS}")
    endif ()

    # TODO: on WatchOS: WatchKit app being installed is missing either the WKWatchKitApp or
    # WKApplication key set to true in its Info.plist
    set_target_properties (
        "${target}"
        PROPERTIES MACOSX_BUNDLE TRUE
                   XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO"
                   XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
                   XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
                   XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "${LIMES_BUNDLE_ID}"
                   MACOSX_BUNDLE_GUI_IDENTIFIER "${LIMES_BUNDLE_ID}"
                   MACOSX_BUNDLE_BUNDLE_VERSION "${LIMES_FULL_VERSION}"
                   MACOSX_BUNDLE_LONG_VERSION_STRING "${LIMES_FULL_VERSION}"
                   MACOSX_BUNDLE_SHORT_VERSION_STRING "${LIMES_VERSION_MAJOR}")

    limes_copy_dlls ("${target}")

endfunction ()
