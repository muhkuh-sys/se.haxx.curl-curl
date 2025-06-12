cmake_minimum_required(VERSION 3.7)

PROJECT("libiconv")

SET(LIBICONV_PREFIX       ${CMAKE_BINARY_DIR}/../build_requirements/jonchki/install/dev    CACHE INTERNAL "The complete path to the libiconv installation.")
SET(LIBICONV_LIBRARY      iconv                                CACHE INTERNAL "The complete path to the libiconv library.")
SET(LIBICONV_INCLUDE_DIR  ${LIBICONV_PREFIX}/include           CACHE INTERNAL "The include folder for the libiconv library.")
SET(LIBICONV_LIB_DIR      ${LIBICONV_PREFIX}/lib               CACHE INTERNAL "The include folder for the libiconv library.")
