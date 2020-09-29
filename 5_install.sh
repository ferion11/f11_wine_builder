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

# install the 32bits
cd "${WORKDIR}/build32" || die "* Cant enter on the ${WORKDIR}/build32 dir!"
make install --no-print-directory || die "* cant install wine!"
#-------------------------------------------------

cd "${WORKDIR}/wine-inst" || die "* Cant enter on the wine-inst dir!"

echo "* Cleaning..."
sudo rm -r include && sudo rm -r share/applications && sudo rm -r share/man

# Will do it on he appimage making only, because one can use this native feature
#echo "* disabling winemenubuilder.exe..."
#sed 's/winemenubuilder.exe -a -r/winemenubuilder.exe -r/g' ./share/wine/wine.inf -i
#
#echo "* disabling FileOpenAssociations..."
#sed 's|    LicenseInformation|    LicenseInformation,\\\n    FileOpenAssociations|g;$a \\n[FileOpenAssociations]\nHKCU,Software\\Wine\\FileOpenAssociations,"Enable",,"N"' ./share/wine/wine.inf -i

rm -f "${WORKDIR}"/*.tar.gz

echo "* Compressing: wine-vanilla-${WINE_VERSION}.tar.gz"
tar czf "${WORKDIR}/wine-vanilla-${WINE_VERSION}.tar.gz" *

cd "${WORKDIR}" || die "Cant enter on ${WORKDIR} dir!"
#mv *.tar.gz result/
#-------------------------------------------------
