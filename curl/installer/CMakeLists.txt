CMAKE_MINIMUM_REQUIRED(VERSION 3.0)

PROJECT("se.haxx.curl-curl-artifact")

INCLUDE(../../cmake/version.cmake)

SET(INSTALL_WINDOWS_x86        ${CMAKE_CURRENT_SOURCE_DIR}/../../build/windows_x86)
SET(INSTALL_WINDOWS_x86_64     ${CMAKE_CURRENT_SOURCE_DIR}/../../build/windows_x86_64)
SET(INSTALL_UBUNTU_1204_x86    ${CMAKE_CURRENT_SOURCE_DIR}/../../build/ubuntu_1204_x86)
SET(INSTALL_UBUNTU_1204_x86_64 ${CMAKE_CURRENT_SOURCE_DIR}/../../build/ubuntu_1204_x86_64)
SET(INSTALL_UBUNTU_1404_x86    ${CMAKE_CURRENT_SOURCE_DIR}/../../build/ubuntu_1404_x86)
SET(INSTALL_UBUNTU_1404_x86_64 ${CMAKE_CURRENT_SOURCE_DIR}/../../build/ubuntu_1404_x86_64)
SET(INSTALL_UBUNTU_1604_x86    ${CMAKE_CURRENT_SOURCE_DIR}/../../build/ubuntu_1604_x86)
SET(INSTALL_UBUNTU_1604_x86_64 ${CMAKE_CURRENT_SOURCE_DIR}/../../build/ubuntu_1604_x86_64)
SET(INSTALL_UBUNTU_1610_x86    ${CMAKE_CURRENT_SOURCE_DIR}/../../build/ubuntu_1610_x86)
SET(INSTALL_UBUNTU_1610_x86_64 ${CMAKE_CURRENT_SOURCE_DIR}/../../build/ubuntu_1610_x86_64)

# Set the package version.
SET(VERSION_PACKAGE "0")

# Get the version from one of the packages.
SET(CURL_DIR "${INSTALL_WINDOWS_x86}/cmake")
FIND_PACKAGE("CURL" REQUIRED CONFIG)
SET(PROJECT_VERSION "${CURL_VERSION}.${VERSION_PACKAGE}")


SET(CPACK_OUTPUT_FILE_PREFIX targets/jonchki/repository/se/haxx/curl/curl/${PROJECT_VERSION})
SET(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
SET(CPACK_PACKAGE_FILE_NAME "curl-${PROJECT_VERSION}")

SET(CPACK_GENERATOR "ZIP")
INCLUDE(CPack)


#-----------------------------------------------------------------------------
#
# Install the Windows_x86 files.
#
INSTALL(FILES ${INSTALL_WINDOWS_x86}/lib/libcurl.a
        DESTINATION windows_x86/dev/lib
)

INSTALL(DIRECTORY ${INSTALL_WINDOWS_x86}/include/curl
        DESTINATION windows_x86/dev/include
        FILES_MATCHING PATTERN "*.h"
)

INSTALL(DIRECTORY ${INSTALL_WINDOWS_x86}/cmake
        DESTINATION windows_x86/dev
        FILES_MATCHING PATTERN "*.cmake"
)


#-----------------------------------------------------------------------------
#
# Install the Windows_x86_64 files.
#
INSTALL(FILES ${INSTALL_WINDOWS_x86_64}/lib/libcurl.a
        DESTINATION windows_x86_64/dev/lib
)

INSTALL(DIRECTORY ${INSTALL_WINDOWS_x86_64}/include/curl
        DESTINATION windows_x86_64/dev/include
        FILES_MATCHING PATTERN "*.h"
)

INSTALL(DIRECTORY ${INSTALL_WINDOWS_x86_64}/cmake
        DESTINATION windows_x86_64/dev
        FILES_MATCHING PATTERN "*.cmake"
)


#-----------------------------------------------------------------------------
#
# Install the Ubuntu_1204_x86 files.
#
INSTALL(FILES ${INSTALL_UBUNTU_1204_x86}/lib/libcurl.a
        DESTINATION ubuntu_1204_x86/dev/lib
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1204_x86}/include/curl
        DESTINATION ubuntu_1204_x86/dev/include
        FILES_MATCHING PATTERN "*.h"
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1204_x86}/cmake
        DESTINATION ubuntu_1204_x86/dev
        FILES_MATCHING PATTERN "*.cmake"
)


