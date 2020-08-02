#!/bin/bash
#GENTOO_PATCH_VERSION="20200523"

#=================================================
die() { echo >&2 "$*"; exit 1; };
#=================================================

#echo "* Getting gentoo wine patchs for winegcc.patch:"
#wget -c "https://dev.gentoo.org/~sarnex/distfiles/wine/gentoo-wine-patches-${GENTOO_PATCH_VERSION}.tar.xz"
#tar xf "gentoo-wine-patches-${GENTOO_PATCH_VERSION}.tar.xz" || die "* Can't extract the gentoo patchs"

echo "* Versions:"
gcc --version
g++ --version
