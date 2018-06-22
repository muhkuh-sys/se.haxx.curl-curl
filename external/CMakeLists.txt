cmake_minimum_required(VERSION 2.8)

PROJECT("external")

INCLUDE(${CMAKE_HOME_DIRECTORY}/../cmake/platform.cmake)

#----------------------------------------------------------------------------
#
# Include the projects in the subdirectories.
#
IF(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	# Windows uses WinSSL.
ELSE(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	# libnettle and gnutls depend on GMP.
	ADD_SUBDIRECTORY(gmp)

	# libnettle needs GMP. gnutls depends on libnettle.
	ADD_SUBDIRECTORY(libnettle)

	# libidn will be needed by gnutls if pk-11 is incuded - some day...
	#ADD_SUBDIRECTORY(libidn)

	# GnuTLS needs libnettle.
	ADD_SUBDIRECTORY(gnutls)
ENDIF(CMAKE_SYSTEM_NAME STREQUAL "Windows")

ADD_SUBDIRECTORY(libgpg-error)
ADD_SUBDIRECTORY(libgcrypt)

# libssh2 depends on gcrypt.
ADD_SUBDIRECTORY(libssh2)

#----------------------------------------------------------------------------
