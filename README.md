# linfra

A collection of infrastructure code that provides dev-environment setup for crosscompiling and testing on a variety of platforms.

This repository contains:
* CMake presets
* Environment variable configuration scripts (`.envrc` file for `direnv` on Unix, and batch scripts for Windows)
* CMake utility code
* Utility scripts

This repository is designed to be project-agnostic, and should be usable by a wide range of consuming projects. See
[the usage docs](docs/rst/usage.rst) for more information about using `linfra` in your project.

The ultimate goal of `linfra` is to enable the following workflow for building and testing for a variety of toolchains and platforms:
```sh
# crosscompile for iOS, run tests on simulator
cmake --preset iOS
cmake --build --preset iOS
ctest --preset iOS

# crosscompile for WebAssembly using Emscripten
cmake --preset emscripten
cmake --build --preset emscripten
ctest --preset emscripten
```
