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

# usage: shutdown-ios-simulators.sh

# This script shuts down and erases the simulator devices used for our iOS, tvOS, and watchOS tests.
# These device IDs are specified in the environment variables IOS_SIMULATOR_DEVICE_ID, TVOS_SIMULATOR_DEVICE_ID,
# and WATCHOS_SIMULATOR_DEVICE_ID, which are initialized by direnv (you can override them in a local .env or
# .envrc.user file).

# This script is never run by CMake or CTest, but can be used to manually shut down simulators once you're done
# with testing.

set -euo pipefail

# shutdown_device <device-id> <type-string>
shutdown_device() {
	local device_id="$1"
	readonly device_id

	local device_type="$2"
	readonly device_type

	echo "$device_type" simulator device ID: "$device_id"

	set +e
	xcrun simctl shutdown "$device_id" > /dev/null 2>&1
	local exit_code=$?
	set -e

	readonly exit_code

	if [ "$exit_code" -eq 149 ]; then
		echo "$device_type" simulator device already shutdown
	elif [ ! "$exit_code" -eq 0 ]; then
		echo Error shutting down "$device_type" simulator device - exit code "$exit_code"
		exit "$exit_code"
	else
		echo Shut down "$device_type" simulator device
	fi

	xcrun simctl erase "$device_id"

	echo Erased "$device_type" simulator device
}

shutdown_device "$IOS_SIMULATOR_DEVICE_ID" "iOS"

shutdown_device "$TVOS_SIMULATOR_DEVICE_ID" "tvOS"

shutdown_device "$WATCHOS_SIMULATOR_DEVICE_ID" "watchOS"

exit 0
