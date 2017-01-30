cmake_minimum_required(VERSION 3.7)

PROJECT("libgmp")

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


ExternalProject_Add(TARGET_libgmp
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libgmp
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/gmp-6.1.2.tar.bz2
                    URL_HASH SHA1=366ded6a44cd108ba6b3f5b9a252eab3f3a95cdf
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libgmp/src/TARGET_libgmp/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --enable-fat --with-pic ${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

SET(LIBGMP_PREFIX       ${CMAKE_CURRENT_BINARY_DIR}/install         CACHE INTERNAL "The complete path to the libgmp installation.")
SET(LIBGMP_LIBRARY_DIR  ${LIBGMP_PREFIX}/lib                        CACHE INTERNAL "The complete path to the libgmp library.")
SET(LIBGMP_LIBRARY      ${LIBGMP_LIBRARY_DIR}/libgmp.a              CACHE INTERNAL "The complete path to the libgmp library.")
SET(LIBGMP_INCLUDE_DIR  ${LIBGMP_PREFIX}/include                    CACHE INTERNAL "The include folder for the libgmp library.")
