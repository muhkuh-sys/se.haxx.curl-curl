cmake_minimum_required(VERSION 3.7)

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
#	FIND_PACKAGE(LibSSH2 REQUIRED CONFIG)
#	GET_TARGET_PROPERTY(LIBSSH2_LIBRARY Libssh2::libssh2 LOCATION)
#	GET_TARGET_PROPERTY(LIBSSH2_INCLUDE_DIR Libssh2::libssh2 INTERFACE_INCLUDE_DIRECTORIES)
#	MESSAGE("LIBSSH2_LIBRARY: ${LIBSSH2_LIBRARY}")
#	MESSAGE("LIBSSH2_INCLUDE_DIR: ${LIBSSH2_INCLUDE_DIR}")
#	SET(LIBSSH2_DIR ${LIBSSH2_INCLUDE_DIR}/..)

	# Get the includes and library for zlib.
	MESSAGE("net.zlib-zlib_DIR: ${net.zlib-zlib_DIR}")
	FIND_PACKAGE(net.zlib-zlib REQUIRED CONFIG)
	GET_TARGET_PROPERTY(ZLIB_LIBRARIES net.zlib-zlib::zlibstatic LOCATION)
	SET(ZLIB_INCLUDE_DIRS ${net.zlib-zlib_INCLUDE_DIR})
	MESSAGE("ZLIB_LIBRARIES: ${ZLIB_LIBRARIES}")
	MESSAGE("ZLIB_INCLUDE_DIRS: ${ZLIB_INCLUDE_DIRS}")
	SET(ZLIB_DIR ${ZLIB_INCLUDE_DIRS}/..)

	SET(LIBLIST "")
	SET(INCLIST "")
	SET(LDLIST "")

	LIST(APPEND INCLIST "-I${CMAKE_BINARY_DIR}/install/include")
	LIST(APPEND LDLIST  "-L${CMAKE_BINARY_DIR}/install/lib")
	LIST(APPEND LDLIST  "-L${CMAKE_BINARY_DIR}/install/lib64")

	# Link to libssh2.
	LIST(APPEND LIBLIST "-l${LIBSSH2_LIBRARY}")

	# Link to libgcrypt (needed by libssh2).
	LIST(APPEND LIBLIST "-l${LIBGCRYPT_LIBRARY}")

	# Link to libgpg-error (needed by libgcrypt).
	LIST(APPEND LIBLIST "-l${LIBGPGERROR_LIBRARY}")

	SET(SSL_ENGINE "--with-gnutls=${GNUTLS_DIR}")

	# Link to libgnutls.
#	LIST(APPEND LIBLIST "-l${LIBGNUTLS_LIBRARY}")

	# Link to nettle.
	LIST(APPEND LIBLIST "-l${LIBHOGWEED_LIBRARY}")
	LIST(APPEND LIBLIST "-l${LIBNETTLE_LIBRARY}")

	# Link to libgmp (needed by nettle).
	LIST(APPEND LIBLIST "-l${LIBGMP_LIBRARY}")

	# Link to zlib.
	LIST(APPEND LIBLIST "-lz")
	LIST(APPEND INCLIST "-I${ZLIB_DIR}/include")
	LIST(APPEND LDLIST  "-L${ZLIB_DIR}/lib")

	# Link to libidn2.
	LIST(APPEND LIBLIST "-l${LIBIDN2_LIBRARY}")

	# Link to libiconv.
	LIST(APPEND LIBLIST "-l${LIBICONV_LIBRARY}")

	STRING(REPLACE ";" " " P_DIREKT_LINK_LIBRARIES "${LIBLIST}")
	STRING(REPLACE ";" " " P_INCLIST "${INCLIST}")
	STRING(REPLACE ";" " " P_LDLIST "${LDLIST}")

	ExternalProject_Add(TARGET_libcurl
	                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libcurl
	                    URL ${CMAKE_CURRENT_SOURCE_DIR}/curl-${VERSION_EXTERNAL}.tar.xz
	                    URL_HASH SHA1=44a8e2115a8cefb52959d17d6a647389db9e389d
	                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libcurl/src/TARGET_libcurl/configure "PKG_CONFIG_PATH=${PKG_CONFIG_PATH}" "CPPFLAGS=${P_INCLIST}" "LDFLAGS=${P_LDLIST}" "LIBS=${P_DIREKT_LINK_LIBRARIES}" --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --enable-crypto-auth --enable-sspi --enable-tls-srp --with-zlib=${ZLIB_DIR} ${SSL_ENGINE} --without-gssapi --with-libssh2=${LIBSSH2_DIR} --with-libidn2 --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt --enable-websockets --with-nghttp2=${NGHTTP2_DIR} --with-nghttp3=${NGHTTP2_DIR} --with-ngtcp2=${NGTCP2_DIR} --host=${CONFIGURE_HOST}
	                    BUILD_COMMAND make
	                    INSTALL_COMMAND make install
	)

	ADD_DEPENDENCIES(TARGET_libcurl TARGET_gnutls TARGET_nghttp2 TARGET_nghttp3 TARGET_ngtcp2 TARGET_libssh2 TARGET_libgpg_error)

	INCLUDE(CMakePackageConfigHelpers)

	SET(LIBRARY_INSTALL_DIR "lib")
	SET(P_LIBRARY_NAME "libcurl.a")
	SET(P_LINK_LIBRARIES "-l${LIBNGHTTP2_LIBRARY} -l${LIBNGTCP2_LIBRARY} -l${LIBNGTCP2GNUTLS_LIBRARY} -l${LIBNGHTTP3_LIBRARY} -l${LIBGNUTLS_LIBRARY} ${P_DIREKT_LINK_LIBRARIES}")
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
	INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/install/lib/libcurl.a ${LIBGCRYPT_LIB_DIR}/lib${LIBGCRYPT_LIBRARY}.a ${LIBGPGERROR_LIB_DIR}/lib${LIBGPGERROR_LIBRARY}.a ${LIBSSH2_LIB_DIR}/lib${LIBSSH2_LIBRARY}.a
	        DESTINATION lib
	)
	# Install libgnutls, nettle and libgmp.
	INSTALL(FILES ${LIBGNUTLS_LIB_DIR}/lib${LIBGNUTLS_LIBRARY}.a ${LIBNETTLE_LIB_DIR}/lib${LIBHOGWEED_LIBRARY}.a ${LIBNETTLE_LIB_DIR}/lib${LIBNETTLE_LIBRARY}.a ${LIBGMP_LIB_DIR}/lib${LIBGMP_LIBRARY}.a
	        DESTINATION lib
	)
	# Install libnghttp2, libnghttp3, libngtcp2, libidn2 and libiconv.
	INSTALL(FILES ${LIBNGHTTP2_LIB_DIR}/lib${LIBNGHTTP2_LIBRARY}.a ${LIBNGHTTP3_LIB_DIR}/lib${LIBNGHTTP3_LIBRARY}.a ${LIBNGTCP2_LIB_DIR}/lib${LIBNGTCP2_LIBRARY}.a ${LIBNGTCP2_LIB_DIR}/lib${LIBNGTCP2GNUTLS_LIBRARY}.a ${LIBIDN2_LIB_DIR}/lib${LIBIDN2_LIBRARY}.a ${LIBICONV_LIB_DIR}/lib${LIBICONV_LIBRARY}.a
	        DESTINATION lib
	)
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

	CONFIGURE_FILE(installer/install_linux.lua
	               ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
	               @ONLY)

	INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/package/install.lua
	        DESTINATION .)

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
