cmake_minimum_required(VERSION 3.2.3)

PROJECT("curl")

INCLUDE(ExternalProject)

# Python is needed for the patch tool.
FIND_PACKAGE(PythonInterp 2.7 REQUIRED)

SET(VERSION_EXTERNAL "7.51.0")
SET(VERSION_PACKAGE  "1")
SET(PROJECT_VERSION  "${VERSION_EXTERNAL}.${VERSION_PACKAGE}")

# Get the VCS version for the jonchki configuration.
INCLUDE(${CMAKE_HOME_DIRECTORY}/cmake/version.cmake)

# Filter the jonchki configuration.
CONFIGURE_FILE(installer/curl.xml
               ${CMAKE_CURRENT_BINARY_DIR}/curl-${PROJECT_VERSION}.xml
               @ONLY)

#----------------------------------------------------------------------------
#
# Build the project.
#

IF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
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

	# Get the includes and library for libssh2.
	# Include folders are in LIBSSH2_INCLUDE_DIR .
	# Library is in LIBSSH2_LIBRARY
	FIND_PACKAGE(LibSSH2 REQUIRED CONFIG)
	GET_TARGET_PROPERTY(LIBSSH2_LIBRARY Libssh2::libssh2 LOCATION)
	GET_TARGET_PROPERTY(LIBSSH2_INCLUDE_DIR Libssh2::libssh2 INTERFACE_INCLUDE_DIRECTORIES)
	MESSAGE("LIBSSH2_LIBRARY: ${LIBSSH2_LIBRARY}")
	MESSAGE("LIBSSH2_INCLUDE_DIR: ${LIBSSH2_INCLUDE_DIR}")
	SET(LIBSSH2_DIR ${LIBSSH2_INCLUDE_DIR}/..)

	# Get the includes and library for zlib.
	MESSAGE("net.zlib-zlib_DIR: ${net.zlib-zlib_DIR}")
	FIND_PACKAGE(net.zlib-zlib REQUIRED CONFIG)
	GET_TARGET_PROPERTY(ZLIB_LIBRARIES net.zlib-zlib::zlibstatic LOCATION)
	SET(ZLIB_INCLUDE_DIRS ${net.zlib-zlib_INCLUDE_DIR})
	MESSAGE("ZLIB_LIBRARIES: ${ZLIB_LIBRARIES}")
	MESSAGE("ZLIB_INCLUDE_DIRS: ${ZLIB_INCLUDE_DIRS}")
	SET(ZLIB_DIR ${ZLIB_INCLUDE_DIRS}/..)

	SET(GNUTLS_DIR ${CMAKE_CURRENT_BINARY_DIR}/../../external/gnutls/install)
	MESSAGE("GNUTLS_DIR: ${GNUTLS_DIR}")
	# Set the link flags for the GnuTLS library.
	IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		# Windows builds need Crypt32 to access the certificate store.
		SET(GNUTLS_LINKFLAGS  "-lcrypt32")
		SET(SYSTEM_LIBRARIES  "-lmsvcrt -ladvapi32 -lshell32 -luser32 -lkernel32 -lwldap32 -lwinmm -lws2_32")
	ELSE(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		SET(GNUTLS_LINKFLAGS  "")
		SET(SYSTEM_LIBRARIES  "")
	ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")


	ExternalProject_Add(TARGET_libcurl
	                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libcurl
	                    URL ${CMAKE_CURRENT_SOURCE_DIR}/curl-${VERSION_EXTERNAL}.tar.bz2
	                    URL_HASH SHA1=f02a14bbe580d2a8cf3bf45a79d39eb595220ac7
	                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "CPPFLAGS=-I${LIBSSH2_DIR}/include -I${LIBGCRYPT_DIR}/include -I${LIBNETTLE_DIR}/include -I${LIBGMP_DIR}/include -I${ZLIB_DIR}/include" "LDFLAGS=-L${LIBSSH2_DIR}/lib -L${LIBGCRYPT_DIR}/lib -L${LIBNETTLE_DIR}/lib -L${LIBGMP_DIR}/lib -L${ZLIB_DIR}/lib" "LIBS=-lssh2 -lgcrypt ${GNUTLS_LINKFLAGS} -lhogweed -lnettle -lgmp -lz" ${CMAKE_CURRENT_BINARY_DIR}/libcurl/src/TARGET_libcurl/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --enable-crypto-auth --enable-tls-srp --with-zlib=${ZLIB_DIR} --without-ssl --without-winssl --without-gssapi --with-gnutls=${GNUTLS_DIR} --with-libssh2=${LIBSSH2_DIR} ${CONFIGURE_HOST}
	                    BUILD_COMMAND make
	                    INSTALL_COMMAND make install
	)



	INCLUDE(CMakePackageConfigHelpers)

	SET(PROJECT_VERSION ${VERSION_EXTERNAL})
	SET(LIBRARY_INSTALL_DIR "lib")
	SET(P_LIBRARY_NAME "libcurl.a")
	SET(INCLUDE_INSTALL_DIR "include")
	SET(LIB_NAME "curl")
	SET(P_LINK_LIBRARIES "-lssh2 -lgcrypt ${GNUTLS_LINKFLAGS} -lhogweed -lnettle -lgmp -lz ${SYSTEM_LIBRARIES}")
	CONFIGURE_PACKAGE_CONFIG_FILE(config.cmake.in
	                              "${CMAKE_CURRENT_BINARY_DIR}/package/${PROJECT_NAME}-config.cmake"
	                              INSTALL_DESTINATION cmake
	                              PATH_VARS LIBRARY_INSTALL_DIR INCLUDE_INSTALL_DIR
	)

	WRITE_BASIC_PACKAGE_VERSION_FILE("${CMAKE_CURRENT_BINARY_DIR}/package/${PROJECT_NAME}-version.cmake"
	        COMPATIBILITY ExactVersion
	)

	INSTALL(FILES "${CMAKE_CURRENT_BINARY_DIR}/package/${PROJECT_NAME}-config.cmake" "${CMAKE_CURRENT_BINARY_DIR}/package/${PROJECT_NAME}-version.cmake"
	        DESTINATION cmake
	        COMPONENT Devel
	)
	INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/install/lib/libcurl.a ${LIBGCRYPT_DIR}/lib/libgcrypt.a ${LIBSSH2_LIBRARY} ${GNUTLS_DIR}/lib/libgnutls.a ${LIBNETTLE_DIR}/lib/libhogweed.a ${LIBNETTLE_DIR}/lib/libnettle.a ${LIBGMP_DIR}/lib/libgmp.a
	        DESTINATION lib
	)
	INSTALL(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/install/include/
	        DESTINATION include
	)
ENDIF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
