:: ======================================================================================
::  __    ____  __  __  ____  ___
:: (  )  (_  _)(  \/  )( ___)/ __)
::  )(__  _)(_  )    (  )__) \__ \
:: (____)(____)(_/\/\_)(____)(___/
::
::  This file is part of the Limes open source library and is licensed under the terms of the GNU Public License.
::
::  Commercial licenses are available; contact the maintainers at ben.the.vining@gmail.com to inquire for details.
::
:: ======================================================================================

:: export default settings for CMake
:: see CMake's environment variables documentation: https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html

call util.bat

call :CHECK_FOR ninja

if %COMMAND_EXISTS% EQU 1 (
	@set CMAKE_GENERATOR="Ninja Multi-Config"
) else (
	@set CMAKE_GENERATOR="Visual Studio 17 2022"
)

@set CMAKE_CONFIG_TYPE=Debug

@set CMAKE_COLOR_DIAGNOSTICS=ON

@set CMAKE_EXPORT_COMPILE_COMMANDS=ON

@set CTEST_OUTPUT_ON_FAILURE=ON
@set CTEST_PROGRESS_OUTPUT=ON
@set CTEST_NO_TESTS_ACTION=error

@set CMAKE_BUILD_PARALLEL_LEVEL=%NUMBER_OF_PROCESSORS%
@set CTEST_PARALLEL_LEVEL=%NUMBER_OF_PROCESSORS%

@set VERBOSE=ON
