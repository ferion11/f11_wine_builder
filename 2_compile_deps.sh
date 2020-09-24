#!/bin/bash
source ./0_variables.sh
#==============================================================================

#=================================================
die() { echo >&2 "$*"; exit 1; };
#=================================================
#==============================================================================
cat /etc/issue
WORKDIR=$(pwd)
echo "* Working inside ${WORKDIR}"

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
	sudo make install >/dev/null || die "* Cant install $1!"
	cd ../ && sudo rm -r build
}

build_and_install "SDL2-${SDL2_VERSION}"
build_and_install "FAudio-${FAUDIO_VERSION}"
build_and_install "Vulkan-Headers-${VULKAN_VERSION}"
build_and_install "Vulkan-Loader-${VULKAN_VERSION}"
build_and_install "SPIRV-Headers-${SPIRV_VERSION}"
# Need libvkd3d-dev package that refuse to install on ${CHROOT_DISTRO}, so workaround:
echo "* compiling and install vkd3d-proton>"
wget -q https://dl.winehq.org/wine-builds/ubuntu/dists/${CHROOT_DISTRO}/main/binary-${UBUNTU_ARCH}/wine-stable_5.0.2~${CHROOT_DISTRO}_${UBUNTU_ARCH}.deb
dpkg -x wine-stable_5.0.2~${CHROOT_DISTRO}_${UBUNTU_ARCH}.deb ./
sudo cp ./opt/wine-stable/bin/widl /usr/bin/ || die "cant copy widl erro!"
cd vkd3d-proton || die "* Cant enter on vkd3d-proton dir!"
./autogen.sh >/dev/null
./configure >/dev/null || die "* vkd3d-proton configure error!"
make -j"$(nproc)" >/dev/null || die "* vkd3d-proton make error!"
sudo make install >/dev/null || die "* vkd3d-proton install error!"

cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"
sudo rm -rf "${WORKDIR}/build_libs"
#==============================================================================
