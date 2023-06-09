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
		GIT_PROGRESS ON)

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

	limes_configure_app_bundle (
		"${target}" BUNDLE_ID "${LIMES_BUNDLE_ID}" VERSION_MAJOR "${LIMES_VERSION_MAJOR}"
		FULL_VERSION "${LIMES_FULL_VERSION}")

	target_link_libraries ("${target}" PRIVATE Catch2::Catch2WithMain)

	# cmake-format: off
	catch_discover_tests (
		"${target}"
		EXTRA_ARGS
			--warn NoAssertions
			--order rand
			--verbosity high
		TEST_PREFIX "limes.${LIMES_TEST_CATEGORY}.unit."
		PROPERTIES
			SKIP_REGULAR_EXPRESSION "SKIPPED:"
			FAIL_REGULAR_EXPRESSION "FAILED:")
	# cmake-format: on

endfunction ()

#[[
	limes_configure_benchmark_target (<executableTarget>
									  BENCH_TARGET <targetName>
									  LIB_NAME <library>)
]]
function (limes_configure_benchmark_target target)

	set (oneVal BENCH_TARGET LIB_NAME)

	cmake_parse_arguments (LIMES "" "${oneVal}" "" ${ARGN})

	target_link_libraries ("${target}" PRIVATE Catch2::Catch2WithMain)

	limes_copy_dlls ("${target}")

	add_custom_target (
		"${LIMES_BENCH_TARGET}" COMMAND "${target}" "[!benchmark]" --order rand --verbosity high
		COMMENT "Running ${LIMES_LIB_NAME} benchmarks..." USES_TERMINAL)

endfunction ()
