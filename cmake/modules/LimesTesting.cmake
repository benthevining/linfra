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

.. _`testing-cmake`:

LimesTesting
------------------

This module provides some functions for configuring test and benchmark targets.

Cache variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. cmake:variable:: LIMES_CATCH_FLAGS

Space-separated command line arguments to be passed to Catch test runners. Used by the limes_configure_test_target() function.

.. cmake:variable:: LIMES_CATCH_FLAGS_BENCH

Space-separated command line arguments to be passed to Catch test runners when running benchmarks. Used by the limes_configure_benchmark_target() function.

#]=======================================================================]

include_guard (GLOBAL)

set (
    LIMES_CATCH_FLAGS
    "--warn NoAssertions --order rand --verbosity high"
    CACHE
        STRING
        "Space-separated command line arguments to be passed to Catch test runners. Used by the limes_configure_test_target() function."
)

set (
    LIMES_CATCH_FLAGS_BENCH
    "--order rand --verbosity high"
    CACHE
        STRING
        "Space-separated command line arguments to be passed to Catch test runners when running benchmarks. Used by the limes_configure_benchmark_target() function."
)

mark_as_advanced (LIMES_CATCH_FLAGS LIMES_CATCH_FLAGS_BENCH)

#[=======================================================================[.rst:

.. command:: limes_get_catch2

    ::

        limes_get_catch2()

This macro populates Catch2 using ``FetchContent`` and does some patching where needed:

* Xcode signing is disabled for the Catch2 targets
* If you're building for tvOS or watchOS, Posix signals are disabled for Catch
* If you're building for watchOS, we add the ``-fgnu-inline-asm`` flag to the Catch target
* If you're building for Emscripten, we add some options to Catch to allow exceptions
* Lastly, this macro includes Catch's ``Catch.cmake`` file.

