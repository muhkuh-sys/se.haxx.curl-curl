cmake_minimum_required(VERSION 3.7)

PROJECT("libidn2")

INCLUDE(ExternalProject)

FIND_PACKAGE(Python3 REQUIRED COMPONENTS Interpreter)
SET(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")

#----------------------------------------------------------------------------
#
# Build the project.
#

IF(${CMAKE_CROSSCOMPILING})
	IF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
		# Get the prefix of the compiler.
		GET_FILENAME_COMPONENT(GCC_BASENAME ${CMAKE_C_COMPILER} NAME)
		IF(${GCC_BASENAME} MATCHES "([^-]+-[^-]+-[^-]+)-gcc")
			SET(CONFIGURE_HOST "--host=${CMAKE_MATCH_1}")
		ELSE(${GCC_BASENAME} MATCHES "([^-]+-[^-]+-[^-]+)-gcc")
			MESSAGE(FATAL_ERROR "Failed to extract the compiler prefix from the C compiler ${CMAKE_C_COMPILER}")
		ENDIF(${GCC_BASENAME} MATCHES "([^-]+-[^-]+-[^-]+)-gcc")
	ELSE("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
		MESSAGE(FATAL_ERROR "Cross compiling detected, but not using GCC. This is currently not supported by the CMake wrapper for OpenSSL.")
	ENDIF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
ELSE(${CMAKE_CROSSCOMPILING})
	SET(CONFIGURE_HOST "")
ENDIF(${CMAKE_CROSSCOMPILING})


ExternalProject_Add(TARGET_libidn2
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libidn2
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/libidn2-2.3.4.tar.gz
                    URL_HASH SHA1=096e2f170fabdfd7011a1848a43e0fca49e3f2e5
                    PATCH_COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/apply_patches.py --working-folder ${CMAKE_CURRENT_BINARY_DIR}/libidn2/src/TARGET_libidn2 --patch-folder ${CMAKE_CURRENT_SOURCE_DIR}/patches --strip 1
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libidn2/src/TARGET_libidn2/configure --prefix=${CMAKE_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --with-included-libunistring --with-libiconv-prefix=${LIBICONV_PREFIX} ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

# libidn2 depends on libiconv.
ADD_DEPENDENCIES(TARGET_libidn2 TARGET_libiconv)

SET(LIBIDN2_PREFIX       ${CMAKE_BINARY_DIR}/install        CACHE INTERNAL "The complete path to the libidn2 installation.")
SET(LIBIDN2_LIBRARY      idn2                               CACHE INTERNAL "The complete path to the libidn2 library.")
SET(LIBIDN2_INCLUDE_DIR  ${LIBIDN2_PREFIX}/include          CACHE INTERNAL "The include folder for the libidn2 library.")
SET(LIBIDN2_LIB_DIR      ${LIBIDN2_PREFIX}/lib              CACHE INTERNAL "The include folder for the libidn2 library.")
