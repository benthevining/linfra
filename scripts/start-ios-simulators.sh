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

# usage: start-ios-simulators.sh

# This script starts the simulator devices used for our iOS, tvOS, and watchOS tests.
# These device IDs are specified in the environment variables IOS_SIMULATOR_DEVICE_ID, TVOS_SIMULATOR_DEVICE_ID,
# and WATCHOS_SIMULATOR_DEVICE_ID, which are initialized by direnv (you can override them in a local .env or
# .envrc.user file).

# This script is never run by CMake or CTest and its usage is optional. If the device simulator being used for
# a test is not running when the test is executed, the emulator wrapper script (test-ios.sh) will start the
# simulator device and then execute the test.

# Running this script before building can speed up post-build and test steps, but everything should still
# "just work" without it.

set -euo pipefail

# start_device <device-id> <type-string>
start_device() {
	local device_id="$1"
	readonly device_id

	local device_type="$2"
	readonly device_type

	echo "$device_type" simulator device ID: "$device_id"

	set +e
	xcrun simctl boot "$device_id" > /dev/null 2>&1
	local boot_result=$?
	set -e

	readonly boot_result

	if [ "$boot_result" -eq 149 ]; then
		echo "$device_type" simulator device aready booted
		return
	elif [ "$boot_result" -eq 0 ]; then
		echo "$device_type" simulator device successfully booted.
	else
		echo Unable to boot "$device_type" simulator device - error code "$boot_result"
		exit $boot_result
	fi
}

start_device "$IOS_SIMULATOR_DEVICE_ID" "iOS"

start_device "$TVOS_SIMULATOR_DEVICE_ID" "tvOS"

start_device "$WATCHOS_SIMULATOR_DEVICE_ID" "watchOS"

exit 0
