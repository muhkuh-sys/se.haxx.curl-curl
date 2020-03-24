cmake_minimum_required(VERSION 3.7)

PROJECT("libgpg-error")

INCLUDE(ExternalProject)


#----------------------------------------------------------------------------
#
# Build the project.
#
ExternalProject_Add(TARGET_libgpg_error
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libgpg-error
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/libgpg-error-1.37.tar.bz2
                    URL_HASH SHA1=6dff83371e0c03fe9ba468cc23d528a8c247785a
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libgpg-error/src/TARGET_libgpg_error/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --host=${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

SET(LIBGPGERROR_PREFIX       ${CMAKE_CURRENT_BINARY_DIR}/install         CACHE INTERNAL "The complete path to the libgpg-error installation.")
SET(LIBGPGERROR_LIBRARY      ${LIBGPGERROR_PREFIX}/lib/libgpg-error.a    CACHE INTERNAL "The complete path to the libgpg-error library.")
SET(LIBGPGERROR_INCLUDE_DIR  ${LIBGPGERROR_PREFIX}/include               CACHE INTERNAL "The include folder for the libgpg-error library.")
