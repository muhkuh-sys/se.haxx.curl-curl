cmake_minimum_required(VERSION 3.7)

PROJECT("gnutls")

INCLUDE(ExternalProject)

# Python is used for the patch script.
FIND_PACKAGE(Python3 REQUIRED COMPONENTS Interpreter)
SET(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")

#----------------------------------------------------------------------------
#
# Build the project.
#
ExternalProject_Add(TARGET_gnutls
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gnutls
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/gnutls-3.7.9.tar.xz
                    URL_HASH SHA1=8896a303b70481dbfa6e3824a0d62ccd36acad29
#                    PATCH_COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/apply_patches.py --working-folder ${CMAKE_CURRENT_BINARY_DIR}/gnutls/src/TARGET_gnutls --patch-folder ${CMAKE_CURRENT_SOURCE_DIR}/patches --strip 1
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gnutls/src/TARGET_gnutls/configure PKG_CONFIG_PATH=${PKG_CONFIG_PATH} GMP_CFLAGS=-I${LIBGMP_INCLUDE_DIR} GMP_LIBS=-L${LIBGMP_LIB_DIR} --prefix=${CMAKE_BINARY_DIR}/install --disable-tools --disable-tests --enable-static=yes --enable-shared=no --with-pic --with-included-libtasn1 --with-included-unistring --enable-ssl3-support --without-p11-kit --host=${CONFIGURE_HOST} --with-libz-prefix=${ZLIB_PREFIX}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

# gnutls depends on libnettle and libidn2.
ADD_DEPENDENCIES(TARGET_gnutls TARGET_libnettle TARGET_libidn2)

SET(LIBGNUTLS_PREFIX       ${CMAKE_BINARY_DIR}/install            CACHE INTERNAL "The complete path to the libgnutls installation.")
SET(LIBGNUTLS_LIBRARY      gnutls                                 CACHE INTERNAL "The complete path to the libgnutls library.")
SET(LIBGNUTLS_LIB_DIR      ${LIBGNUTLS_PREFIX}/lib                CACHE INTERNAL "The complete path to the libgnutls library.")
SET(LIBGNUTLS_INCLUDE_DIR  ${LIBGNUTLS_PREFIX}/include            CACHE INTERNAL "The include folder for the libgnutls library.")
