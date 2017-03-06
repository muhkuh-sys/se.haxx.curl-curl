cmake_minimum_required(VERSION 2.8)

PROJECT("external")

#----------------------------------------------------------------------------
#
# Set custom definitions for several compiler.
#

# Microsoft: Do not show msvs security warnings about unsafe functions.
IF(${CMAKE_BUILD_TOOL} MATCHES "(msdev|VCExpress|devenv|nmake)")
	ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS)
	ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE)
ENDIF(${CMAKE_BUILD_TOOL} MATCHES "(msdev|VCExpress|devenv|nmake)")


# Microsoft: Set warning level to 2.
if(${CMAKE_BUILD_TOOL} MATCHES "(msdev|VCExpress|devenv)")
	ADD_DEFINITIONS(/W2)
ENDIF(${CMAKE_BUILD_TOOL} MATCHES "(msdev|VCExpress|devenv)")


#----------------------------------------------------------------------------
#
# Include the projects in the subdirectories.
#
IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
	# Windows uses WinSSL.
ELSE(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
	# libnettle and gnutls depend on GMP.
	ADD_SUBDIRECTORY(gmp)

	# libnettle needs GMP. gnutls depends on libnettle.
	ADD_SUBDIRECTORY(libnettle)

	# libidn will be needed by gnutls if pk-11 is incuded - some day...
	#ADD_SUBDIRECTORY(libidn)

	# GnuTLS needs libnettle.
	ADD_SUBDIRECTORY(gnutls)
ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")

ADD_SUBDIRECTORY(libgpg-error)
ADD_SUBDIRECTORY(libgcrypt)

# libssh2 depends on gcrypt.
ADD_SUBDIRECTORY(libssh2)

#----------------------------------------------------------------------------
