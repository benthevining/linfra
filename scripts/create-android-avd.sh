#!/bin/bash

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

set -euxo pipefail

# ANDROID_SDK_ROOT should be set.
if [ ! -d "$ANDROID_SDK_ROOT" ]; then
	echo Android SDK not found at path '$ANDROID_SDK_ROOT'
	echo Make sure that the ANDROID_SDK_ROOT variable is set!
	exit 1
fi

if [ -z ${SDK_VERSION_MAJOR+x} ]; then
	SDK_VERSION_MAJOR=34
fi

readonly SDK_VERSION_MAJOR

if [ -z ${SDK_FULL_VERSION+x} ]; then
	SDK_FULL_VERSION="$SDK_VERSION_MAJOR.0.0"
fi

readonly SDK_FULL_VERSION

if [ -z ${AVD_NAME+x} ]; then
	AVD_NAME=TestAVD
fi

readonly AVD_NAME

if [ -z ${ARCH+x} ]; then
	ARCH=arm64-v8a
fi

readonly ARCH

#

TOOLS_DIR="$ANDROID_SDK_ROOT/tools/bin"
readonly TOOLS_DIR

if [ ! -d "$TOOLS_DIR" ]; then
	echo Tools directory not found at path '$TOOLS_DIR'
	exit 1
fi

SDK_MANAGER="$TOOLS_DIR/sdkmanager"
readonly SDK_MANAGER

#

# populate module list
$SDK_MANAGER --list

# install required modules & packages

$SDK_MANAGER "build-tools;$SDK_FULL_VERSION"

$SDK_MANAGER "platforms;android-$SDK_VERSION_MAJOR"

IMAGE="system-images;android-$SDK_VERSION_MAJOR;google_apis;$ARCH"
readonly IMAGE

$SDK_MANAGER "$IMAGE"

$SDK_MANAGER --update

# create avd
"$TOOLS_DIR/avdmanager" create avd -n "$AVD_NAME" -k "$IMAGE"

exit $?
