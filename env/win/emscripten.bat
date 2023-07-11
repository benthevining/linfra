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

:: check if the Emscripten SDK is installed
::
:: variables:
:: EMSCRIPTEN_ROOT - path to the root of the Emscripten SDK. This file attempts to locate it automatically.

@call util.bat

:: check for existence of emcc (emscripten compiler)
@call :CHECK_FOR emcc

if %COMMAND_EXISTS% EQU 1
(
	:: store path of emcc executable into variable COMMAND_OUTPUT
	@call :EXEC "where emcc"

	:: equivalent of dirname in bash, outputs to dirname variable
	for %%F in (%COMMAND_OUTPUT%) do set dirname=%%~dpF

	@set EMSCRIPTEN_ROOT=%dirname%
)
