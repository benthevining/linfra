***************************************
WATCHOS_SIMULATOR_DEVICE_ID
***************************************

.. cmake:envvar:: WATCHOS_SIMULATOR_DEVICE_ID

.. include:: env-var.txt

This variable tells the ``watchOS`` CMake preset what simulator device ID to use for running presets (via the ``test-ios.sh`` script).
Note that this environment variable is read by the CMake preset at configure time, so in order for changing the environment variable
to take effect, you must reconfigure CMake. This variable is initialized by ``direnv`` by parsing the output of
``xcrun simctl list --json`` to find the most recent available runtime and device type.