#]=======================================================================]
macro (limes_get_catch2)

    set (CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO")
    set (CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
    set (CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")

    include (FetchContent)

    if ("${CMAKE_SYSTEM_NAME}" MATCHES "tvOS" OR "${CMAKE_SYSTEM_NAME}" MATCHES "watchOS")
        set (CATCH_CONFIG_NO_POSIX_SIGNALS ON)
    endif ()

    FetchContent_Declare (
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG origin/devel
        GIT_SHALLOW ON
        GIT_PROGRESS ON
    )

    FetchContent_MakeAvailable (Catch2)

    if (TARGET Catch2)
        if ("${CMAKE_SYSTEM_NAME}" MATCHES "watchOS")
            target_compile_options (Catch2 PRIVATE -fgnu-inline-asm)
        elseif (EMSCRIPTEN)
            target_compile_options (Catch2 PRIVATE -sNO_DISABLE_EXCEPTION_CATCHING -fexceptions)
            target_link_options (Catch2 PRIVATE -fexceptions)
        endif ()
    endif ()

    if (catch2_SOURCE_DIR)
        list (APPEND CMAKE_MODULE_PATH "${catch2_SOURCE_DIR}/extras")
    endif ()

    include (Catch)

endmacro ()

#[=======================================================================[.rst:

.. command:: limes_configure_test_target

    ::

        limes_configure_test_target (<target>
                                     BUNDLE_ID <id>
                                     VERSION_MAJOR <majorVersion>
                                     FULL_VERSION <fullVersion>
                                     TEST_PREFIX <prefix>)

This function configures an executable target for testing, and calls ``catch_discover_tests``.

On platforms such as iOS and Android, only application bundles in specific formats can be
run (``.app`` bundles on iOS, and ``apk`` s on Android). This function does this setup work by
calling :command:`limes_configure_app_bundle`, linking the executable target to
``Catch2::Catch2WithMain``, and calling ``catch_discover_tests``.

Note that this function is intended for use with executable targets whose source files include
Catch2 ``TEST_CASE`` declarations.

Options:

``BUNDLE_ID``
 Bundle ID to use for the ``.app`` bundle on iOS.

``VERSION_MAJOR``
 Major version of the test application.

``FULL_VERSION``
 Full version string for the test application.

``TEST_PREFIX``
 Prefix to prepend to all test case names to create test names registered with CTest.

TODO: a CATCH_FLAGS option/variable?

#]=======================================================================]
function (limes_configure_test_target target)

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target ${target} does not exist!")
    endif ()

    set (oneVal BUNDLE_ID VERSION_MAJOR FULL_VERSION TEST_PREFIX)

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

    if (NOT LIMES_TEST_PREFIX)
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - argument TEST_PREFIX is required!")
    endif ()

    if (LIMES_UNPARSED_ARGUMENTS)
        message (
            AUTHOR_WARNING
                "${CMAKE_CURRENT_FUNCTION} - unparsed arguments: ${LIMES_UNPARSED_ARGUMENTS}"
        )
    endif ()

    limes_configure_app_bundle (
        "${target}" BUNDLE_ID "${LIMES_BUNDLE_ID}" VERSION_MAJOR "${LIMES_VERSION_MAJOR}"
        FULL_VERSION "${LIMES_FULL_VERSION}"
    )

    target_link_libraries ("${target}" PRIVATE Catch2::Catch2WithMain)

    separate_arguments (args UNIX_COMMAND "${LIMES_CATCH_FLAGS}")

    # cmake-format: off
    catch_discover_tests (
        "${target}"
        EXTRA_ARGS ${args}
        TEST_PREFIX "${LIMES_TEST_PREFIX}"
        PROPERTIES
            SKIP_REGULAR_EXPRESSION "SKIPPED:"
            FAIL_REGULAR_EXPRESSION "FAILED:"
    )
    # cmake-format: on

endfunction ()

#[=======================================================================[.rst:

.. command:: limes_configure_benchmark_target

    ::

        limes_configure_benchmark_target (<executableTarget>
                                          BUNDLE_ID <id>
                                          VERSION_MAJOR <majorVersion>
                                          FULL_VERSION <fullVersion>
                                         [BENCH_TARGET <targetName>]
                                         [LIB_NAME <library>])

This function creates a custom target to drive running benchmarks in the specified ``<executableTarget>``.

This function is intended for use with executable targets whose source files contain Catch2
``TEST_CASE`` declarations with the ``[!benchmark]`` tag. The custom target (whose name is specified in
``BENCH_TARGET``), when built, will run all benchmark test cases in the ``<executableTarget>``.

Options:

``BENCH_TARGET``
 Name of the custom target to create that will drive running the benchmarks. If not specified, defaults to
 ``<executableTarget>_benchmarks``.

``LIB_NAME``
 Name of the library or product being tested by these benchmarks. Only used to create the custom target's
 ``COMMENT``. If not specified, defaults to ``<executableTarget>``.

``BUNDLE_ID``
 Bundle ID to use for the ``.app`` bundle on iOS.

``VERSION_MAJOR``
 Major version of the test application.

``FULL_VERSION``
 Full version string for the test application.

TODO: custom Catch2 JSON reporter?

#]=======================================================================]
function (limes_configure_benchmark_target target)

    if (NOT TARGET "${target}")
        message (FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - target ${target} does not exist!")
    endif ()

    set (oneVal BENCH_TARGET LIB_NAME BUNDLE_ID)

    cmake_parse_arguments (LIMES "" "${oneVal}" "" ${ARGN})

    if (NOT LIMES_LIB_NAME)
        set (LIMES_LIB_NAME "${target}")
    endif ()

    if (NOT LIMES_BENCH_TARGET)
        set (LIMES_BENCH_TARGET "${target}_benchmarks")
    endif ()

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
                "${CMAKE_CURRENT_FUNCTION} - unparsed arguments: ${LIMES_UNPARSED_ARGUMENTS}"
        )
    endif ()

    target_link_libraries ("${target}" PRIVATE Catch2::Catch2WithMain)

    limes_configure_app_bundle (
        "${target}" BUNDLE_ID "${LIMES_BUNDLE_ID}" VERSION_MAJOR "${LIMES_VERSION_MAJOR}"
        FULL_VERSION "${LIMES_FULL_VERSION}"
    )

    separate_arguments (args UNIX_COMMAND "${LIMES_CATCH_FLAGS_BENCH}")

    add_custom_target (
        "${LIMES_BENCH_TARGET}" COMMAND "${target}" "[!benchmark]" ${args}
        COMMENT "Running ${LIMES_LIB_NAME} benchmarks..." USES_TERMINAL
    )

endfunction ()
