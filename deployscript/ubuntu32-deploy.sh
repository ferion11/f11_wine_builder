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
WORKDIR=$(pwd)
echo "* Working inside ${WORKDIR}"

# Ubuntu Main Repos:
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO} main restricted universe multiverse" > /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO} main restricted universe multiverse" >> /etc/apt/sources.list

###### Ubuntu Update Repos:
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-proposed main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb ${CHROOT_MIRROR} ${CHROOT_DISTRO}-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-proposed main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src ${CHROOT_MIRROR} ${CHROOT_DISTRO}-backports main restricted universe multiverse" >> /etc/apt/sources.list

apt-get -q -y update >/dev/null
echo "* Install software-properties-common..."
apt-get -q -y install software-properties-common apt-utils >/dev/null || die "* apt software-properties-common and apt-utils erro!"

# gcc-9 ppa:
add-apt-repository ppa:ubuntu-toolchain-r/test >/dev/null

echo "* update, upgrade and dist-upgrade..."
apt-get -q -y update >/dev/null
apt-get -q -y upgrade >/dev/null
apt-get -q -y dist-upgrade >/dev/null

echo "* Install deps..."
apt-get -q -y install wget git sudo make cmake gcc-9 g++-9 tar gzip xz-utils bzip2 gawk sed flex bison >/dev/null || die "* apt basic erro!"
apt-get -q -y install xserver-xorg-dev:i386 libfreetype6-dev:i386 libfontconfig1-dev:i386 libglu1-mesa-dev:i386 libosmesa6-dev:i386 libvulkan-dev:i386 libvulkan1:i386 libpulse-dev:i386 libopenal-dev:i386 libncurses-dev:i386 libgnutls28-dev:i386 libtiff-dev:i386 libldap-dev:i386 libcapi20-dev:i386 libpcap-dev:i386 libxml2-dev:i386 libmpg123-dev:i386 libgphoto2-dev:i386 libsane-dev:i386 libcupsimage2-dev:i386 libkrb5-dev:i386 libgsm1-dev:i386 libxslt1-dev:i386 libv4l-dev:i386 libgstreamer-plugins-base1.0-dev:i386 libudev-dev:i386 libxi-dev:i386 liblcms2-dev:i386 libibus-1.0-dev:i386 libsdl2-dev:i386 ocl-icd-opencl-dev:i386 libxinerama-dev:i386 libxcursor-dev:i386 libxrandr-dev:i386 libxcomposite-dev:i386 libavcodec57:i386 libavcodec-dev:i386 libswresample2:i386 libswresample-dev:i386 libavutil55:i386 libavutil-dev:i386 libusb-1.0-0-dev:i386 libgcrypt20-dev:i386 libasound2-dev:i386 libjpeg8-dev:i386 libldap2-dev:i386 libx11-dev:i386 zlib1g-dev:i386 libcups2:i386 libdbus-1-3:i386 libicu-dev:i386 libncurses5:i386 >/dev/null || die "* main apt erro!"
apt-get -q -y purge libvulkan-dev libvulkan1 libsdl2-dev libsdl2-2.0-0 --purge --autoremove >/dev/null || die "* apt purge error!"
# removed  libfaudio0:i386 libfaudio-dev:i386 (building it below), libvkd3d-dev:i386

echo "* compile and install more deps..."
mkdir "${WORKDIR}/build_libs"
cd "${WORKDIR}/build_libs" || die "* Cant enter on dir build_libs!"

echo "* downloading SDL2..."
wget -q "https://www.libsdl.org/release/SDL2-${SDL2_VERSION}.tar.gz"
echo "* downloading FAudio..."
wget -q "https://github.com/FNA-XNA/FAudio/archive/${FAUDIO_VERSION}.tar.gz" -O "FAudio-${FAUDIO_VERSION}.tar.gz"
echo "* downloading Vulkan-Headers..."
wget -q "https://github.com/KhronosGroup/Vulkan-Headers/archive/v${VULKAN_VERSION}.tar.gz" -O "Vulkan-Headers-${VULKAN_VERSION}.tar.gz"
echo "* downloading Vulkan-Loader..."
wget -q "https://github.com/KhronosGroup/Vulkan-Loader/archive/v${VULKAN_VERSION}.tar.gz" -O "Vulkan-Loader-${VULKAN_VERSION}.tar.gz"
echo "* downloading SPIRV-Headers..."
wget -q "https://github.com/KhronosGroup/SPIRV-Headers/archive/${SPIRV_VERSION}.tar.gz"  -O "SPIRV-Headers-${SPIRV_VERSION}.tar.gz"
git clone --depth 1 https://github.com/HansKristian-Work/vkd3d-proton.git

