#!/usr/bin/env bash
set -xe

BUILDPATH='mxs-build'
INSTALLPATH='mxs-install'
FWTAG='LSDK-19.03'

rm -rf "$INSTALLPATH"

mkdir -p "$BUILDPATH"
mkdir -p "$INSTALLPATH/boot"

make ARCH=arm64 O="$BUILDPATH" defconfig

make -j$( nproc ) ARCH=arm64 O="$BUILDPATH" CROSS_COMPILE=aarch64-linux-gnu- all modules
make -j$( nproc ) ARCH=arm64 O="$BUILDPATH" CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH="../$INSTALLPATH" modules_install
make -j$( nproc ) ARCH=arm64 O="$BUILDPATH" CROSS_COMPILE=aarch64-linux-gnu- INSTALL_PATH="../$INSTALLPATH/boot" install

mkdir -p "$INSTALLPATH/lib/firmware"
pushd "${INSTALLPATH}/lib/firmware"
curl -O "https://gitlab.dolphinics.no/nxp-mirror/qoriq-engine-pfe-bin/raw/${FWTAG}/ls1012a/slow_path/ppfe_class_ls1012a.elf"
curl -O "https://gitlab.dolphinics.no/nxp-mirror/qoriq-engine-pfe-bin/raw/${FWTAG}/ls1012a/slow_path/ppfe_tmu_ls1012a.elf"
popd

cp "${BUILDPATH}/arch/arm64/boot/Image" "${INSTALLPATH}/boot/"
cp "${BUILDPATH}/arch/arm64/boot/dts/freescale/fsl-ls1012a-rdb.dtb" "${INSTALLPATH}/boot/"
tree ${INSTALLPATH}

tar -zcvf "${INSTALLPATH}.tar.gz" "$INSTALLPATH"
