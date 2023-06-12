***************************************
Crosscompiling for Emscripten
***************************************

Crosscompiling for Emscripten (WebAssembly) is done using the CMake preset ``emscripten`` and is fairly straightforward. This preset uses the
Emscripten SDK's provided CMake toolchain file and the Ninja Multi-Config generator.

Note that this preset requires the :envvar:`EMSCRIPTEN_ROOT` environment variable to be defined.
