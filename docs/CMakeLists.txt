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

find_package (Python3 COMPONENTS Interpreter)

find_program (SPHINX_EXECUTABLE NAMES sphinx-build
              DOC "Sphinx Documentation Builder (sphinx-doc.org)")

mark_as_advanced (SPHINX_EXECUTABLE)

if (NOT (TARGET Python3::Interpreter AND SPHINX_EXECUTABLE))
    return ()
endif ()

set (configured_conf "${CMAKE_CURRENT_BINARY_DIR}/conf.py")

# input vars: CMAKE_CURRENT_LIST_DIR
configure_file (conf.py "${configured_conf}" @ONLY NEWLINE_STYLE UNIX)

set (LINFRA_DOCS_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/doc"
     CACHE PATH "Directory where Linfra documentation will be produced")

set (stamp_file "${CMAKE_CURRENT_BINARY_DIR}/linfra_docs.stamp")
set (log_file "${CMAKE_CURRENT_BINARY_DIR}/sphinx.log")

set (sphinx_cache "${CMAKE_CURRENT_BINARY_DIR}/doctrees")

file (GLOB_RECURSE rst_files LIST_DIRECTORIES false CONFIGURE_DEPENDS "rst/*.rst")

file (GLOB cmake_modules LIST_DIRECTORIES false
      CONFIGURE_DEPENDS "${CMAKE_CURRENT_LIST_DIR}/../cmake/modules/*.cmake")

# cmake-format: off
add_custom_command (
	OUTPUT "${stamp_file}"
	COMMAND
		"${SPHINX_EXECUTABLE}"
			-b html
			-c "${CMAKE_CURRENT_BINARY_DIR}"
			-d "${sphinx_cache}"
			-w "${log_file}"
			-a
			"${CMAKE_CURRENT_LIST_DIR}/rst"
			"${LINFRA_DOCS_OUTPUT_DIR}"
	COMMAND "${CMAKE_COMMAND}" -E touch "${stamp_file}"
	DEPENDS "${configured_conf}" colors.py linfra.css ${rst_files} ${cmake_modules}
	COMMENT "Building linfra docs..."
	VERBATIM USES_TERMINAL)
# cmake-format: on

# TODO: add linkcheck builder

add_custom_target (LinfraDocs DEPENDS "${stamp_file}"
                   SOURCES "${configured_conf}" colors.py linfra.css ${rst_files} ${cmake_modules})

source_group (TREE "${CMAKE_CURRENT_LIST_DIR}/rst" PREFIX docs FILES ${rst_files})
source_group (config FILES "${configured_conf}" colors.py linfra.css)
source_group (cmake FILES ${cmake_modules})

set_property (TARGET LinfraDocs APPEND PROPERTY ADDITIONAL_CLEAN_FILES "${LINFRA_DOCS_OUTPUT_DIR}"
                                                "${log_file}")
