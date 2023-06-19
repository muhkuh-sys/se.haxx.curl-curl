cmake_minimum_required(VERSION 3.7)

PROJECT("libiconv")

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


ExternalProject_Add(TARGET_libiconv
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libiconv
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/libiconv-1.17.tar.gz
                    URL_HASH SHA1=409a6a8c07280e02cc33b65ae871311f4b33077b
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libiconv/src/TARGET_libiconv/configure --prefix=${CMAKE_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

SET(LIBICONV_PREFIX       ${CMAKE_BINARY_DIR}/install          CACHE INTERNAL "The complete path to the libiconv installation.")
SET(LIBICONV_LIBRARY      iconv                                CACHE INTERNAL "The complete path to the libiconv library.")
SET(LIBICONV_INCLUDE_DIR  ${LIBICONV_PREFIX}/include           CACHE INTERNAL "The include folder for the libiconv library.")
SET(LIBICONV_LIB_DIR      ${LIBICONV_PREFIX}/lib               CACHE INTERNAL "The include folder for the libiconv library.")
