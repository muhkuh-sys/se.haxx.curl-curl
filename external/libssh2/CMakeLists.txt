cmake_minimum_required(VERSION 3.2.3)

PROJECT("libssh2")

INCLUDE(ExternalProject)

# Python is used for some test scripts.
FIND_PACKAGE(PythonInterp 2.7 REQUIRED)

SET(VERSION_EXTERNAL "1.9.0")


#----------------------------------------------------------------------------
#
# Build the project.
#
SET(PRJ_CMAKE_ARGS "")

# Do not build shared libraries.
LIST(APPEND PRJ_CMAKE_ARGS "-DBUILD_SHARED_LIBS=OFF")

# Do not build the examples.
LIST(APPEND PRJ_CMAKE_ARGS "-DBUILD_EXAMPLES=OFF")

# Do not run tests.
LIST(APPEND PRJ_CMAKE_ARGS "-DBUILD_TESTING=OFF")

# Add libgcrypt.
LIST(APPEND PRJ_CMAKE_ARGS "-DCRYPTO_BACKEND=Libgcrypt")
LIST(APPEND PRJ_CMAKE_ARGS "-DLIBGCRYPT_LIBRARY=${LIBGCRYPT_LIBRARY}")
LIST(APPEND PRJ_CMAKE_ARGS "-DLIBGCRYPT_INCLUDE_DIR=${LIBGCRYPT_INCLUDE_DIR}")

# Add ZLIB.
LIST(APPEND PRJ_CMAKE_ARGS "-DENABLE_ZLIB_COMPRESSION=ON")
LIST(APPEND PRJ_CMAKE_ARGS "-Dnet.zlib-zlib_DIR=${CMAKE_BINARY_DIR}/../build_requirements/jonchki/install/dev/cmake")

LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
LIST(APPEND PRJ_CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=''")

ExternalProject_Add(TARGET_libssh2
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libssh2-${VERSION_EXTERNAL}
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/libssh2-${VERSION_EXTERNAL}.tar.gz
                    URL_HASH SHA1=21e98282b103307a16792e5e2d4c99beaf0b3b9c
                    PATCH_COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_HOME_DIRECTORY}/cmake/tools/apply_patches.py --working-folder ${CMAKE_CURRENT_BINARY_DIR}/libssh2-${VERSION_EXTERNAL}/src/TARGET_libssh2 --patch-folder ${CMAKE_CURRENT_SOURCE_DIR}/patches --strip 1
                    CMAKE_ARGS ${PRJ_CMAKE_ARGS}
                    INSTALL_COMMAND make install DESTDIR=${CMAKE_CURRENT_BINARY_DIR}/install
                    TEST_AFTER_INSTALL 1
                    TEST_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/install/lib/cmake/libssh2/Libssh2Config.cmake ${CMAKE_CURRENT_BINARY_DIR}/install/lib/cmake/libssh2/LibSSH2Config.cmake
)
