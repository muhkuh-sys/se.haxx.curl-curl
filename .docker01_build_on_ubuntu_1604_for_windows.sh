#! /bin/bash
set -e

# Get the project directory.
PRJDIR=`pwd`

# Make sure that the "build" folder exists.
# NOTE: do not remove it, maybe there are already components.
mkdir -p ${PRJDIR}/build

# Start the container and get the ID.
# The project directory is mounted at /tmp/work .
ID=`docker run --detach --interactive --volume ${PRJDIR}:/tmp/work mbs_ubuntu_1604 /bin/bash`

# Update the package list to prevent "not found" messages.
docker exec ${ID} bash -c 'apt-get update --assume-yes'

# Install the project specific packages.
docker exec ${ID} bash -c 'apt-get install --assume-yes lua5.1 lua-filesystem lua-expat lua51-mhash lua-curl lua-zip'

# Build the 32bit version.
docker exec ${ID} bash -c 'export PATH=/usr/mingw-w64-i686/bin:${PATH} && cd /tmp/work && bash .build01_windows32.sh'
docker exec ${ID} bash -c 'tar --create --file /tmp/work/build/build_windows_x86.tar.gz --gzip --directory /tmp/work/build/windows32/curl/curl/install .'
docker exec ${ID} bash -c 'chown `stat -c %u:%g /tmp/work` /tmp/work/build/build_windows_x86.tar.gz'

# Build the 64bit version.
docker exec ${ID} bash -c 'export PATH=/usr/mingw-w64-x86_64/bin:${PATH} && cd /tmp/work && bash .build02_windows64.sh'
docker exec ${ID} bash -c 'tar --create --file /tmp/work/build/build_windows_x86_64.tar.gz --gzip --directory /tmp/work/build/windows64/curl/curl/install .'
docker exec ${ID} bash -c 'chown `stat -c %u:%g /tmp/work` /tmp/work/build/build_windows_x86_64.tar.gz'

# Stop and remove the container.
docker stop --time 0 ${ID}
docker rm ${ID}
