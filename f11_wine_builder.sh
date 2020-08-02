#!/bin/bash
# nehalem go up to sse4.2
export C_COMPILER="gcc-9"
export CXX_COMPILER="g++-9"
export CFLAGS="-march=nehalem -O2 -pipe -ftree-vectorize -fno-stack-protector"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed"

export WINE_BUILD_OPTIONS="--without-curses --without-oss --without-mingw --disable-winemenubuilder --disable-win16 --disable-tests"
export WINE_VERSION="$1"

GENTOO_PATCH_VERSION="20200523"
SDL2_VERSION="2.0.12"
FAUDIO_VERSION="20.08"
VULKAN_VERSION="1.2.148"
SPIRV_VERSION="1.5.3"

#=================================================
die() { echo >&2 "$*"; exit 1; };
#=================================================

echo "* Getting gentoo wine patchs for winegcc.patch:"
wget -c "https://dev.gentoo.org/~sarnex/distfiles/wine/gentoo-wine-patchmkdir build-tools && cd build-tools' >> $MAINDIR/build32.sh
	echo '../wine/configure '${WINE_BUILD_OPTIONSes-${GENTOO_PATCH_VERSION}.tar.xz"
tar xf "gentoo-wine-patches-${GENTOO_PATCH_VERSION}.tar.xz" || die "* Can't extract the gentoo patchs"

echo "* Install deps:"
apt-get -y build-dep wine-development wine-stable:i386 libsdl2 libvulkan1 xz-utils
apt-get -y install libusb-1.0-0-dev libgcrypt20-dev libpulse-dev libudev-dev libsane-dev libv4l-dev libkrb5-dev libgphoto2-dev liblcms2-dev libpcap-dev libcapi20-dev
apt-get -y purge libvulkan-dev libvulkan1 libsdl2-dev libsdl2-2.0-0 --purge --autoremove
apt-get -y clean
apt-get -y autoclean

echo "* compile and install more deps:"
mkdir "$HOME/build_libs"
cd "$HOME/build_libs"

echo "* downloading all:"
wget "https://www.libsdl.org/release/SDL2-${SDL2_VERSION}.tar.gz"
wget "https://github.com/FNA-XNA/FAudio/archive/${FAUDIO_VERSION}.tar.gz" -O "FAudio-${FAUDIO_VERSION}.tar.gz"
wget "https://github.com/KhronosGroup/Vulkan-Headers/archive/v${VULKAN_VERSION}.tar.gz" -O "Vulkan-Headers-${VULKAN_VERSION}.tar.gz"
wget "https://github.com/KhronosGroup/Vulkan-Loader/archive/v${VULKAN_VERSION}.tar.gz" -O "Vulkan-Loader-${VULKAN_VERSION}.tar.gz"
wget "https://github.com/KhronosGroup/SPIRV-Headers/archive/${SPIRV_VERSION}.tar.gz"  -O "SPIRV-Headers-${SPIRV_VERSION}.tar.gz"
git clone --depth 1 https://github.com/HansKristian-Work/vkd3d-proton.git

echo "* extracting:"
tar xf "SDL2-${SDL2_VERSION}.tar.gz"
tar xf "FAudio-${FAUDIO_VERSION}.tar.gz"
tar xf "Vulkan-Headers-${VULKAN_VERSION}.tar.gz"
tar xf "Vulkan-Loader-${VULKAN_VERSION}.tar.gz"
tar xf "SPIRV-Headers-${SPIRV_VERSION}.tar.gz"

build_and_install() {
	echo "* Building and installing: $1"
	mkdir build && cd build
	cmake ../"$1" && make -j$(nproc) && sudo make install
	cd ../ && sudo rm -r build
}

build_and_install "SDL2-${SDL2_VERSION}"
build_and_install "FAudio-${FAUDIO_VERSION}"
build_and_install "Vulkan-Headers-${VULKAN_VERSION}"
build_and_install "Vulkan-Loader-${VULKAN_VERSION}"
build_and_install "SPIRV-Headers-${SPIRV_VERSION}"
cd vkd3d-proton && ./autogen.sh
./configure
make -j$(nproc)
sudo make install

cd "$HOME"
rm -rf "$HOME/build_libs"
#==============================================================================
echo "* Wine part:"
echo "* Getting wine source and patch:"
wget "https://dl.winehq.org/wine/source/5.x/wine-${WINE_VERSION}.tar.xz"
tar xf "wine-${WINE_VERSION}.tar.xz"
mv "wine-{WINE_VERSION}" "wine-src"

wget "https://github.com/wine-staging/wine-staging/archive/v${WINE_VERSION}.tar.gz"
tar xf "v$WINE_VERSION.tar.gz"
"./wine-staging-${WINE_VERSION}/patches/patchinstall.sh" DESTDIR="$HOME/wine-src" --all || die "* Can't apply the wine-staging patches!"

echo "* Compiling:"
mkdir "wine-staging"
cd wine-src && ./configure "${WINE_BUILD_OPTIONS}" --prefix "$HOME/wine-staging"
make -j$(nproc)
make install

echo "* Some clean:"
cd "$HOME/wine-staging" && rm -r include && rm -r share/applications && rm -r share/man && cd "$HOME"

echo "* Strip all binaries and libraries:"
find "$HOME/wine-staging" -type f -exec strip --strip-unneeded {} \;

echo "* Compressing:"
XZ_OPT=-9 tar cvJf "wine-staging-${WINE_VERSION}.tar.xz" wine-staging

mv "wine-staging-${WINE_VERSION}.tar.xz" result/
