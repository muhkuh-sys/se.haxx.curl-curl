cmake_minimum_required(VERSION 3.7)

PROJECT("libnettle")

INCLUDE(ExternalProject)


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


MESSAGE("LIBGMP_INCLUDE_DIR: ${LIBGMP_INCLUDE_DIR}")
MESSAGE("LIBGMP_LIBRARY_DIR: ${LIBGMP_LIBRARY_DIR}")

ExternalProject_Add(TARGET_libnettle
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libnettle
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/nettle-3.4.tar.gz
                    URL_HASH SHA1=f3c8495b7c43cba9cdd19503e7567095c680b490
                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "LIBS=-lgmp" ${CMAKE_CURRENT_BINARY_DIR}/libnettle/src/TARGET_libnettle/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --enable-pic --with-include-path=${LIBGMP_INCLUDE_DIR} --with-lib-path=${LIBGMP_LIBRARY_DIR} ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

SET(LIBNETTLE_PREFIX       ${CMAKE_CURRENT_BINARY_DIR}/install       CACHE INTERNAL "The complete path to the libnettle installation.")
SET(LIBNETTLE_LIBRARY      ${LIBNETTLE_PREFIX}/lib/libnettle.a       CACHE INTERNAL "The complete path to the libnettle library.")
SET(LIBNETTLE_INCLUDE_DIR  ${LIBNETTLE_PREFIX}/include               CACHE INTERNAL "The include folder for the libnettle library.")
