cmake_minimum_required(VERSION 3.7)

PROJECT("libgcrypt")

INCLUDE(ExternalProject)

# Python is used for the patch tool.
FIND_PACKAGE(Python3 REQUIRED COMPONENTS Interpreter)
SET(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")

#----------------------------------------------------------------------------
#
# Build the project.
#
ExternalProject_Add(TARGET_libgcrypt
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libgcrypt
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/libgcrypt-1.10.2.tar.bz2
                    URL_HASH SHA1=0b9555960d84a09ea14e52360808f2e02e9c12d2
#                    PATCH_COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/apply_patches.py --working-folder ${CMAKE_CURRENT_BINARY_DIR}/libgcrypt/src/TARGET_libgcrypt --patch-folder ${CMAKE_CURRENT_SOURCE_DIR}/patches --strip 1
                    CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/libgcrypt/src/TARGET_libgcrypt/configure --prefix=${CMAKE_BINARY_DIR}/install --enable-static=yes --enable-shared=no --with-pic --with-libgpg-error-prefix=${LIBGPGERROR_PREFIX} --host=${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
                    TEST_AFTER_INSTALL 1
                    TEST_COMMAND ${CMAKE_COMMAND} -E copy_directory ${LIBGPGERROR_INCLUDE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/install/include
)

SET(LIBGCRYPT_PREFIX       ${CMAKE_BINARY_DIR}/install               CACHE INTERNAL "The complete path to the libgcrypt installation.")
SET(LIBGCRYPT_LIBRARY      gcrypt                                    CACHE INTERNAL "The complete path to the libgcrypt library.")
SET(LIBGCRYPT_INCLUDE_DIR  ${LIBGCRYPT_PREFIX}/include               CACHE INTERNAL "The include folder for the libgcrypt library.")
SET(LIBGCRYPT_LIB_DIR      ${LIBGCRYPT_PREFIX}/lib                   CACHE INTERNAL "The include folder for the libgcrypt library.")