#-----------------------------------------------------------------------------
#
# Install the Ubuntu_1204_x86_64 files.
#
INSTALL(FILES ${INSTALL_UBUNTU_1204_x86_64}/lib/libcurl.a
        DESTINATION ubuntu_1204_x86_64/dev/lib
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1204_x86_64}/include/curl
        DESTINATION ubuntu_1204_x86_64/dev/include
        FILES_MATCHING PATTERN "*.h"
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1204_x86_64}/cmake
        DESTINATION ubuntu_1204_x86_64/dev
        FILES_MATCHING PATTERN "*.cmake"
)


#-----------------------------------------------------------------------------
#
# Install the Ubuntu_1404_x86 files.
#
INSTALL(FILES ${INSTALL_UBUNTU_1404_x86}/lib/libcurl.a
        DESTINATION ubuntu_1404_x86/dev/lib
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1404_x86}/include/curl
        DESTINATION ubuntu_1404_x86/dev/include
        FILES_MATCHING PATTERN "*.h"
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1404_x86}/cmake
        DESTINATION ubuntu_1404_x86/dev
        FILES_MATCHING PATTERN "*.cmake"
)


#-----------------------------------------------------------------------------
#
# Install the Ubuntu_1404_x86_64 files.
#
INSTALL(FILES ${INSTALL_UBUNTU_1404_x86_64}/lib/libcurl.a
        DESTINATION ubuntu_1404_x86_64/dev/lib
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1404_x86_64}/include/curl
        DESTINATION ubuntu_1404_x86_64/dev/include
        FILES_MATCHING PATTERN "*.h"
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1404_x86_64}/cmake
        DESTINATION ubuntu_1404_x86_64/dev
        FILES_MATCHING PATTERN "*.cmake"
)


#-----------------------------------------------------------------------------
#
# Install the Ubuntu_1604_x86 files.
#
INSTALL(FILES ${INSTALL_UBUNTU_1604_x86}/lib/libcurl.a
        DESTINATION ubuntu_1604_x86/dev/lib
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1604_x86}/include/curl
        DESTINATION ubuntu_1604_x86/dev/include
        FILES_MATCHING PATTERN "*.h"
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1604_x86}/cmake
        DESTINATION ubuntu_1604_x86/dev
        FILES_MATCHING PATTERN "*.cmake"
)


#-----------------------------------------------------------------------------
#
# Install the Ubuntu_1604_x86_64 files.
#
INSTALL(FILES ${INSTALL_UBUNTU_1604_x86_64}/lib/libcurl.a
        DESTINATION ubuntu_1604_x86_64/dev/lib
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1604_x86_64}/include/curl
        DESTINATION ubuntu_1604_x86_64/dev/include
        FILES_MATCHING PATTERN "*.h"
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1604_x86_64}/cmake
        DESTINATION ubuntu_1604_x86_64/dev
        FILES_MATCHING PATTERN "*.cmake"
)


#-----------------------------------------------------------------------------
#
# Install the Ubuntu_1610_x86 files.
#
INSTALL(FILES ${INSTALL_UBUNTU_1610_x86}/lib/libcurl.a
        DESTINATION ubuntu_1610_x86/dev/lib
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1610_x86}/include/curl
        DESTINATION ubuntu_1610_x86/dev/include
        FILES_MATCHING PATTERN "*.h"
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1610_x86}/cmake
        DESTINATION ubuntu_1610_x86/dev
        FILES_MATCHING PATTERN "*.cmake"
)


#-----------------------------------------------------------------------------
#
# Install the Ubuntu_1610_x86_64 files.
#
INSTALL(FILES ${INSTALL_UBUNTU_1610_x86_64}/lib/libcurl.a
        DESTINATION ubuntu_1610_x86_64/dev/lib
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1610_x86_64}/include/curl
        DESTINATION ubuntu_1610_x86_64/dev/include
        FILES_MATCHING PATTERN "*.h"
)

INSTALL(DIRECTORY ${INSTALL_UBUNTU_1610_x86_64}/cmake
        DESTINATION ubuntu_1610_x86_64/dev
        FILES_MATCHING PATTERN "*.cmake"
)


#-----------------------------------------------------------------------------

INSTALL(FILES install.lua
        DESTINATION .)


CONFIGURE_FILE(curl.xml
               ${CPACK_OUTPUT_FILE_PREFIX}/curl-${PROJECT_VERSION}.xml
               @ONLY)


#-----------------------------------------------------------------------------
#
# Filter the pom.xml file.
#
SET(POM_ARTIFACT_ID  "curl")
SET(POM_GROUP_ID     "se.haxx.curl")
SET(POM_VERSION      "${PROJECT_VERSION}")
SET(POM_PACKAGING    "zip")
CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/pom.xml ${CPACK_OUTPUT_FILE_PREFIX}/pom.xml)
