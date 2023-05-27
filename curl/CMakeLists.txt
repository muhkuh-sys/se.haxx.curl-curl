cmake_minimum_required(VERSION 3.2.3)

PROJECT("curl")

INCLUDE(ExternalProject)

# Python is needed for the patch tool.
FIND_PACKAGE(PythonInterp 2.7 REQUIRED)

SET(VERSION_EXTERNAL "8.1.1")
SET(VERSION_PACKAGE  "1")
SET(PROJECT_VERSION  "${VERSION_EXTERNAL}.${VERSION_PACKAGE}")

# Get the VCS version for the jonchki configuration.
INCLUDE(${CMAKE_HOME_DIRECTORY}/cmake/version.cmake)

# Filter the jonchki configuration.
CONFIGURE_FILE(installer/curl.xml
               ${CMAKE_BINARY_DIR}/curl-${PROJECT_VERSION}.xml
               @ONLY)

#----------------------------------------------------------------------------
#
# Build the project.
#

IF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
	#----------------------------------------------------------------------------
	#
	# Construct the host ID for the configure command.
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

	SET(LIBICONV_DIR ${CMAKE_CURRENT_BINARY_DIR}/../../external/libiconv/install)
	MESSAGE("LIBICONV_DIR: ${LIBICONV_DIR}")

	SET(LIBIDN2_DIR ${CMAKE_CURRENT_BINARY_DIR}/../../external/libidn2/install)
	MESSAGE("LIBIDN2_DIR: ${LIBIDN2_DIR}")

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
		SET(SSL_ENGINE "--with-schannel")

		LIST(APPEND LIBLIST "-lcrypt32")
	ELSE(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		SET(SSL_ENGINE "--with-gnutls=${GNUTLS_DIR}")

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

	# Link to libiconv.
	LIST(APPEND LIBLIST "-liconv")
	LIST(APPEND INCLIST "-I${LIBICONV_DIR}/include")
	LIST(APPEND LDLIST  "-L${LIBICONV_DIR}/lib")

	# Link to libidn2.
	LIST(APPEND INCLIST "-I${LIBIDN2_DIR}/include")
	LIST(APPEND LDLIST  "-L${LIBIDN2_DIR}/lib")

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
	                    URL ${CMAKE_CURRENT_SOURCE_DIR}/curl-${VERSION_EXTERNAL}.tar.xz
	                    URL_HASH SHA1=44a8e2115a8cefb52959d17d6a647389db9e389d
	                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "CPPFLAGS=${P_INCLIST}" "LDFLAGS=${P_LDLIST}" "LIBS=${P_LINK_LIBRARIES}" ${CMAKE_CURRENT_BINARY_DIR}/libcurl/src/TARGET_libcurl/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --enable-crypto-auth --enable-sspi --enable-tls-srp --with-zlib=${ZLIB_DIR} ${SSL_ENGINE} --without-gssapi --with-libssh2=${LIBSSH2_DIR} --with-libidn2 --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt --host=${CONFIGURE_HOST}
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

	#----------------------------------------------------------------------------
	#
	# Build a package for the selected platform.
	#

	SET(CPACK_OUTPUT_FILE_PREFIX ${CMAKE_BINARY_DIR}/../../repository/se/haxx/curl/curl/${PROJECT_VERSION})
	SET(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
	SET(CPACK_PACKAGE_FILE_NAME "curl-${PROJECT_VERSION}-${JONCHKI_PLATFORM}")

	SET(CPACK_GENERATOR "TXZ")
	INCLUDE(CPack)

	IF(${JONCHKI_PLATFORM_DIST_ID} STREQUAL "windows")
		# Package a windows build.

		CONFIGURE_FILE(installer/install_windows.lua
		               ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
		               @ONLY)

		INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
		        DESTINATION .)
	ELSE(${JONCHKI_PLATFORM_DIST_ID} STREQUAL "windows")
		# Package a linux build.

		CONFIGURE_FILE(installer/install_linux.lua
		               ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
		               @ONLY)

		INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
		        DESTINATION .)
	ENDIF(${JONCHKI_PLATFORM_DIST_ID} STREQUAL "windows")

	CONFIGURE_FILE(installer/curl.xml
	               ${CPACK_OUTPUT_FILE_PREFIX}/curl-${PROJECT_VERSION}-${JONCHKI_PLATFORM}.xml
	               @ONLY)


	#-----------------------------------------------------------------------------
	#
	# Create a custom target named "pack".
	# It builds the package and creates the hashes.
	#
	ADD_CUSTOM_TARGET(pack
	                  COMMAND ${CMAKE_MAKE_PROGRAM}
	                  COMMAND ${CMAKE_MAKE_PROGRAM} package
	                  COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/generate_hash.py ${CPACK_OUTPUT_FILE_PREFIX}/curl-${PROJECT_VERSION}-${JONCHKI_PLATFORM}.xml
	                  COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/generate_hash.py ${CPACK_OUTPUT_FILE_PREFIX}/curl-${PROJECT_VERSION}-${JONCHKI_PLATFORM}.tar.xz
	                  COMMENT "Pack the artifact and generate the hashes...")


	#-----------------------------------------------------------------------------
	#
	# Filter the pom.xml file.
	#
	SET(POM_ARTIFACT_ID  "curl")
	SET(POM_GROUP_ID     "se.haxx.curl")
	SET(POM_VERSION      "${PROJECT_VERSION}")
	SET(POM_PACKAGING    "tar.xz")
	CONFIGURE_FILE(installer/pom.xml
	               ${CPACK_OUTPUT_FILE_PREFIX}/curl-${PROJECT_VERSION}.pom
	               @ONLY)
ENDIF((${BUILDCFG_ONLY_JONCHKI_CFG} STREQUAL "OFF"))
