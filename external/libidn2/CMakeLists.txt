cmake_minimum_required(VERSION 3.7)

PROJECT("libidn2")

SET(LIBIDN2_PREFIX       ${CMAKE_BINARY_DIR}/../build_requirements/jonchki/install/dev CACHE INTERNAL "The complete path to the libidn2 installation.")
SET(LIBIDN2_LIBRARY      idn2                               CACHE INTERNAL "The complete path to the libidn2 library.")
SET(LIBIDN2_INCLUDE_DIR  ${LIBIDN2_PREFIX}/include          CACHE INTERNAL "The include folder for the libidn2 library.")
SET(LIBIDN2_LIB_DIR      ${LIBIDN2_PREFIX}/lib              CACHE INTERNAL "The include folder for the libidn2 library.")
