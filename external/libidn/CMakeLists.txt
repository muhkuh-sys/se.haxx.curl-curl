cmake_minimum_required(VERSION 3.7)

PROJECT("libidn")

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


ExternalProject_Add(TARGET_libidn
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libidn
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/libidn-1.33.tar.gz
                    URL_HASH SHA1=57872fdc665dcc585e16f4ac0bb35374b1103f7e
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libidn/src/TARGET_libidn/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

SET(LIBIDN_PREFIX       ${CMAKE_CURRENT_BINARY_DIR}/install         CACHE INTERNAL "The complete path to the libgpg-error installation.")
SET(LIBIDN_LIBRARY      ${LIBIDN_PREFIX}/lib/libidn.a    CACHE INTERNAL "The complete path to the libgpg-error library.")
SET(LIBIDN_INCLUDE_DIR  ${LIBIDN_PREFIX}/include               CACHE INTERNAL "The include folder for the libgpg-error library.")
