cmake_minimum_required(VERSION 3.2.3)

PROJECT("curl")

INCLUDE(ExternalProject)

# Python is needed for the patch tool.
FIND_PACKAGE(PythonInterp 2.7 REQUIRED)

SET(VERSION_EXTERNAL "7.56.1")
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

	SET(LIBLIST "")
	SET(INCLIST "")
	SET(LDLIST "")

	# Link to libssh2.
	LIST(APPEND LIBLIST "-lssh2")
	LIST(APPEND INCLIST "-I${LIBSSH2_DIR}/include")
	LIST(APPEND LDLIST  "-L${LIBSSH2_DIR}/lib")

	# Link to libgcrypt (needed by libssh2).
	LIST(APPEND LIBLIST "-lgcrypt")
	LIST(APPEND INCLIST "-I${LIBGCRYPT_DIR}/include")
	LIST(APPEND LDLIST  "-L${LIBGCRYPT_DIR}/lib")

	# Link to libgpg-error (needed by libgcrypt).
	LIST(APPEND LIBLIST "-lgpg-error")
	LIST(APPEND INCLIST "-I${LIBGPG_ERROR_DIR}/include")
	LIST(APPEND LDLIST  "-L${LIBGPG_ERROR_DIR}/lib")

	# Windows uses WinSSL to get access to the system certificate store.
	# Unix systems use GnuTLS with Nettle.
	IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		SET(SSL_ENGINE0 "--without-ssl")
		SET(SSL_ENGINE1 "--with-winssl")
		SET(SSL_ENGINE2 "--without-gnutls")

		LIST(APPEND LIBLIST "-lcrypt32")
	ELSE(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		SET(SSL_ENGINE0 "--without-ssl")
		SET(SSL_ENGINE1 "--without-winssl")
		SET(SSL_ENGINE2 "--with-gnutls=${GNUTLS_DIR}")

		# Link to libgnutls.
		LIST(APPEND LIBLIST "-lgnutls")
		LIST(APPEND INCLIST "-I${GNUTLS_DIR}/include")
		LIST(APPEND LDLIST  "-L${GNUTLS_DIR}/lib")

		# Link to nettle.
		LIST(APPEND LIBLIST "-lhogweed")
		LIST(APPEND LIBLIST "-lnettle")
		LIST(APPEND INCLIST "-I${LIBNETTLE_DIR}/include")
		LIST(APPEND LDLIST  "-L${LIBNETTLE_DIR}/lib")

		# Link to libgmp (needed by nettle).
		LIST(APPEND LIBLIST "-lgmp")
		LIST(APPEND INCLIST "-I${LIBGMP_DIR}/include")
		LIST(APPEND LDLIST  "-L${LIBGMP_DIR}/lib")
	ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")

	# Link to zlib.
	LIST(APPEND LIBLIST "-lz")
	LIST(APPEND INCLIST "-I${ZLIB_DIR}/include")
	LIST(APPEND LDLIST  "-L${ZLIB_DIR}/lib")

	# Add Windows system libraries.
	IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		LIST(APPEND LIBLIST "-lmsvcrt")
		LIST(APPEND LIBLIST "-ladvapi32")
		LIST(APPEND LIBLIST "-lshell32")
		LIST(APPEND LIBLIST "-luser32")
		LIST(APPEND LIBLIST "-lkernel32")
		LIST(APPEND LIBLIST "-lwldap32")
		LIST(APPEND LIBLIST "-lwinmm")
		LIST(APPEND LIBLIST "-lws2_32")
	ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")

	STRING(REPLACE ";" " " P_LINK_LIBRARIES "${LIBLIST}")
	STRING(REPLACE ";" " " P_INCLIST "${INCLIST}")
	STRING(REPLACE ";" " " P_LDLIST "${LDLIST}")

	ExternalProject_Add(TARGET_libcurl
	                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libcurl
	                    URL ${CMAKE_CURRENT_SOURCE_DIR}/curl-${VERSION_EXTERNAL}.tar.bz2
	                    URL_HASH SHA1=c26bd88fdd5fe5d31a3b9e7a0a6b3dffff3168df
	                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "CPPFLAGS=${P_INCLIST}" "LDFLAGS=${P_LDLIST}" "LIBS=${P_LINK_LIBRARIES}" ${CMAKE_CURRENT_BINARY_DIR}/libcurl/src/TARGET_libcurl/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --enable-crypto-auth --enable-sspi --enable-tls-srp --with-zlib=${ZLIB_DIR} ${SSL_ENGINE0} ${SSL_ENGINE1} ${SSL_ENGINE2} --without-gssapi --with-libssh2=${LIBSSH2_DIR} ${CONFIGURE_HOST}
	                    BUILD_COMMAND make
	                    INSTALL_COMMAND make install
	)



	INCLUDE(CMakePackageConfigHelpers)

	SET(LIBRARY_INSTALL_DIR "lib")
	SET(P_LIBRARY_NAME "libcurl.a")
	SET(INCLUDE_INSTALL_DIR "include")
	SET(LIB_NAME "curl")
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
	INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/install/lib/libcurl.a ${LIBGCRYPT_DIR}/lib/libgcrypt.a ${LIBGPG_ERROR_DIR}/lib/libgpg-error.a ${LIBSSH2_LIBRARY}
	        DESTINATION lib
	)
	IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		# No additional libraries.
	ELSE(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		# Install libgnutls, nettle and libgmp.
		INSTALL(FILES ${GNUTLS_DIR}/lib/libgnutls.a ${LIBNETTLE_DIR}/lib/libhogweed.a ${LIBNETTLE_DIR}/lib/libnettle.a ${LIBGMP_DIR}/lib/libgmp.a
		        DESTINATION lib
		)
	ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
	INSTALL(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/install/include/
	        DESTINATION include
	)
	INSTALL(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/install/bin/
	        DESTINATION bin
	        USE_SOURCE_PERMISSIONS
	)
ENDIF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
