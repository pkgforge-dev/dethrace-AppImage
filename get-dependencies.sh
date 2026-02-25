#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake    \
    libdecor \
    sdl3

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
echo "Building dethrace..."
echo "---------------------------------------------------------------"
REPO="https://github.com/dethrace-labs/dethrace"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of dethrace..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone --recursive --depth 1 "$REPO" ./dethrace
else
    echo "Making stable build of dethrace..."
    echo "---------------------------------------------------------------"
    VERSION=$(git ls-remote --tags --refs --sort='v:refname' "$REPO" | tail -n1 | cut -d/ -f3)
    git clone --branch "$VERSION" --single-branch --recursive --depth 1 "$REPO" ./dethrace
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./dethrace
mkdir -p build && cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DDETHRACE_PLATFORM_SDL2=OFF \
    -DDETHRACE_PLATFORM_SDL3=ON
make -j$(nproc)
mv -v dethrace ../../AppDir/bin
cp -rv ../packaging/dethrace.desktop ../../AppDir
