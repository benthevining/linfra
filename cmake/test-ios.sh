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

# CMake will send us the actual executable path that's inside the .app bundle, for example foo.app/foo

# note that you need to build with the simulator SDK, not the device SDK,
# and the global property XCODE_EMIT_EFFECTIVE_PLATFORM_NAME must be OFF

# TODO: we're not correctly capturing the exit code of the launch command, we're currently relying on
# the FAIL_REGULAR_EXPRESSION test property...

set -euxo pipefail

DEVICE_ID="$1"
readonly DEVICE_ID

APP_PATH="$2"

APP_PATH=$(dirname "$APP_PATH")
readonly APP_PATH

if [ ! -d "$APP_PATH" ]; then
	echo App does not exist at path "$APP_PATH"!
	exit 1
fi

shift 2

APP_BUNDLE_ID=$(mdls -name kMDItemCFBundleIdentifier -r "$APP_PATH")
readonly APP_BUNDLE_ID

if [ -z "$APP_BUNDLE_ID" ]; then
	echo Unable to retrieve app bundle ID!
	exit 1
fi

set +e
xcrun simctl boot "$DEVICE_ID"
boot_result=$?
set -e

readonly boot_result

if [ "$boot_result" -eq 149 ]; then
	echo Device aready booted.
elif [ "$boot_result" -ne 0 ]; then
	echo "Unable to boot device $DEVICE_ID - error code $boot_result"
	exit $boot_result
fi

xcrun simctl install "$DEVICE_ID" "$APP_PATH"

xcrun simctl launch --console-pty "$DEVICE_ID" "$APP_BUNDLE_ID" "$@"

exit $?
