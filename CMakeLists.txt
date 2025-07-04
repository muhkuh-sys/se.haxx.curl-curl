cmake_minimum_required(VERSION 3.7)

PROJECT("se.haxx.curl-curl")

# Get the VCS version for the jonchki configuration.
INCLUDE(cmake/version.cmake)
INCLUDE(cmake/platform.cmake)
MESSAGE("Building for: ${JONCHKI_PLATFORM}")


# Enable tests (see here for details: http://www.vtk.org/Wiki/CMake/Testing_With_CTest)
ENABLE_TESTING()

# Set some installation folders.
INCLUDE(cmake/muhkuh_installation_folders.cmake)

OPTION(BUILDCFG_ONLY_JONCHKI_CFG "Build only the jonchki configuration. This is used for the resolve phase. The default is OFF."
       "OFF")

SET(PKG_CONFIG_PATH "${CMAKE_BINARY_DIR}/install/lib/pkgconfig:${CMAKE_BINARY_DIR}/install/lib64/pkgconfig")
MESSAGE("PKG_CONFIG_PATH: ${PKG_CONFIG_PATH}")

#----------------------------------------------------------------------------
#
# Find all packages.
#

# Python is used for some test scripts.
FIND_PACKAGE(Python3 REQUIRED COMPONENTS Interpreter)
SET(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")


#----------------------------------------------------------------------------
#
# Include the projects in the subdirectories.
#
IF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
	ADD_SUBDIRECTORY(external)
ENDIF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))

ADD_SUBDIRECTORY(curl)

#----------------------------------------------------------------------------

