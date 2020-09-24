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

echo "* Compiling..."
mkdir "build32"
mkdir "wine-inst"

# compile 32bits
cd "${WORKDIR}/build32" || die "* Cant enter on the ${WORKDIR}/build32 dir!"
PKG_CONFIG_PATH="/usr/lib/i386-linux-gnu/pkgconfig:/usr/lib32/pkgconfig" ../wine-src/configure --prefix "${WORKDIR}/wine-inst" --disable-tests
echo "DEBUG EXIT"; exit 1
make -j"$(nproc)" --no-print-directory || die "* cant make wine32!"

cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"
