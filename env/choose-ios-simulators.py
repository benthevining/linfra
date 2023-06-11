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

import sys
import subprocess
import json

#

if len(sys.argv) < 2:
	print ('You must specify the platform as the first argument')
	sys.exit(1)

platform = sys.argv[1]

if not platform in ['iOS', 'tvOS', 'watchOS']:
	print ('Invalid platform requested: ', platform)
	sys.exit(1)

run_result = subprocess.run (['xcrun', 'simctl', 'list', '--json'],
							 stdout=subprocess.PIPE)

top_dict = json.loads (run_result.stdout)

#

runtimes = top_dict['runtimes']

chosen_runtime = None

for runtime_obj in runtimes:
	if not (runtime_obj['isAvailable'] and runtime_obj['platform'] == platform):
		continue

	if chosen_runtime is None or runtime_obj['version'] > chosen_runtime['version']:
		chosen_runtime = runtime_obj

if chosen_runtime is None:
	print ('No runtime found!')
	sys.exit(1)

runtime_id = chosen_runtime['identifier']

#

devices_dict = top_dict['devices']

if not runtime_id in devices_dict:
	print('Runtime ID ', runtime_id, ' not found in devices dict!')
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
