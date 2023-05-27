cmake_minimum_required(VERSION 3.7)

PROJECT("libnettle")

INCLUDE(ExternalProject)


#----------------------------------------------------------------------------
#
# Build the project.
#
MESSAGE("LIBGMP_INCLUDE_DIR: ${LIBGMP_INCLUDE_DIR}")
MESSAGE("LIBGMP_LIBRARY_DIR: ${LIBGMP_LIBRARY_DIR}")

ExternalProject_Add(TARGET_libnettle
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libnettle
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/nettle-3.9.tar.gz
                    URL_HASH SHA1=308c81e94e2ba333fc39ea4141760a8f0cd19c37
                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "LIBS=-lgmp" ${CMAKE_CURRENT_BINARY_DIR}/libnettle/src/TARGET_libnettle/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install --enable-static=yes --enable-shared=no --enable-pic --with-include-path=${LIBGMP_INCLUDE_DIR} --with-lib-path=${LIBGMP_LIBRARY_DIR} --host=${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

SET(LIBNETTLE_PREFIX       ${CMAKE_CURRENT_BINARY_DIR}/install       CACHE INTERNAL "The complete path to the libnettle installation.")
SET(LIBNETTLE_LIBRARY      ${LIBNETTLE_PREFIX}/lib/libnettle.a       CACHE INTERNAL "The complete path to the libnettle library.")
SET(LIBNETTLE_INCLUDE_DIR  ${LIBNETTLE_PREFIX}/include               CACHE INTERNAL "The include folder for the libnettle library.")
