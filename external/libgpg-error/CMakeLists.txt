cmake_minimum_required(VERSION 3.7)

PROJECT("libgpg-error")

INCLUDE(ExternalProject)


#----------------------------------------------------------------------------
#
# Build the project.
#
ExternalProject_Add(TARGET_libgpg_error
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libgpg-error
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/libgpg-error-1.31.tar.bz2
                    URL_HASH SHA1=2bafad316d4e3e12bae4822b14ed9020090e6acf
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libgpg-error/src/TARGET_libgpg_error/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --host=${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

SET(LIBGPGERROR_PREFIX       ${CMAKE_CURRENT_BINARY_DIR}/install         CACHE INTERNAL "The complete path to the libgpg-error installation.")
SET(LIBGPGERROR_LIBRARY      ${LIBGPGERROR_PREFIX}/lib/libgpg-error.a    CACHE INTERNAL "The complete path to the libgpg-error library.")
SET(LIBGPGERROR_INCLUDE_DIR  ${LIBGPGERROR_PREFIX}/include               CACHE INTERNAL "The include folder for the libgpg-error library.")