echo "* extracting..."
tar xf "SDL2-${SDL2_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "FAudio-${FAUDIO_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "Vulkan-Headers-${VULKAN_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "Vulkan-Loader-${VULKAN_VERSION}.tar.gz" || die "* extract tar.gz error!"
tar xf "SPIRV-Headers-${SPIRV_VERSION}.tar.gz" || die "* extract tar.gz error!"

build_and_install() {
	echo "* Building and installing: $1"
	mkdir build
	cd build || die "* Cant enter on build dir!"
	cmake ../"$1" >/dev/null
	make -j"$(nproc)" >/dev/null || die "* Cant make $1!"
	make install >/dev/null || die "* Cant install $1!"
	cd ../ && rm -r build
}

build_and_install "SDL2-${SDL2_VERSION}"
build_and_install "FAudio-${FAUDIO_VERSION}"
build_and_install "Vulkan-Headers-${VULKAN_VERSION}"
build_and_install "Vulkan-Loader-${VULKAN_VERSION}"
build_and_install "SPIRV-Headers-${SPIRV_VERSION}"
# Need libvkd3d-dev package that refuse to install on bionic, so workaround:
echo "* compiling and install vkd3d-proton>"
wget -q https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-i386/wine-stable_5.0.1~bionic_i386.deb
dpkg -x wine-stable_5.0.1~bionic_i386.deb .
cp ./opt/wine-stable/bin/widl /usr/bin/ || die "cant copy widl erro!"
cd vkd3d-proton || die "* Cant enter on vkd3d-proton dir!"
./autogen.sh >/dev/null
./configure >/dev/null || die "* vkd3d-proton configure error!"
make -j"$(nproc)" >/dev/null || die "* vkd3d-proton make error!"
make install >/dev/null || die "* vkd3d-proton install error!"

cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"
rm -rf "${WORKDIR}/build_libs"
#==============================================================================

echo "* Wine part:"
echo "* Getting wine source and patch..."
wget -q "https://dl.winehq.org/wine/source/5.x/wine-${WINE_VERSION}.tar.xz"
tar xf "wine-${WINE_VERSION}.tar.xz" || die "* cant extract wine!"
mv "wine-${WINE_VERSION}" "wine-src" || die "* cant rename wine-src!"

wget -q "https://github.com/wine-staging/wine-staging/archive/v${WINE_VERSION}.tar.gz"
tar xf "v${WINE_VERSION}.tar.gz" || die "* cant extract wine-staging patchs!"
echo "* Applying staging patchs..."
"./wine-staging-${WINE_VERSION}/patches/patchinstall.sh" DESTDIR="${WORKDIR}/wine-src" --all >"${WORKDIR}/staging_patches.txt" || die "* Cant apply the wine-staging patches!"
#echo "* Applying esync patch"; there is no usable esync in 5.10 staging patches anymore, Due to the current and ongoing work in ntdll.so
#"./wine-staging-${WINE_VERSION}/patches/patchinstall.sh" DESTDIR="${WORKDIR}/wine-src" eventfd_synchronization >"${WORKDIR}/staging_patches.txt" || die "* Cant apply the eventfd_synchronization patche!"

echo "* Compiling..."
mkdir "wine-staging"
cd wine-src || die "* Cant enter on the wine-src dir!"
#./configure "${WINE_BUILD_OPTIONS}" --prefix "${WORKDIR}/wine-staging"
./configure --prefix "${WORKDIR}/wine-staging" --disable-tests
make -j"$(nproc)" --no-print-directory || die "* cant make wine!"
make install --no-print-directory || die "* cant install wine!"

cd "${WORKDIR}/wine-staging" || die "* Cant enter on the wine-staging dir!"
echo "* Cleaning..."
rm -r include && rm -r share/applications && rm -r share/man
echo "* Compressing: wine-staging-${WINE_VERSION}.tar.gz"
tar czf "${WORKDIR}/wine-staging-${WINE_VERSION}.tar.gz" *
cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"

echo "Packing tar result file..."
tar cvf result.tar "wine-staging-${WINE_VERSION}.tar.gz" "staging_patches.txt"
echo "* result.tar size: $(du -hs result.tar)"
