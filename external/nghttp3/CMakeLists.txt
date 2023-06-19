cmake_minimum_required(VERSION 3.7)

PROJECT("nghttp3")

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


ExternalProject_Add(TARGET_nghttp3
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/nghttp3
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/nghttp3-0.11.0.tar.xz
                    URL_HASH SHA1=e37b699dddde564f8097836a344825f84a7b5c19
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/nghttp3/src/TARGET_nghttp3/configure --prefix=${CMAKE_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --enable-lib-only ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

SET(LIBNGHTTP3_PREFIX       ${CMAKE_BINARY_DIR}/install     CACHE INTERNAL "The complete path to the nghttp3 installation.")
SET(LIBNGHTTP3_LIBRARY      nghttp3                         CACHE INTERNAL "The complete path to the nghttp3 library.")
SET(LIBNGHTTP3_INCLUDE_DIR  ${LIBNGHTTP3_PREFIX}/include    CACHE INTERNAL "The include folder for the nghttp3 library.")
SET(LIBNGHTTP3_LIB_DIR      ${LIBNGHTTP3_PREFIX}/lib        CACHE INTERNAL "The include folder for the nghttp3 library.")
