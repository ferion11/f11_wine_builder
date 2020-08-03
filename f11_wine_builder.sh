#!/bin/bash
# nehalem go up to sse4.2
export C_COMPILER="gcc-9"
export CXX_COMPILER="g++-9"
export CFLAGS="-march=nehalem -O2 -pipe -ftree-vectorize -fno-stack-protector"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed"

#export WINE_BUILD_OPTIONS="--without-curses --without-oss --without-mingw --disable-winemenubuilder --disable-win16 --disable-tests"
export WINE_BUILD_OPTIONS="--without-oss --without-mingw --disable-winemenubuilder --disable-win16 --disable-tests"
export WINE_VERSION="$1"

GENTOO_PATCH_VERSION="20200523"
SDL2_VERSION="2.0.12"
FAUDIO_VERSION="20.08"
VULKAN_VERSION="1.2.145"
SPIRV_VERSION="1.5.3"

#=================================================
die() { echo >&2 "$*"; exit 1; };
#=================================================

echo "* Getting gentoo wine patchs for winegcc.patch:"
wget -c "https://dev.gentoo.org/~sarnex/distfiles/wine/gentoo-wine-patches-${GENTOO_PATCH_VERSION}.tar.xz"
tar xf "gentoo-wine-patches-${GENTOO_PATCH_VERSION}.tar.xz" || die "* Cant extract the gentoo patchs"

echo "* Install deps:"
sudo apt-get -y build-dep wine-development libsdl2 libvulkan1 xz-utils || die "* apt-get error!"
sudo apt-get -y install libusb-1.0-0-dev libgcrypt20-dev libpulse-dev libudev-dev libsane-dev libv4l-dev libkrb5-dev libgphoto2-dev liblcms2-dev libpcap-dev libcapi20-dev || die "* apt-get error!"
sudo apt-get -y purge libvulkan-dev libvulkan1 libsdl2-dev libsdl2-2.0-0 --purge --autoremove || die "* apt-get error!"
sudo apt-get -y clean || die "* apt-get error!"
sudo apt-get -y autoclean || die "* apt-get error!"

echo "* compile and install more deps:"
mkdir "$HOME/build_libs"
cd "$HOME/build_libs" || die "* Cant enter on dir build_libs!"

echo "* downloading all:"
wget "https://www.libsdl.org/release/SDL2-${SDL2_VERSION}.tar.gz"
wget "https://github.com/FNA-XNA/FAudio/archive/${FAUDIO_VERSION}.tar.gz" -O "FAudio-${FAUDIO_VERSION}.tar.gz"
wget "https://github.com/KhronosGroup/Vulkan-Headers/archive/v${VULKAN_VERSION}.tar.gz" -O "Vulkan-Headers-${VULKAN_VERSION}.tar.gz"
wget "https://github.com/KhronosGroup/Vulkan-Loader/archive/v${VULKAN_VERSION}.tar.gz" -O "Vulkan-Loader-${VULKAN_VERSION}.tar.gz"
wget "https://github.com/KhronosGroup/SPIRV-Headers/archive/${SPIRV_VERSION}.tar.gz"  -O "SPIRV-Headers-${SPIRV_VERSION}.tar.gz"
#git clone --depth 1 https://github.com/HansKristian-Work/vkd3d-proton.git

echo "* extracting:"
tar xf "SDL2-${SDL2_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "FAudio-${FAUDIO_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "Vulkan-Headers-${VULKAN_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "Vulkan-Loader-${VULKAN_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "SPIRV-Headers-${SPIRV_VERSION}.tar.gz" || die "* extract tar.gz error!"

build_and_install() {
	echo "* Building and installing: $1"
	mkdir build
	cd build || die "* Cant enter on build dir!"
	cmake ../"$1"
	make -j"$(nproc)" || die "* Cant make $1!"
	sudo make install || die "* Cant install $1!"
	cd ../ && sudo rm -r build
}

build_and_install "SDL2-${SDL2_VERSION}"
build_and_install "FAudio-${FAUDIO_VERSION}"
build_and_install "Vulkan-Headers-${VULKAN_VERSION}"
build_and_install "Vulkan-Loader-${VULKAN_VERSION}"
build_and_install "SPIRV-Headers-${SPIRV_VERSION}"
# Need libvkd3d-dev package that refuse to install on bionic
#echo "* widl workaround for vkd3d-proton"
#wget https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-i386/wine-stable_4.0.3~bionic_i386.deb
#dpkg -x wine.deb .
#cp ./opt/wine-stable/bin/widl /usr/bin/
#cd vkd3d-proton || die "* Cant enter on vkd3d-proton dir!"
#./autogen.sh
#./configure || die "* vkd3d-proton configure error!"
#make -j"$(nproc)" || die "* vkd3d-proton make error!"
#sudo make install || die "* vkd3d-proton install error!"

cd "$HOME" || die "Cant enter on $HOME dir!"
rm -rf "$HOME/build_libs"
#==============================================================================
echo "* Wine part:"
echo "* Getting wine source and patch:"
wget "https://dl.winehq.org/wine/source/5.x/wine-${WINE_VERSION}.tar.xz"
tar xf "wine-${WINE_VERSION}.tar.xz" || die "* cant extract wine!"
mv "wine-${WINE_VERSION}" "wine-src" || die "* cant rename wine-src!"

wget "https://github.com/wine-staging/wine-staging/archive/v${WINE_VERSION}.tar.gz"
tar xf "v${WINE_VERSION}.tar.gz" || die "* cant extract wine-staging patchs!"
"./wine-staging-${WINE_VERSION}/patches/patchinstall.sh" DESTDIR="$HOME/wine-src" --all || die "* Cant apply the wine-staging patches!"

echo "* Compiling:"
mkdir "wine-staging"
cd wine-src || die "* Cant enter on the wine-src dir!"
./configure "${WINE_BUILD_OPTIONS}" --prefix "$HOME/wine-staging"
make -j"$(nproc)" || die "* cant make wine!"
make install || die "* cant install wine!"

echo "* Some clean:"
cd "$HOME/wine-staging" || die "* Cant enter on the wine-staging dir!"
rm -r include && rm -r share/applications && rm -r share/man
cd "$HOME" || die "Cant enter on $HOME dir!"

echo "* Strip all binaries and libraries:"
find "$HOME/wine-staging" -type f -exec strip --strip-unneeded {} \;

echo "* Compressing:"
XZ_OPT=-9 tar cvJf "wine-staging-${WINE_VERSION}.tar.xz" wine-staging

mv "wine-staging-${WINE_VERSION}.tar.xz" result/
