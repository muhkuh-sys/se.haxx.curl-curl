cmake_minimum_required(VERSION 3.7)

PROJECT("ngtcp2")

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

ExternalProject_Add(TARGET_ngtcp2
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ngtcp2
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/ngtcp2-0.15.0.tar.xz
                    URL_HASH SHA1=7f6a8f672d76b4b551b9cc1979914bbce7e82387
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/ngtcp2/src/TARGET_ngtcp2/configure PKG_CONFIG_PATH=${PKG_CONFIG_PATH} --prefix=${CMAKE_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --enable-lib-only --with-gnutls ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

# libngtcp2 depends in gnutls, libnettle and libidn2.
ADD_DEPENDENCIES(TARGET_ngtcp2 TARGET_gnutls TARGET_libnettle)

SET(LIBNGTCP2_PREFIX         ${CMAKE_BINARY_DIR}/install    CACHE INTERNAL "The complete path to the ngtcp2 installation.")
SET(LIBNGTCP2_LIBRARY        ngtcp2                         CACHE INTERNAL "The complete path to the ngtcp2 library.")
SET(LIBNGTCP2GNUTLS_LIBRARY  ngtcp2_crypto_gnutls           CACHE INTERNAL "The complete path to the ngtcp2 library.")
SET(LIBNGTCP2_INCLUDE_DIR    ${LIBNGTCP2_PREFIX}/include    CACHE INTERNAL "The include folder for the ngtcp2 library.")
SET(LIBNGTCP2_LIB_DIR        ${LIBNGTCP2_PREFIX}/lib        CACHE INTERNAL "The include folder for the ngtcp2 library.")
