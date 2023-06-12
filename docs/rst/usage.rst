***************************************
Using linfra
***************************************

``linfra`` is used by the various Limes library repositories, but is designed to be as generic as possible, and may be used by any project.

The critical functionality linfra provides consists of:

* CMake presets, which depend on
* :ref:`Environment variables <env-vars>` (configured using ``direnv``)
* CMake utility code (mostly to make tests work on all target platforms)

Several of the scripts and files enabling this functionality are required to be at a known path on the filesystem, and cannot easily be
fetched by something like ``CPM.cmake`` or ``FetchContent`` (specifically, the CMake preset json files and the crosscompiling emulator wrapper
scripts) -- therefore, I recommend making linfra a git submodule of your consuming project. This is how the Limes libraries consume linfra.

Assuming linfra is a git submodule at the path ``linfra/``, you can enable linfra's functionality with the following files:

``CMakePresets.json``
################################

	.. code:: json

		{
		  "cmakeMinimumRequired": {
		    "major": 3,
		    "minor": 25,
		    "patch": 0
		  },
		  "include": [
		    "linfra/CMakePresets.json"
		  ],
		  "version": 6
		}

You can simply include linfra's ``CMakePresets.json`` file, which imports all of linfra's provided CMake presets.

``.envrc``
################################

	.. code:: bash

		source_env linfra/.envrc

You can simply source linfra's ``.envrc`` file, which configures all of linfra's environment variables. In order to adopt linfra's convention of
allowing local ``.env`` or ``.envrc.user`` files, your project's ``.envrc`` should look like this:

	.. code:: bash

		source_env linfra/.envrc

		source_env_if_exists .envrc.user
		dotenv_if_exists .env

and you should add ``.env`` and ``.envrc.user`` to your ``.gitignore`` file.


Using linfra for testing
################################

In order to include linfra's provided CMake utility code, you can simply ``add_subdirectory (linfra)``.

On platforms like iOS and Android, only application bundles can be installed and run. You should call :command:`limes_configure_app_bundle()` to build your
test executable as an app bundle that can be executed on iOS and Android simulators.

I also suggest calling the macro :command:`limes_default_project_options()` in your top-level ``CMakeLists.txt`` file. This macro sets the global property
``XCODE_EMIT_EFFECTIVE_PLATFORM_NAME`` to ``OFF`` (which is important, because our iOS crosscompiling emulator script won't work if this option is
on!) if the current project is the top-level project and you're building for iOS. If you're building for Emscripten, this macro also sets some
global options for enabling exceptions.

If you're using Catch2 for testing, I recommend calling the macro :command:`limes_get_catch2()` to populate Catch2. This macro populates Catch2 using
FetchContent, and does a bit of patching where needed:
* XCode signing is disabled before adding the Catch targets
* On tvOS and watchOS, POSIX signals are disabled (Catch won't compile on these platforms otherwise)
* On watchOS, we add the ``-fgnu-inline-asm`` compile flag to Catch (it won't compile otherwise)
* On Emscripten, we add flags to Catch to enable exceptions
* Lastly, this macro includes Catch's provided ``Catch.cmake`` file
