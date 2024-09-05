#!/bin/sh

# SPDX-License-Identifier: MIT
# Copyright (c) 2024 Linaro Ltd
# Author: Dmitry Baryshkov

FW_PKG_NAME="firmware-x1e80100-crd"
FW_SUBDIR="8380_CRD"
FW_VER="200.0.32.0"
LIB_FW_DIR="x1e80100"
FW_DEVNAME="Qualcomm X Elite Compute Reference Device"

SHAREDIR=/usr/share/firmware-qcom-woa

while true
do
	case "$1" in
		"-c")
			DLDIR="$2"
			mkdir -p "${DLDIR}"
			shift
			shift
			;;
		"-d")
			SHAREDIR="$2"
			shift
			shift
			;;
		*)
			break
	esac
done

. ${SHAREDIR}/common.sh

do_prepare

if [ "$1" = "-c" ]
then
	shift
	DLDIR="$1"
	mkdir -p "${DLDIR}"
	shift
fi

do_dl \
	fce26a9c95ff8f5ddbc58312dfad9d1d317bda1a9a854ea49290acb34485bbbd qcdx8380.cab \
	872581d2b371c7b4e2ba779f8dc9899fff45ffcec2ca58e6981d76bc1113a7d8 qcsubsys_ext_adsp8380.cab \
	610af5d3ab44181ad7995576b9f064463ac9dd3c883b7105a40b14cfe36694b9 qcsubsys_ext_cdsp8380.cab \

do_install \
	qcadsp8380.mbn qccdsp8380.mbn qcdxkmsuc8380.mbn qcvss8380.mbn adsp_dtbs.elf cdsp_dtbs.elf

do_install_jsn \
	adspr.jsn adspua.jsn adsps.jsn battmgr.jsn cdspr.jsn

ln -s qcadsp8380.mbn "${FW_OUT}"/adsp.mbn
ln -s qccdsp8380.mbn "${FW_OUT}"/cdsp.mbn

ln -s adsp_dtbs.elf "${FW_OUT}"/adsp_dtb.mbn
ln -s cdsp_dtbs.elf "${FW_OUT}"/cdsp_dtb.mbn

do_build

