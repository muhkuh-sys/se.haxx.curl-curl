cmake_minimum_required(VERSION 3.7)

PROJECT("libgcrypt")

INCLUDE(ExternalProject)


#----------------------------------------------------------------------------
#
# Build the project.
#
ExternalProject_Add(TARGET_libgcrypt
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libgcrypt
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/libgcrypt-1.8.3.tar.bz2
                    URL_HASH SHA1=13bd2ce69e59ab538e959911dfae80ea309636e3
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libgcrypt/src/TARGET_libgcrypt/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --with-libgpg-error-prefix=${LIBGPGERROR_PREFIX} --host=${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
                    TEST_AFTER_INSTALL 1
                    TEST_COMMAND ${CMAKE_COMMAND} -E copy_directory ${LIBGPGERROR_INCLUDE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/install/include
)

SET(LIBGCRYPT_LIBRARY      ${CMAKE_CURRENT_BINARY_DIR}/install/lib/libgpg-error.a    CACHE INTERNAL "The complete path to the libgpg-error library.")
SET(LIBGCRYPT_INCLUDE_DIR  ${CMAKE_CURRENT_BINARY_DIR}/install/include               CACHE INTERNAL "The include folder for the libgpg-error library.")

