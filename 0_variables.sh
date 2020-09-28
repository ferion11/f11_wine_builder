#!/bin/bash
export WINE_VERSION="5.18"
export STAGING_VERSION="${WINE_VERSION}"
export TKG_GIT_COMMIT="8cb2d6edbf136b8698ad8a8234d6faed825582ae"
export TKG_SRC_FILENAME="wine-tkg-v${WINE_VERSION}-src.tar.gz"

export SDL2_VERSION="2.0.12"
export FAUDIO_VERSION="20.08"
export VULKAN_VERSION="1.2.145"
export SPIRV_VERSION="1.5.3"


export CHROOT_DISTRO="bionic"
export CHROOT_MIRROR="http://archive.ubuntu.com/ubuntu/"

# amd64 or i386
export UBUNTU_ARCH=i386

# nehalem go up to sse4.2
export CFLAGS="-march=nehalem -O2 -pipe -ftree-vectorize -fno-stack-protector"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed"