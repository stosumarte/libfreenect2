#!/bin/bash
#
# Builds the static libfreenect2 that FreenectTD bundles: arm64, macOS 12.4+, Metal / OpenCL / CPU depth,
# VideoToolbox color, TinyThread threading (FreenectV2.cpp relies on its waitForNewFrame behaviour).
# Needs full Xcode (for the Metal compiler), CMake, and Homebrew libusb and jpeg-turbo.
#
# Usage: ./build_freenecttd.sh [path/to/FreenectTD]
# With a path, also copies the library and the public headers into that FreenectTD checkout.

set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
BUILD="$SRC/build-freenecttd"
STAGE="$BUILD/install"

cmake -S "$SRC" -B "$BUILD" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.4 \
    -DENABLE_METAL=ON \
    -DENABLE_OPENCL=ON \
    -DENABLE_OPENGL=OFF \
    -DENABLE_CUDA=OFF \
    -DENABLE_VAAPI=OFF \
    -DENABLE_TEGRAJPEG=OFF \
    -DENABLE_CXX11=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_OPENNI2_DRIVER=OFF \
    -DCMAKE_INSTALL_PREFIX="$STAGE"
cmake --build "$BUILD" --target install -j "$(sysctl -n hw.ncpu)"

# CMake quietly builds without Metal when the Metal compiler can't run; FreenectTD needs it
if ! grep -q "^#define LIBFREENECT2_WITH_METAL_SUPPORT" "$STAGE/include/libfreenect2/config.h"; then
    echo "Built without Metal: install full Xcode (on Xcode 26+ also: xcodebuild -downloadComponent MetalToolchain)" >&2
    exit 1
fi

if [ $# -gt 0 ]; then
    FNTD="$1"
    cp "$STAGE/lib/libfreenect2.a" "$FNTD/include/libs/libfreenect2_0.2.0.a"
    rm -rf "$FNTD/include/headers/libfreenect2"
    cp -R "$STAGE/include/libfreenect2" "$FNTD/include/headers/libfreenect2"
    echo "Copied libfreenect2 $(git -C "$SRC" rev-parse --short HEAD) into $FNTD"
fi
