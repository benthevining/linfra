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

LimesDocs
------------------

This module provides some functions for configuring documentation builds and targets.

#]=======================================================================]

include_guard (GLOBAL)

#[=======================================================================[.rst:

.. command:: limes_default_doxygen_settings

    ::

        limes_default_doxygen_settings()

This macro calls ``find_package(Doxygen)`` and calls ``return()`` if Doxygen can't be found.
If Doxygen is found, this macro sets some default values for various ``DOXYGEN_`` variables.

.. note::
    This macro calls ``return()`` if Doxygen can't be found.

If you have other documentation targets that don't depend on Doxygen (such as generating a dependency graph,
autogenerating help files from a command line tool's output, etc), I recommend adding these targets *first*
in your documentation directory, then calling :command:`limes_default_doxygen_settings`, and then declaring
your project's Doxygen build targets (ie using CMake's ``doxygen_add_docs``, etc). This way, your other
documentation targets will always be created, and :command:`limes_default_doxygen_settings` will call ``return``
for you if Doxygen can't be found, preventing your Doxygen targets from being created. In my view, this is
generally desirable, because then other places in your build scripts can simply check for the existence of
your Doxygen targets to know if your documentation can actually be built successfully or not (as opposed to
always creating the target, and having it output an error message or something if Doxygen couldn't be found).

An example project's ``CMakeLists.txt`` in its ``docs/`` directory might look something like this:

.. code:: cmake

    myproj_create_dependency_graph_target()

    limes_default_doxygen_settings()

    doxygen_add_docs (myproj_docs ...)

    limes_add_docs_coverage (myproj_docs)

#]=======================================================================]
macro (limes_default_doxygen_settings)

    find_package (Doxygen OPTIONAL_COMPONENTS dot)

    if (NOT DOXYGEN_FOUND)
        message (WARNING "Doxygen not found, cannot build documentation")
        return ()
    endif ()

    if (NOT DOXYGEN_OUTPUT_DIRECTORY)
        set (DOXYGEN_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/doc")
    endif ()

    if (NOT DOXYGEN_WARN_LOGFILE)
        set (DOXYGEN_WARN_LOGFILE "${PROJECT_SOURCE_DIR}/logs/doxygen.log")
    endif ()

    if (NOT DOXYGEN_USE_MDFILE_AS_MAINPAGE)
        set (DOXYGEN_USE_MDFILE_AS_MAINPAGE "${PROJECT_SOURCE_DIR}/README.md")

        if (NOT EXISTS "${DOXYGEN_USE_MDFILE_AS_MAINPAGE}")
            unset (DOXYGEN_USE_MDFILE_AS_MAINPAGE)
        endif ()
    endif ()

    set (DOXYGEN_ALWAYS_DETAILED_SEC YES)
    set (DOXYGEN_FULL_PATH_NAMES NO)
    set (DOXYGEN_JAVADOC_AUTOBRIEF YES)
    set (DOXYGEN_BUILTIN_STL_SUPPORT YES)
    set (DOXYGEN_DISTRIBUTE_GROUP_DOC YES)
    set (DOXYGEN_GROUP_NESTED_COMPOUNDS YES)
    set (DOXYGEN_EXTRACT_PRIV_VIRTUAL YES)
    set (DOXYGEN_EXTRACT_STATIC YES)
    set (DOXYGEN_HIDE_FRIEND_COMPOUNDS YES)
    set (DOXYGEN_SORT_BRIEF_DOCS YES)
    set (DOXYGEN_SORT_MEMBERS_CTORS_1ST YES)
    set (DOXYGEN_SORT_GROUP_NAMES YES)
    set (DOXYGEN_SORT_BY_SCOPE_NAME YES)
    set (DOXYGEN_SOURCE_BROWSER YES)
    set (DOXYGEN_HTML_TIMESTAMP YES)
    set (DOXYGEN_HTML_DYNAMIC_SECTIONS YES)
    set (DOXYGEN_HTML_INDEX_NUM_ENTRIES 1)
    set (DOXYGEN_GENERATE_TREEVIEW YES)
    set (DOXYGEN_FULL_SIDEBAR YES)
    set (DOXYGEN_EXT_LINKS_IN_WINDOW YES)
    set (DOXYGEN_COLLABORATION_GRAPH NO)
    set (DOXYGEN_TEMPLATE_RELATIONS YES)
    set (DOXYGEN_DOT_IMAGE_FORMAT svg)
    set (DOXYGEN_INTERACTIVE_SVG YES)
    set (DOXYGEN_GENERATE_XML YES)

endmacro ()

#

# for some reason, this seems to be more robust than find_package(Python)
find_program (PYTHON_PROGRAM NAMES python3 python DOC "Python interpreter executable")

mark_as_advanced (PYTHON_PROGRAM)

block ()
if (PYTHON_PROGRAM)
    # check if coverxygen is installed
    if (NOT DEFINED CACHE{COVERXYGEN_INSTALLED})
        execute_process (
            COMMAND "${PYTHON_PROGRAM}" -c "import coverxygen" RESULT_VARIABLE coverxygen_found
            OUTPUT_VARIABLE output ERROR_VARIABLE error
        )

        if (coverxygen_found EQUAL 0)
            set (found_value ON)
        else ()
            set (found_value OFF)
        endif ()

        set (COVERXYGEN_INSTALLED "${found_value}"
             CACHE INTERNAL "Whether the coverxygen Python module was found"
        )

        message (CONFIGURE_LOG "coverxygen found: ${COVERXYGEN_INSTALLED}")
    endif ()

    if (NOT COVERXYGEN_INSTALLED)
        message (WARNING "coverxygen not installed, can't set up docs coverage reports")
    endif ()
else ()
    message (WARNING "Python not found, can't set up docs coverage reports")
endif ()
endblock ()

#[=======================================================================[.rst:

.. command:: limes_add_docs_coverage

    ::

        limes_add_docs_coverage (<docs-target>
                                [SOURCE_DIR <path>]
                                [DOCS_OUTPUT_DIR <path>]
                                [OUT_FILE <path>])

This function adds a post-build step to the ``docs-target`` to run ``coverxygen`` on the XML files generated by Doxygen.
Note that ``docs-target`` must be a Doxygen documentation build target (ie created by ``doxygen_add_docs``, etc), and it
must have ``GENERATE_XML`` set to ``ON`` in its configuration file (:command:`limes_default_doxygen_settings` sets this
to ``ON`` for you).

Options:

``SOURCE_DIR``
 Path to the source directory that the source code documented by ``docs-target`` is in. If not specified, defaults to
 ``PROJECT_SOURCE_DIR``.

``DOCS_OUTPUT_DIR``
 Path to the documentation produced by Doxygen after building ``docs-target``. This function assumes that the generated
 XML output will be at ``<DOCS_OUTPUT_DIR>/xml``. If not specified, the value of the ``DOXYGEN_OUTPUT_DIRECTORY`` variable
 will be used. If the ``DOCS_OUTPUT_DIR`` argument is not specified and the ``DOXYGEN_OUTPUT_DIRECTORY`` variable is not
 set, an error will be raised.

``OUT_FILE``
 This function will print the coverage information to stdout and also produce a plaintext file at the path specified by
 ``OUT_FILE``. If this argument isn't specified, no files will be produced.

#]=======================================================================]
function (limes_add_docs_coverage docsTarget)

    if (NOT TARGET "${docsTarget}")
        message (
            FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} - docs target ${docsTarget} does not exist!"
        )
    endif ()

    set (oneVal OUT_FILE SOURCE_DIR DOCS_OUTPUT_DIR)

    cmake_parse_arguments (LIMES "" "${oneVal}" "" ${ARGN})

    if (NOT LIMES_DOCS_OUTPUT_DIR)
        if (NOT DOXYGEN_OUTPUT_DIRECTORY)
            message (
                FATAL_ERROR
                    "${CMAKE_CURRENT_FUNCTION} - argument DOCS_OUTPUT_DIR not specified and the DOXYGEN_OUTPUT_DIRECTORY variable is not set!"
            )
        endif ()

        set (LIMES_DOCS_OUTPUT_DIR "${DOXYGEN_OUTPUT_DIRECTORY}")
    endif ()

    if (NOT LIMES_SOURCE_DIR)
        set (LIMES_SOURCE_DIR "${PROJECT_SOURCE_DIR}")
    endif ()

    if (LIMES_UNPARSED_ARGUMENTS)
        message (
            AUTHOR_WARNING
                "${CMAKE_CURRENT_FUNCTION} - unparsed arguments: ${LIMES_UNPARSED_ARGUMENTS}"
        )
    endif ()

    if (NOT (PYTHON_PROGRAM AND COVERXYGEN_INSTALLED))
        return ()
    endif ()

    set (xml_dir "${LIMES_DOCS_OUTPUT_DIR}/xml")

    # cmake-format: off
    set (command
        "${PYTHON_PROGRAM}"
            -m coverxygen
            --xml-dir "${xml_dir}"
            --src-dir "${LIMES_SOURCE_DIR}"
            --format summary
            --prefix "${LIMES_SOURCE_DIR}"
    )
    # cmake-format: on

    # write to stdout
    add_custom_command (
        TARGET "${docsTarget}" POST_BUILD COMMAND ${command} --output - VERBATIM USES_TERMINAL
    )

    if (LIMES_OUT_FILE)
        # write a plaintext file
        add_custom_command (
            TARGET "${docsTarget}"
            POST_BUILD
            BYPRODUCTS "${LIMES_OUT_FILE}"
            COMMAND ${command} --output "${LIMES_OUT_FILE}"
            COMMENT "Running docs coverage report for target ${docsTarget}..."
            VERBATIM USES_TERMINAL
        )
    endif ()

endfunction ()
