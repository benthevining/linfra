***************************************
Using linfra
***************************************

``linfra`` is used by the various Limes library repositories, but is designed to be as generic as possible, and may be used by any project.

The critical functionality linfra provides consists of:

* CMake presets, which depend on
* :ref:`Environment variables <env-vars>` (configured using ``direnv``)
* :ref:`CMake utility code <cmake-modules>` (mostly to make tests work on all target platforms)

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

Some CMake configuration is needed to get test executables building and running for all platforms. See the :ref:`LimesTesting <testing-cmake>`
module for documentation of the relevant functions.
