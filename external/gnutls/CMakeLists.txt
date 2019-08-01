cmake_minimum_required(VERSION 3.7)

PROJECT("gnutls")

INCLUDE(ExternalProject)

# Python is used for the patch script.
FIND_PACKAGE(PythonInterp 2.7 REQUIRED)

#----------------------------------------------------------------------------
#
# Build the project.
#
MESSAGE("LIBGMP_INCLUDE_DIR: ${LIBGMP_INCLUDE_DIR}")
MESSAGE("LIBGMP_LIBRARY: ${LIBGMP_LIBRARY}")
MESSAGE("LIBNETTLE_PREFIX: ${LIBNETTLE_PREFIX}")
MESSAGE("CONFIGURE_HOST: ${CONFIGURE_HOST}")
ExternalProject_Add(TARGET_gnutls
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gnutls
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/gnutls-3.6.9.tar.xz
                    URL_HASH SHA1=4a12757b129562ae92a01ca890ed282050595296
                    PATCH_COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/apply_patches.py --working-folder ${CMAKE_CURRENT_BINARY_DIR}/gnutls/src/TARGET_gnutls --patch-folder ${CMAKE_CURRENT_SOURCE_DIR}/patches --strip 1
                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "CPPFLAGS=-I${LIBGMP_INCLUDE_DIR}" "LDFLAGS=-L${LIBGMP_LIBRARY_DIR}" "PKG_CONFIG_PATH=${LIBNETTLE_PREFIX}/lib/pkgconfig:${LIBNETTLE_PREFIX}/lib64/pkgconfig" ${CMAKE_CURRENT_BINARY_DIR}/gnutls/src/TARGET_gnutls/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --disable-tools --disable-tests --enable-static=yes --enable-shared=no --with-pic --with-included-libtasn1 --with-included-unistring --without-p11-kit --without-idn --host=${CONFIGURE_HOST} --with-libz-prefix=${ZLIB_PREFIX}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)


SET(LIBGNUTLS_PREFIX       ${CMAKE_CURRENT_BINARY_DIR}/install    CACHE INTERNAL "The complete path to the libgnutls installation.")
SET(LIBGNUTLS_LIBRARY      ${LIBGNUTLS_PREFIX}/lib/libgnutls.a    CACHE INTERNAL "The complete path to the libgnutls library.")
SET(LIBGNUTLS_INCLUDE_DIR  ${LIBGNUTLS_PREFIX}/include            CACHE INTERNAL "The include folder for the libgnutls library.")
