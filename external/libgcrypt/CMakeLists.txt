cmake_minimum_required(VERSION 3.7)

PROJECT("libgcrypt")

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


ExternalProject_Add(TARGET_libgcrypt
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libgcrypt
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/libgcrypt-1.8.3.tar.bz2
                    URL_HASH SHA1=13bd2ce69e59ab538e959911dfae80ea309636e3
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libgcrypt/src/TARGET_libgcrypt/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --with-libgpg-error-prefix=${LIBGPGERROR_PREFIX} ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
                    TEST_AFTER_INSTALL 1
                    TEST_COMMAND ${CMAKE_COMMAND} -E copy_directory ${LIBGPGERROR_INCLUDE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/install/include
)

SET(LIBGCRYPT_LIBRARY      ${CMAKE_CURRENT_BINARY_DIR}/install/lib/libgpg-error.a    CACHE INTERNAL "The complete path to the libgpg-error library.")
SET(LIBGCRYPT_INCLUDE_DIR  ${CMAKE_CURRENT_BINARY_DIR}/install/include               CACHE INTERNAL "The include folder for the libgpg-error library.")

