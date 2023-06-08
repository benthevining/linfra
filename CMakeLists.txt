cmake_minimum_required (VERSION 3.25 FATAL_ERROR)

project (
	limes-infra
	LANGUAGES NONE
	DESCRIPTION "Common utilities used by Limes library repos"
	HOMEPAGE_URL https://github.com/benthevining/linfra/
	VERSION 0.0.1)

#

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

#

function (limes_copy_dlls target)
	if (WIN32)
		add_custom_command (
			TARGET "${target}" POST_BUILD
			COMMAND "${CMAKE_COMMAND}" -E copy -t $<TARGET_FILE_DIR:${target}>
					$<TARGET_RUNTIME_DLLS:${target}> USES_TERMINAL COMMAND_EXPAND_LISTS)
	endif ()
endfunction ()

#

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

#

macro (limes_get_catch2)

	set (CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO")
	set (CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
	set (CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")

	include (FetchContent)

	if ("${CMAKE_SYSTEM_NAME}" MATCHES "tvOS" OR "${CMAKE_SYSTEM_NAME}" MATCHES "watchOS")
		set (CATCH_CONFIG_NO_POSIX_SIGNALS ON)
	endif ()

	FetchContent_Declare (Catch2 GIT_REPOSITORY https://github.com/catchorg/Catch2.git
						  GIT_TAG origin/devel GIT_SHALLOW ON)

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

#[[
	limes_configure_test_target (<target>
								 BUNDLE_ID <id>
								 VERSION_MAJOR <majorVersion>
								 FULL_VERSION <fullVersion>
								 TEST_CATEGORY <category>)
]]
function (limes_configure_test_target target)

	set (oneVal BUNDLE_ID VERSION_MAJOR FULL_VERSION TEST_CATEGORY)

	cmake_parse_arguments (LIMES "" "${oneVal}" "" ${ARGN})

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

	target_link_libraries ("${target}" PRIVATE Catch2::Catch2WithMain)

	lfilesystem_copy_dlls ("${target}")

	# cmake-format: off
	catch_discover_tests (
		"${target}"
		EXTRA_ARGS
			--warn NoAssertions
			--order rand
			--verbosity high
		TEST_PREFIX "limes.${LIMES_TEST_CATEGORY}.unit.")
	# cmake-format: on

endfunction ()
