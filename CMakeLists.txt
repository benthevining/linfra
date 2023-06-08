cmake_minimum_required (VERSION 3.25 FATAL_ERROR)

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

#[[
	limes_configure_app_bundle (<target>
								BUNDLE_ID <id>
								VERSION_MAJOR <majorVersion>
								FULL_VERSION <fullVersion>)
]]
function (limes_configure_app_bundle target)

	set (oneVal BUNDLE_ID VERSION_MAJOR FULL_VERSION)

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

	limes_copy_dlls ("${target}")

endfunction ()

#

include ("${CMAKE_CURRENT_LIST_DIR}/cmake/Testing.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/cmake/Docs.cmake")
