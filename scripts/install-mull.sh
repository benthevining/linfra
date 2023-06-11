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

# usage: install-mull.sh [<clangVersion>] [<installPrefix>]

# Note that you also need to install the corresponding version of Clang/LLVM and make sure it is in your PATH.

set -euo pipefail

readonly MULL_LATEST_VERSION=0.21.0

if [ "$#" -gt "0" ]; then
	MULL_CLANG_VERSION="$1"
elif [ -z ${MULL_CLANG_VERSION+x} ]; then
	echo Clang version not specified! Either set the environment variable MULL_CLANG_VERSION or pass the Clang version as an argument to this script.
	exit 1
fi

readonly MULL_CLANG_VERSION

if [[ "$MULL_CLANG_VERSION" -gt "14" || "$MULL_CLANG_VERSION" -lt "11" ]]; then
	echo Mull only supports Clang 11-14. Invalid Clang version requested: "$MULL_CLANG_VERSION"
	exit 1
fi

echo Selected Clang version: "$MULL_CLANG_VERSION"

if [ "$#" -gt "1" ]; then
	INSTALL_PREFIX="$2"
elif [ -z ${INSTALL_PREFIX+x} ]; then
	INSTALL_PREFIX="/usr/local"
fi

readonly INSTALL_PREFIX

echo Install prefix: "$INSTALL_PREFIX"

# on Linux, install using apt (may require sudo)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	curl -1sLf 'https://dl.cloudsmith.io/public/mull-project/mull-stable/setup.deb.sh' | sudo -E bash
	apt-get update
	apt-get install "mull-$MULL_CLANG_VERSION"
	exit $?
fi

# need to manually download & install for MacOS

installer_name="Mull-$MULL_CLANG_VERSION-$MULL_LATEST_VERSION-LLVM-$MULL_CLANG_VERSION.0-macOS-11.7.6"
readonly installer_name

installer_file_name="$installer_name.zip"
readonly installer_file_name

TEMP_DIR="$(pwd)/temp"
readonly TEMP_DIR

echo Temporary directory: "$TEMP_DIR"

downloaded_zip="$TEMP_DIR/$installer_file_name"
readonly downloaded_zip

if [ ! -d "$TEMP_DIR" ]; then
	mkdir "$TEMP_DIR"
fi

if [ ! -f "$downloaded_zip" ]; then
	download_url="https://github.com/mull-project/mull/releases/download/$MULL_LATEST_VERSION/$installer_file_name"
	readonly download_url
	echo Artefact download URL: "$download_url"
	cd "$TEMP_DIR"
	curl -LO "$download_url"
fi

unzipped_dir="$TEMP_DIR/$installer_name"
readonly unzipped_dir

if [ ! -d "$unzipped_dir" ]; then
	unzip "$downloaded_zip"
fi

#

runner_filename="mull-runner-$MULL_CLANG_VERSION"
readonly runner_filename

runner="$unzipped_dir/bin/$runner_filename"
readonly runner

if [ ! -f "$runner" ]; then
	echo Runner executable not found at path "$runner"
	exit 1
fi

install_bin_dir="$INSTALL_PREFIX/bin"
readonly install_bin_dir

if [ ! -d "$install_bin_dir" ]; then
	mkdir -p "$install_bin_dir"
fi

installed_runner="$install_bin_dir/$runner_filename"
readonly installed_runner

if [ -f "$installed_runner" ]; then
	echo Runner already installed at path "$installed_runner"
else
	echo Installing runner...
	cp "$runner" "$installed_runner"
fi

#

plugin_filename="mull-ir-frontend-$MULL_CLANG_VERSION"
readonly plugin_filename

plugin="$unzipped_dir/lib/$plugin_filename"
readonly plugin

if [ ! -f "$plugin" ]; then
	echo Plugin binary not found at path "$plugin"
	exit 1
fi

install_lib_dir="$INSTALL_PREFIX/lib"
readonly install_lib_dir

if [ ! -d "$install_lib_dir" ]; then
	mkdir -p "$install_lib_dir"
fi

installed_plugin="$install_lib_dir/$plugin_filename"
readonly installed_plugin

if [ -f "$installed_plugin" ]; then
	echo Plugin already installed at path "$installed_plugin"
else
	echo Installing plugin...
	cp "$plugin" "$installed_plugin"
fi

#

echo Installed mull at prefix "$INSTALL_PREFIX"

rm -rf "$TEMP_DIR"

exit 0
