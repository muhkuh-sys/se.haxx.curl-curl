cmake_minimum_required(VERSION 3.7)

PROJECT("libgmp")

INCLUDE(ExternalProject)


#----------------------------------------------------------------------------
#
# Build the project.
#
ExternalProject_Add(TARGET_libgmp
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libgmp
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/gmp-6.2.0.tar.xz
                    URL_HASH SHA1=052a5411dc74054240eec58132d2cf41211d0ff6
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libgmp/src/TARGET_libgmp/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --enable-fat --with-pic --host=${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

SET(LIBGMP_PREFIX       ${CMAKE_CURRENT_BINARY_DIR}/install         CACHE INTERNAL "The complete path to the libgmp installation.")
SET(LIBGMP_LIBRARY_DIR  ${LIBGMP_PREFIX}/lib                        CACHE INTERNAL "The complete path to the libgmp library.")
SET(LIBGMP_LIBRARY      ${LIBGMP_LIBRARY_DIR}/libgmp.a              CACHE INTERNAL "The complete path to the libgmp library.")
SET(LIBGMP_INCLUDE_DIR  ${LIBGMP_PREFIX}/include                    CACHE INTERNAL "The include folder for the libgmp library.")
