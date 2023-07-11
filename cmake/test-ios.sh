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

# usage: test-ios.sh <device-id> <executable> [<args...>]

# This script is used as the CMAKE_CROSSCOMPILING_EMULATOR for our iOS, tvOS, and watchOS simulator
# builds. Each of those CMake presets sets CMAKE_CROSSCOMPILING_EMULATOR to a list of 2 items: the
# path to this script, and the <device-id> argument. Device IDs are specified using environment
# variables, and each CMake preset selects the appropriate environment variable: the iOS preset uses
# IOS_SIMULATOR_DEVICE_ID, the tvOS preset uses TVOS_SIMULATOR_DEVICE_ID, and the watchOS preset uses
# WATCHOS_SIMULATOR_DEVICE_ID. These environment variables are initialized by direnv, but you can
# override the defaults in a local .env or .envrc.user file. If you change one of the device ID
# environment variables, you should reconfigure CMake to get the change to the new device simulators.

# Note that you need to build with the simulator SDK, not the device SDK, and the global property
# XCODE_EMIT_EFFECTIVE_PLATFORM_NAME must be OFF (otherwise the path we get sent by CMake will include
# the literal string `${EFFECTIVE_PLATFORM}`, which we can't expand reliably).

# If the simulator device specified by <device-id> is not already running, this script will start it.
# This script does not shutdown the simulator device; in a scenario like running CTest it is desirable
# to leave the simulator running so that each test doesn't need to restart it.
# Use the scripts start-ios-simulators.sh and shutdown-ios-simulators.sh in the scripts/ directory to
# start and shutdown all the simulator devices used for our iOS, tvOS, and watchOS tests. This is optional;
# if you never run those scripts manually, running our CTest test suite should still "just work".

# TODO: we're not correctly capturing the exit code of the launch command, we're currently relying on
# the FAIL_REGULAR_EXPRESSION test property...

set -euo pipefail

DEVICE_ID="$1"
readonly DEVICE_ID

if [ -z "$DEVICE_ID" ]; then
	echo Empty device ID!
	exit 1
fi

echo iOS simulator device ID: "$DEVICE_ID"

APP_PATH="$2"

# CMake will send us the actual executable path that's inside the .app bundle, for example foo.app/foo
# but we want to work with the path to the .app bundle, so take dirname of the path CMake sent us
# this is a bit hacky, if the .app bundle's default layout created by CMake changes, this will break
APP_PATH=$(dirname "$APP_PATH")
readonly APP_PATH

if [ ! -d "$APP_PATH" ]; then
	echo App does not exist at path "$APP_PATH"!
	exit 1
fi

shift 2

APP_BUNDLE_ID=$(mdls -name kMDItemCFBundleIdentifier -r "$APP_PATH")
readonly APP_BUNDLE_ID

if [ -z "$APP_BUNDLE_ID" ] || [ "$APP_BUNDLE_ID" == "(null)" ]; then
	echo Unable to retrieve app bundle ID!
	echo App bundle path: "$APP_PATH"
	exit 1
fi

echo App bundle ID: "$APP_BUNDLE_ID"

set +e
xcrun simctl boot "$DEVICE_ID" > /dev/null 2>&1
boot_result=$?
set -e

readonly boot_result

if [ "$boot_result" -eq 149 ]; then
	echo Device aready booted.
elif [ "$boot_result" -eq 0 ]; then
	echo Device successfully booted.
else
	echo "Unable to boot device $DEVICE_ID - error code $boot_result"
	exit $boot_result
fi

# this should not re-install the app unless the binary has changed (or it was deleted from the simulator device)
xcrun simctl install "$DEVICE_ID" "$APP_PATH"

exec xcrun simctl launch --console-pty "$DEVICE_ID" "$APP_BUNDLE_ID" "$@"
