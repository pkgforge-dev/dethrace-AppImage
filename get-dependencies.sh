#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake          \
    libdecor       \
    pipewire-audio \
    pipewire-jack  \
    sdl3           \
    shaderc        \
    vulkan-headers

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building dethrace..."
echo "---------------------------------------------------------------"
REPO="https://github.com/Link4Electronics/dethrace"
#if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of dethrace..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone --recursive --depth 1 "$REPO" ./dethrace
#else
#    echo "Making stable build of dethrace..."
#    echo "---------------------------------------------------------------"
#    VERSION=$(git ls-remote --tags --refs --sort='v:refname' "$REPO" | tail -n1 | cut -d/ -f3)
#    git clone --branch "$VERSION" --single-branch --recursive --depth 1 "$REPO" ./dethrace
#fi
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
