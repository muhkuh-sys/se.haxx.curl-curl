cmake_minimum_required(VERSION 3.7)

PROJECT("nghttp2")

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


ExternalProject_Add(TARGET_nghttp2
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/nghttp2
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/nghttp2-1.53.0.tar.xz
                    URL_HASH SHA1=640c46a8805f384565bd56988055bf3b0cc58fd4
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/nghttp2/src/TARGET_nghttp2/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

SET(LIBNGHTTP2_PREFIX       ${CMAKE_CURRENT_BINARY_DIR}/install    CACHE INTERNAL "The complete path to the nghttp2 installation.")
SET(LIBNGHTTP2_LIBRARY      ${LIBNGHTTP2_PREFIX}/lib/libnghttp2.a  CACHE INTERNAL "The complete path to the nghttp2 library.")
SET(LIBNGHTTP2_INCLUDE_DIR  ${LIBNGHTTP2_PREFIX}/include           CACHE INTERNAL "The include folder for the nghttp2 library.")
