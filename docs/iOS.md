# Crosscompiling (and testing) for iOS

Crosscompiling for iOS-family platforms is done using the CMake presets `iOS`, `tvOS`, `watchOS`, `iOS-device`, `tvOS-device`, and `watchOS-device`.
The presets suffixed with `-device` build for an actual device, and the non-`device` presets build for the iOS simulators.

All of these presets use CMake's `Xcode` generator and are only available on MacOS host systems.

## CMAKE_CROSSCOMPILING_EMULATOR

The `-device` presets do not set `CMAKE_CROSSCOMPILING_EMULATOR`. Running these tests on connected iOS devices is a TODO item, but these executables
cannot be executed on the host system, even by the iOS simulator. Therefore, the non-`device` presets currently do not have CTest presets, and those workflow
presets exclude test steps.

The non-`device` presets set `CMAKE_CROSSCOMPILING_EMULATOR` to the script [`test-ios.sh`](../cmake/test-ios.sh), a harness script that:
* selects the appropriate simulator device for the current target platform (iOS, tvOS, or watchOS)
* boots this simulator device if it isn't already running
* installs the test application on the simulator device
* executes the test application on the simulator device and reports results

See this script file for a more detailed discussion of its internals.

## Environment variables

The IDs of the simulator devices to use for each platform can be specified in the environment variables `IOS_SIMULATOR_DEVICE_ID`, `TVOS_SIMULATOR_DEVICE_ID`,
and `WATCHOS_SIMULATOR_DEVICE_ID`. Note that these environment variables are read by the CMake presets at configure time, so in order for changing these
variables to take effect, you must re-configure CMake. Each of these environment variables are initialized by `direnv`, but you can override them manually from
the command line, or by using local `.env` or `.envrc.user` files. See [`ios.envrc`](../env/ios.envrc) for the definition of the default values.

## CMake internals

To install and run the test executables on simulator devices, we have to build them as `.app` bundles and specify some version information to put in the plist.
The CMake function `limes_configure_test_target()` does this setup work. Also note that the `test-ios.sh` script is currently not correctly capturing the exit
code of the text executable running on the simulator, so we are relying on the `FAIL_REGULAR_EXPRESSION` test property to correctly report failures. This test
property is also initialized by the `limes_configure_test_target()` function.

CMake technically supports building for both the device and simulator within the same build tree, but this is implemented using `xcodebuild`'s ability to expand
`${EFFECTIVE_PLATFORM}` placeholders at build time - meaning that the paths to test executables that CMake sends to the `test-ios.sh` script contain the *literal*
string `${EFFECTIVE_PLATFORM}`, which our script cannot reliably expand (since we cannot know what platform the user selected at build time). The solution to this
is to use separate build trees to build for devices and simulators. This is why there are separate sets of `-device` and non-`device` CMake presets. Each CMake
preset explicitly declares either the device or simulator platform at both configure and build time. Each library's CMakeLists.txt also contains some logic to set
the `XCODE_EMIT_EFFECTIVE_PLATFORM_NAME` global property to `OFF` for our testing purposes.

## Utility scripts

The scripts [`start-ios-simulators.sh`](../scripts/start-ios-simulators.sh) and [`shutdown-ios-simulators.sh`](../scripts/shutdown-ios-simulators.sh) are provided
for developer convenience. These scripts read the `IOS_SIMULATOR_DEVICE_ID`, `TVOS_SIMULATOR_DEVICE_ID`, and `WATCHOS_SIMULATOR_DEVICE_ID` environment variables
and start or shutdown the simulator devices specified by these variables. Usage of both scripts is entirely optional; the normal CMake build-and-test workflow should
"just work" without ever manually running either of these scripts.

Starting simulator devices can take a few moments. If the appropriate simulator device isn't running when `test-ios.sh` is invoked, that script will start the
simulator device, but this can make the build and/or test steps take a bit longer. Run `start-ios-simulators.sh` before running the build to make sure all simulator
devices are running (and could be booted correctly).

Leaving simulator devices running when you're no longer using them can waste your system's resources. The `shutdown-ios-simulators.sh` script will shut down and
erase all three simulators you've used for testing.
