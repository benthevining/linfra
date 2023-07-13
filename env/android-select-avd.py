#!/usr/bin/env python3
# -*- coding: utf-8 -*-

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

"""
Usage: android-select-avd.py

This script parses the output of 'avdmanager list avd' to choose an Android AVD to use for running tests.
When successful, the script will print the AVD ID to stdout. avdmanager doesn't seem to report any additional
information about each AVD other than its name, so for now we simply choose the first one in the returned list.

This script is invoked by direnv to choose the default value for the ANDROID_SIMULATOR_AVD environment variable.

Note that the ANDROID_SDK_ROOT environment variable must be set when this script is invoked.
"""

from os import environ
import sys
from pathlib import Path
import subprocess

sdk_root = environ.get ('ANDROID_SDK_ROOT')

if sdk_root is None:
    print ('The environment variable ANDROID_SDK_ROOT must be set!')
    sys.exit (1)

sdk_root = Path (sdk_root)

avdmanager = sdk_root / 'tools' / 'bin' / 'avdmanager'

run_result = subprocess.run ([avdmanager, 'list', 'avd', '--compact'],
                stdout=subprocess.PIPE, check=True)

device_list = run_result.stdout.decode().split()

if device_list is None or len(device_list) == 0:
    print('No Android AVDs were found!')
    sys.exit(1)

print (device_list[0])
