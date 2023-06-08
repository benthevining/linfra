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

include_guard (GLOBAL)

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

endmacro ()
