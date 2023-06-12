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

:: look for Android SDK/NDK
::
:: variables:
:: ANDROID_SDK_ROOT - path to the Android SDK installation. Defaults to $HOME/Library/Android/sdk.
:: ANDROID_NDK_ROOT - path to the Android NDK to use. This file attempts to locate it automatically but your .env can override it.
:: ANDROID_SIMULATOR_AVD - ID of the AVD to use with the Android Studio emulator

:: TODO: test other possible locations
@set ANDROID_SDK_ROOT=C:\Users\%USERNAME%\AppData\Local\Android\sdk

if exist %ANDROID_SDK_ROOT%\
(
	:: TODO: emulator -list-avds or use avdmanager
	@set ANDROID_SIMULATOR_AVD=TestAVD

	@set ANDROID_NDK_ROOT=%ANDROID_SDK_ROOT%\ndk

	if exist %ANDROID_NDK_ROOT%\
	(
		:: TODO: locate most recent NDK (save to ANDROID_NDK_ROOT)
	)
)
