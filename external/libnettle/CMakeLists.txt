cmake_minimum_required(VERSION 3.7)

PROJECT("libnettle")

INCLUDE(ExternalProject)


#----------------------------------------------------------------------------
#
# Build the project.
#
ExternalProject_Add(TARGET_libnettle
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libnettle
                    URL ${CMAKE_CURRENT_SOURCE_DIR}/nettle-3.9.tar.gz
                    URL_HASH SHA1=308c81e94e2ba333fc39ea4141760a8f0cd19c37
                    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env "LIBS=-lgmp" ${CMAKE_CURRENT_BINARY_DIR}/libnettle/src/TARGET_libnettle/configure --prefix=${CMAKE_BINARY_DIR}/install --enable-static=yes --enable-shared=no --enable-pic --with-include-path=${LIBGMP_INCLUDE_DIR} --with-lib-path=${LIBGMP_LIB_DIR} --host=${CONFIGURE_HOST}
                    BUILD_COMMAND make
                    INSTALL_COMMAND make install
)

# libnettle depends on libGMP.
ADD_DEPENDENCIES(TARGET_libnettle TARGET_libgmp)

SET(LIBNETTLE_PREFIX       ${CMAKE_BINARY_DIR}/install            CACHE INTERNAL "The complete path to the libnettle installation.")
SET(LIBNETTLE_LIBRARY      nettle                                 CACHE INTERNAL "The complete path to the libnettle library.")
SET(LIBHOGWEED_LIBRARY     hogweed                                CACHE INTERNAL "The complete path to the libnettle library.")
SET(LIBNETTLE_INCLUDE_DIR  ${LIBNETTLE_PREFIX}/include            CACHE INTERNAL "The include folder for the libnettle library.")
SET(LIBNETTLE_LIB_DIR      ${LIBNETTLE_PREFIX}/lib64              CACHE INTERNAL "The complete path to the libnettle library.")
