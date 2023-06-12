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

#]=======================================================================]
macro (limes_default_doxygen_settings)

    find_package (Doxygen OPTIONAL_COMPONENTS dot)

    if (NOT DOXYGEN_FOUND)
        message (WARNING "Doxygen not found, cannot build documentation")
        return ()
    endif ()

    set (DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/../doc")
    set (DOXYGEN_WARN_LOGFILE "${CMAKE_CURRENT_LIST_DIR}/../logs/doxygen.log")
    set (DOXYGEN_USE_MDFILE_AS_MAINPAGE "${CMAKE_CURRENT_LIST_DIR}/../README.md")
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
            OUTPUT_VARIABLE output ERROR_VARIABLE error)

        if (coverxygen_found EQUAL 0)
            set (found_value ON)
        else ()
            set (found_value OFF)
        endif ()

        set (COVERXYGEN_INSTALLED "${found_value}"
             CACHE INTERNAL "Whether the coverxygen Python module was found")

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

This function adds a post-build step to the ``docs-target`` to run ``coverxygen`` on the
generated XML files. Note that ``docs-target`` must be a Doxygen documentation build
target, and it must have ``GENERATE_XML`` set to ``ON`` in its configuration file.

Options:

``SOURCE_DIR``
 Path to the source directory that the source code documented by ``docs-target`` is in.

``DOCS_OUTPUT_DIR``
 Path to the documentation produced by Doxygen after building ``docs-target``. This function
 assumes that the generated XML output will be at ``<DOCS_OUTPUT_DIR>/xml``.

``OUT_FILE``
 This function will print the coverage information to stdout and also produce a plaintext
 file at the path specified by ``OUT_FILE``.

#]=======================================================================]
function (limes_add_docs_coverage docsTarget)

    if (NOT (PYTHON_PROGRAM AND COVERXYGEN_INSTALLED))
        return ()
    endif ()

    set (oneVal OUT_FILE SOURCE_DIR DOCS_OUTPUT_DIR)

    cmake_parse_arguments (LIMES "" "${oneVal}" "" ${ARGN})

    if (NOT LIMES_DOCS_OUTPUT_DIR)
        set (LIMES_DOCS_OUTPUT_DIR "${DOXYGEN_OUTPUT_DIRECTORY}")
    endif ()

    if (NOT LIMES_OUT_FILE)
        set (LIMES_OUT_FILE "${LIMES_DOCS_OUTPUT_DIR}/coverage.txt")
    endif ()

    if (NOT LIMES_SOURCE_DIR)
        set (LIMES_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/../src")
    endif ()

    set (xml_dir "${LIMES_DOCS_OUTPUT_DIR}/xml")

    # cmake-format: off
	add_custom_command (
		TARGET "${docsTarget}" POST_BUILD
		BYPRODUCTS "${LIMES_OUT_FILE}"
		# write a plaintext file
		COMMAND
			"${PYTHON_PROGRAM}" -m coverxygen
				--xml-dir "${xml_dir}"
				--src-dir "${LIMES_SOURCE_DIR}"
				--format summary
				--prefix "${LIMES_SOURCE_DIR}"
				--output "${LIMES_OUT_FILE}"
		# write to stdout
		COMMAND
			"${PYTHON_PROGRAM}" -m coverxygen
				--xml-dir "${xml_dir}"
				--src-dir "${LIMES_SOURCE_DIR}"
				--format summary
				--prefix "${LIMES_SOURCE_DIR}"
				--output -
		COMMENT "Running docs coverage report for target ${docsTarget}..."
		VERBATIM USES_TERMINAL)
	# cmake-format: on

endfunction ()
