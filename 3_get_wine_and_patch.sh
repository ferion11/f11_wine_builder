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

echo "* Wine part:"
echo "* Getting wine source from ValveSoftware and patch..."
wget -q "https://github.com/Tk-Glitch/wine-tkg/archive/${TKG_GIT_COMMIT}.tar.gz" -O "${TKG_SRC_FILENAME}"
tar xf "${TKG_SRC_FILENAME}" || die "* cant extract wine!"
mv "wine-tkg-${TKG_GIT_COMMIT}" "wine-src" || die "* cant rename wine-src!"


#wget -q "https://github.com/wine-staging/wine-staging/archive/v${STAGING_VERSION}.tar.gz"
#tar xf "v${STAGING_VERSION}.tar.gz" || die "* cant extract wine-staging patchs!"
echo "* Applying patchs..."
#"./wine-staging-${STAGING_VERSION}/patches/patchinstall.sh" DESTDIR="${WORKDIR}/wine-src" --all || die "* Cant apply the wine-staging patches!"
cd "${WORKDIR}/wine-src" || die "Cant enter on ${WORKDIR}/wine-src dir!"
patch -p1 < "${WORKDIR}/patches/timeout_infinite_fix.patch" || die "Cant apply the timeout_infinite_fix.patch!"

cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"
