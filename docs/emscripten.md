# Crosscompiling for Emscripten

Crosscompiling for Emscripten (WebAssembly) is done using the CMake preset `emscripten` and is fairly straightforward. This preset uses the
Emscripten SDK's provided CMake toolchain file and the Ninja Multi-Config generator.

## Environment variables

In order for the `emscripten` CMake preset to use the toolchain file in the Emscripten SDK, it needs to be able to find the path to the Emscripten SDK.
The CMake preset expects the `EMSCRIPTEN_ROOT` environment variable to be set. `direnv` attempts to automatically find this path by running `which emcc`,
but you can override this path using local `.env` or `.envrc.user` files.
