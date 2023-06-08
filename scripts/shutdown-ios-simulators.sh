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

for device_id in "$IOS_SIMULATOR_DEVICE_ID" "$TVOS_SIMULATOR_DEVICE_ID" "$WATCHOS_SIMULATOR_DEVICE_ID"
do
	xcrun simctl shutdown "$device_id"
	xcrun simctl erase "$device_id"
done

exit 0
