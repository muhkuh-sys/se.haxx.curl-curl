cmake_minimum_required(VERSION 3.7)

PROJECT("gnutls")

INCLUDE(ExternalProject)


#----------------------------------------------------------------------------
#
# Build the project.
#

IF(${CMAKE_CROSSCOMPILING})
	IF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		# Get the prefix of the compiler.
		GET_FILENAME_COMPONENT(GCC_BASENAME ${CMAKE_C_COMPILER} NAME)
		IF(GCC_BASENAME MATCHES "([^-]+-[^-]+-[^-]+)-gcc")
			SET(CONFIGURE_HOST "${CMAKE_MATCH_1}")
		ELSE(GCC_BASENAME MATCHES "([^-]+-[^-]+-[^-]+)-gcc")
			MESSAGE(FATAL_ERROR "Failed to extract the compiler prefix from the C compiler ${CMAKE_C_COMPILER}")
		ENDIF(GCC_BASENAME MATCHES "([^-]+-[^-]+-[^-]+)-gcc")
	ELSE(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		MESSAGE(FATAL_ERROR "Cross compiling detected, but not using GCC. This is currently not supported.")
	ENDIF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
ELSE(${CMAKE_CROSSCOMPILING})
	# Set the host even if not cross compiling.
	# Otherwise GNUTLS detects the CPU and tries to build with special
	# support for it. In the first place this sounds very nice. But it
	# fails on a 32bit OS running on a 64bit CPU - which is the case for
	# Docker 32bit images.
	IF(CMAKE_SYSTEM_NAME STREQUAL "Linux")
		IF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
			SET(CONFIGURE_HOST "${JONCHKI_PLATFORM_CPU_ARCH}-pc-linux-gnu")
		ELSE(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
			MESSAGE(FATAL_ERROR "Trying to detect the system with a non-GCC compiler. This is currently not supported.")
		ENDIF(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	ELSE(CMAKE_SYSTEM_NAME STREQUAL "Linux")
		MESSAGE(FATAL_ERROR "Trying to detect the system on a non-linux OS. This is currently not supported.")
	ENDIF(CMAKE_SYSTEM_NAME STREQUAL "Linux")
ENDIF(${CMAKE_CROSSCOMPILING})


MESSAGE("LIBGMP_INCLUDE_DIR: ${LIBGMP_INCLUDE_DIR}")
MESSAGE("LIBGMP_LIBRARY: ${LIBGMP_LIBRARY}")
MESSAGE("LIBNETTLE_PREFIX: ${LIBNETTLE_PREFIX}")
MESSAGE("CONFIGURE_HOST: ${CONFIGURE_HOST}")
ExternalProject_Add(TARGET_gnutls
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gnutls
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/gnutls-3.5.18.tar.xz
                    URL_HASH SHA1=3f56903c4eba1af9440c64ef86688f984834f0d5
                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "GMP_CFLAGS=-I${LIBGMP_INCLUDE_DIR}" "GMP_LIBS=-L${LIBGMP_LIBRARY_DIR}" "PKG_CONFIG_PATH=${LIBNETTLE_PREFIX}/lib/pkgconfig" ${CMAKE_CURRENT_BINARY_DIR}/gnutls/src/TARGET_gnutls/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --disable-tools --disable-tests --enable-static=yes --enable-shared=no --with-pic --with-included-libtasn1 --with-included-unistring --without-p11-kit --without-idn --host=${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)


SET(LIBGNUTLS_PREFIX       ${CMAKE_CURRENT_BINARY_DIR}/install    CACHE INTERNAL "The complete path to the libgnutls installation.")
SET(LIBGNUTLS_LIBRARY      ${LIBGNUTLS_PREFIX}/lib/libgnutls.a    CACHE INTERNAL "The complete path to the libgnutls library.")
SET(LIBGNUTLS_INCLUDE_DIR  ${LIBGNUTLS_PREFIX}/include            CACHE INTERNAL "The include folder for the libgnutls library.")
