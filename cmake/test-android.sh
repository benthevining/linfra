#!/bin/bash

# @formatter:off
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
# @formatter:on

# usage: test-android.sh <sdk-root-path> <avd-name> <executable> [<args...>]

# TODO: forward args to app
# emulator seems to enter an event loop when you start it...

set -euo pipefail

if [ -z "$ANDROID_SDK_ROOT" ]; then
	ANDROID_SDK_ROOT="$1"
fi

readonly ANDROID_SDK_ROOT

if [ ! -d "$ANDROID_SDK_ROOT" ]; then
	echo Android SDK does not exist at path: "$ANDROID_SDK_ROOT"
	exit 1
fi

if [ -z ${ANDROID_SIMULATOR_AVD+x} ]; then
	ANDROID_SIMULATOR_AVD="$2"
fi

readonly ANDROID_SIMULATOR_AVD

APP_PATH="$3"
readonly APP_PATH

if [ ! -f "$APP_PATH" ]; then
	echo App does not exist at path "$APP_PATH"!
	exit 1
fi

shift 3

"$ANDROID_SDK_ROOT/tools/emulator" -avd "$ANDROID_SIMULATOR_AVD" -read-only -debug-all -no-boot-anim -no-window -skip-adb-auth

"$ANDROID_SDK_ROOT/platform-tools/adb" -d "$ANDROID_SIMULATOR_AVD" install -t "$APP_PATH"

# TODO: actually run the app?

exit $?
