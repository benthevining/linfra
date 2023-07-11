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

cmake_minimum_required (VERSION 3.25 FATAL_ERROR)

project (
    linfra
    VERSION 0.0.1
    DESCRIPTION "CMake project utilities"
    HOMEPAGE_URL "https://github.com/benthevining/linfra"
    LANGUAGES NONE)

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/modules")

include (LimesUtil)
include (LimesTesting)
include (LimesDocs)
include (LimesMull)

option (LINFRA_DOCS "Build the linfra docs" "${PROJECT_IS_TOP_LEVEL}")

mark_as_advanced (LINFRA_DOCS)

if (LINFRA_DOCS)
    add_subdirectory (docs)
endif ()
