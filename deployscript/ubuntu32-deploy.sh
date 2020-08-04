#!/bin/bash
#export WINE_BUILD_OPTIONS="--without-curses --without-oss --without-mingw --disable-winemenubuilder --disable-win16 --disable-tests"
export WINE_VERSION="5.11"
export SDL2_VERSION="2.0.12"
export FAUDIO_VERSION="20.08"
export VULKAN_VERSION="1.2.145"
export SPIRV_VERSION="1.5.3"

export CHROOT_DISTRO="bionic"
export CHROOT_MIRROR="http://archive.ubuntu.com/ubuntu/"

# nehalem go up to sse4.2
export CFLAGS="-march=nehalem -O2 -pipe -ftree-vectorize -fno-stack-protector"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed"
#==============================================================================

#=================================================
die() { echo >&2 "$*"; exit 1; };
#=================================================
#==============================================================================
cat /etc/issue

# Ubuntu Main Repos:
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO} main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO} main restricted universe multiverse" >> /etc/apt/sources.list

echo "* Install deps:"
apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
#apt-get -y install libicu-dev:i386 libv4l-dev:i386 libx11-dev:i386 libxinerama-dev:i386 libxml2-dev:i386 zlib1g-dev:i386 libcapi20-dev:i386 libcups2:i386 libdbus-1-3:i386 libfontconfig:i386 libfreetype6:i386 libglu1-mesa:i386 libgnutls28-dev:i386 libncurses5:i386 libosmesa6:i386 libsane:i386 libxcomposite1:i386 libxcursor1:i386 libxi6:i386 libxrandr2:i386 libxslt1.1:i386 ocl-icd-libopencl1:i386 xorg-dev libfreetype6-dev:i386 || die "* apt-get error!"
#apt-get -y purge libvulkan-dev libvulkan1 libsdl2-dev libsdl2-2.0-0 --purge --autoremove || die "* apt-get purge error!"
#apt-get -y clean || die "* apt-get clean error!"
#apt-get -y autoclean || die "* apt-get autoclean error!"
BASIC_SYSTEM_PACKAGES="software-properties-common wget sudo build-essential cmake xz-utils gzip"
apt-get -y install "${BASIC_SYSTEM_PACKAGES}"
OTHERS_DEPS="xserver-xorg-dev:i386 libfreetype6-dev:i386 libfontconfig1-dev:i386 libglu1-mesa-dev:i386 libosmesa6-dev:i386 libvulkan-dev:i386 libvulkan1:i386 libpulse-dev:i386 libopenal-dev:i386 libncurses-dev:i386 libgnutls28-dev:i386 libtiff-dev:i386 libldap-dev:i386 libcapi20-dev:i386 libpcap-dev:i386 libxml2-dev:i386 libmpg123-dev:i386 libgphoto2-dev:i386 libsane-dev:i386 libcupsimage2-dev:i386 libkrb5-dev:i386 libgsm1-dev:i386 libxslt1-dev:i386 libv4l-dev:i386 libgstreamer-plugins-base1.0-dev:i386 libudev-dev:i386 libxi-dev:i386 liblcms2-dev:i386 libibus-1.0-dev:i386 libsdl2-dev:i386 ocl-icd-opencl-dev:i386 libxinerama-dev:i386 libxcursor-dev:i386 libxrandr-dev:i386 libxcomposite-dev:i386 libavcodec57:i386 libavcodec-dev:i386 libswresample2:i386 libswresample-dev:i386 libavutil55:i386 libavutil-dev:i386"
EXTRA_DEV_PACKAGES="libusb-1.0-0-dev:i386 libgcrypt20-dev:i386 libasound2-dev:i386 libjpeg8-dev:i386 libldap2-dev:i386"
apt install "${OTHERS_DEPS} ${EXTRA_DEV_PACKAGES}" || die "* main apt-get erro!"
# removed  libfaudio0:i386 libfaudio-dev:i386 (building it below), libvkd3d-dev:i386

echo "* compile and install more deps:"
mkdir "$HOME/build_libs"
cd "$HOME/build_libs" || die "* Cant enter on dir build_libs!"

echo "* downloading all:"
wget "https://www.libsdl.org/release/SDL2-${SDL2_VERSION}.tar.gz"
wget "https://github.com/FNA-XNA/FAudio/archive/${FAUDIO_VERSION}.tar.gz" -O "FAudio-${FAUDIO_VERSION}.tar.gz"
wget "https://github.com/KhronosGroup/Vulkan-Headers/archive/v${VULKAN_VERSION}.tar.gz" -O "Vulkan-Headers-${VULKAN_VERSION}.tar.gz"
wget "https://github.com/KhronosGroup/Vulkan-Loader/archive/v${VULKAN_VERSION}.tar.gz" -O "Vulkan-Loader-${VULKAN_VERSION}.tar.gz"
wget "https://github.com/KhronosGroup/SPIRV-Headers/archive/${SPIRV_VERSION}.tar.gz"  -O "SPIRV-Headers-${SPIRV_VERSION}.tar.gz"
git clone --depth 1 https://github.com/HansKristian-Work/vkd3d-proton.git

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
	make install || die "* Cant install $1!"
	cd ../ && rm -r build
}

build_and_install "SDL2-${SDL2_VERSION}"
build_and_install "FAudio-${FAUDIO_VERSION}"
build_and_install "Vulkan-Headers-${VULKAN_VERSION}"
build_and_install "Vulkan-Loader-${VULKAN_VERSION}"
build_and_install "SPIRV-Headers-${SPIRV_VERSION}"
# Need libvkd3d-dev package that refuse to install on bionic, so workaround:
wget https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-i386/wine-stable_5.0.1~bionic_i386.deb
dpkg -x wine.deb .
cp ./opt/wine-stable/bin/widl /usr/bin/ || die "cant copy widl erro!"
cd vkd3d-proton || die "* Cant enter on vkd3d-proton dir!"
./autogen.sh
./configure || die "* vkd3d-proton configure error!"
make -j"$(nproc)" || die "* vkd3d-proton make error!"
make install || die "* vkd3d-proton install error!"

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
#./configure "${WINE_BUILD_OPTIONS}" --prefix "$HOME/wine-staging"
./configure --prefix "$HOME/wine-staging"
make -j"$(nproc)" || die "* cant make wine!"
make install || die "* cant install wine!"

echo "* Some clean:"
cd "$HOME/wine-staging" || die "* Cant enter on the wine-staging dir!"
rm -r include && rm -r share/applications && rm -r share/man
cd "$HOME" || die "Cant enter on $HOME dir!"

echo "* Strip all binaries and libraries:"
find "$HOME/wine-staging" -type f -exec strip --strip-unneeded {} \;

echo "* Compressing:"
tar czvf "wine-staging-${WINE_VERSION}.tar.gz" wine-staging

echo "Packing tar result file..."
tar cvf result.tar "wine-staging-${WINE_VERSION}.tar.gz"
echo "* result.tar size: $(du -hs result.tar)"
