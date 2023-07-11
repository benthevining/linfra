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

:: Calls a command and stores its output into the variable COMMAND_OUTPUT
:EXEC
	@set COMMAND_OUTPUT=

	@for /F "delims=" %%i in ('%~1 2^>nul') do @(
		@set COMMAND_OUTPUT=%%i
	)

	@if not "%COMMAND_OUTPUT%"=="" (
		@echo %1 -^> %COMMAND_OUTPUT%
	)
@goto :EOF

:: Checks for existence of the given program and sets the variable COMMAND_EXISTS
:CHECK_FOR
	@set COMMAND_EXISTS=

	@where %~1 >nul 2>nul

	@if %ERRORLEVEL% EQU 0 (
		@set COMMAND_EXISTS=1
	) else (
		@set COMMAND_EXISTS=0
	)
@goto :EOF
