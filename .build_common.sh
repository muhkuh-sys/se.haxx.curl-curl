# Do not call this script directly. It is included from the .build??_*.sh files.

echo "PRJ_DIR        = ${PRJ_DIR}"
echo "BUILD_DIR      = ${BUILD_DIR}"
echo "CMAKE_COMPILER = ${CMAKE_COMPILER}"
echo "JONCHKI        = ${JONCHKI}"
echo "JONCHKI_SYSTEM = ${JONCHKI_SYSTEM}"

# Create all folders.
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/external
mkdir -p ${BUILD_DIR}/build_requirements
mkdir -p ${BUILD_DIR}/curl


# Get the build requirements.
pushd ${BUILD_DIR}/build_requirements
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="ON" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}
make
lua5.1 ${JONCHKI} --verbose info --syscfg ${PRJ_DIR}/jonchki/jonchkisys.cfg --prjcfg ${PRJ_DIR}/jonchki/jonchkicfg.xml ${JONCHKI_SYSTEM} --build-dependencies curl/curl-*.xml
popd

# Build the external components.
pushd ${BUILD_DIR}/external
cmake -DBUILDCFG_ONLY_JONCHKI_CFG="ON" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${PRJ_DIR}/external
make
popd

CMAKE_MODULES="-DLibSSH2_DIR='${BUILD_DIR}/external/libssh2/install/lib/cmake/libssh2' -Dnet.zlib-zlib_DIR='${BUILD_DIR}/build_requirements/jonchki/install/dev/cmake' -DLIBGMP_DIR='${BUILD_DIR}/external/gmp/install' -DLIBNETTLE_DIR='${BUILD_DIR}/external/libnettle/install' -DLIBGCRYPT_DIR=${BUILD_DIR}/external/libgcrypt/install -DLIBGPG_ERROR_DIR=${BUILD_DIR}/external/libgpg-error/install"
# Build the CURL library.
pushd ${BUILD_DIR}/curl
cmake -DBUILDCFG_LUA_USE_SYSTEM="OFF" -DCMAKE_INSTALL_PREFIX="" ${CMAKE_COMPILER} ${CMAKE_MODULES} ${PRJ_DIR}
make
make install DESTDIR=${PWD}/install
popd
