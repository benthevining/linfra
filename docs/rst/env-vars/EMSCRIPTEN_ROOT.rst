***************************************
EMSCRIPTEN_ROOT
***************************************

.. cmake:envvar:: EMSCRIPTEN_ROOT

.. include:: env-var.txt

This environment variable tells the ``emscripten`` CMake preset where to find the root of the Emscripten SDK
installation. This variable is required in order to use the ``emscripten`` preset. ``direnv`` attempts to
automatically find this path by running ``which emcc``.
