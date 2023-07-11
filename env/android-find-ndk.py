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
Usage: android-find-ndk.py

This script finds the most recent installed NDK and prints its full path to stdout.

Note that the ANDROID_SDK_ROOT environment variable must be set when this script is invoked.
"""

import os
import sys
from pathlib import Path

sdk_root = os.environ.get ('ANDROID_SDK_ROOT')

if sdk_root is None:
  print ('The environment variable ANDROID_SDK_ROOT must be set!')
  sys.exit (1)

sdk_root = Path (sdk_root)

ndk_root = sdk_root / 'ndk'

if not os.path.isdir(ndk_root):
  print (f'NDK root does not exist at path: {ndk_root}')
  sys.exit(1)

# build list of subdirectories below ndk_root
# we only want 1 layer deep, not recursive
subdirs = []

for _, dirs, _ in os.walk(ndk_root):
  subdirs.extend(dirs)
  break

latest_version = None

for version in subdirs:
  if latest_version is None or version > latest_version:
    latest_version = version

ndk_path = ndk_root / latest_version

if not os.path.isdir(ndk_path):
  print (f'Internal error - deduced NDK path does not exist: {ndk_path}')
  sys.exit(1)

print(ndk_path)
