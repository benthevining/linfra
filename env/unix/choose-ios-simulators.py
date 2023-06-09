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
Usage: choose-ios-simulators.py <platform>

This script parses the output of 'xcrun simctl list --json' to choose simulator device UUIDs to use for each platform.
When successful, the script will print a single device UUID to stdout for the requested platform. The platform is
specified as a positional argument to the script and must be one of iOS, tvOS, or watchOS.

This script is invoked by direnv to choose default values for the IOS_SIMULATOR_DEVICE_ID, TVOS_SIMULATOR_DEVICE_ID,
and WATCHOS_SIMULATOR_DEVICE_ID environment variables.
"""

import sys
import subprocess
import json

#

if len(sys.argv) < 2:
    print ('You must specify the platform as the first argument')
    sys.exit(1)

platform = sys.argv[1]

if platform not in ['iOS', 'tvOS', 'watchOS']:
    print (f'Invalid platform requested: \'{platform}\'')
    sys.exit(1)

run_result = subprocess.run (['xcrun', 'simctl', 'list', '--json'],
                            stdout=subprocess.PIPE, check=True)

top_dict = json.loads (run_result.stdout)

#

# Need to chooose a runtime to use and save its identifier.
# Pick the newest available runtime for the desired platform.

runtimes = top_dict['runtimes']

chosen_runtime = None

for runtime_obj in runtimes:
    if not (runtime_obj['isAvailable'] and runtime_obj['platform'] == platform):
        continue

    if chosen_runtime is None or runtime_obj['version'] > chosen_runtime['version']: # pylint: disable=unsubscriptable-object
        chosen_runtime = runtime_obj

if chosen_runtime is None:
    print ('No runtime found!')
    sys.exit(1)

runtime_id = chosen_runtime['identifier']

#

devices_dict = top_dict['devices']

if not runtime_id in devices_dict:
    print(f'Runtime ID \'{runtime_id}\' not found in devices dict!')
    sys.exit(1)

devices = devices_dict[runtime_id]

chosen_device = None

# the newest device will be at the end of the list, so reverse it before iterating
devices.reverse()

for device_obj in devices:
    if device_obj['isAvailable']:
        chosen_device = device_obj
        break

if chosen_device is None:
    print('No devices available!')
    sys.exit(1)

print(chosen_device['udid'])
