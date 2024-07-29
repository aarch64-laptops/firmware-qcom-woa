#!/bin/sh

# SPDX-License-Identifier: MIT
# Copyright (c) 2024 Linaro Ltd
# Author: Dmitry Baryshkov

FW_PKG_NAME="firmware-lenovo-yoga-c630"
FW_SUBDIR="Lenovo/YogaC630"
FW_VER="200.0.19.0"
LIB_FW_DIR="sdm850/LENOVO/81JL"
FW_DEVNAME="Lenovo Yoga C630 laptop"

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

do_dl \
	949f9fa256d036d829a1429451514c4f6aa3fcb228078a36a0bc4c6d569be3f9 qcdx850.cab \
	544f0b2ff642846a2bf0754600be57ef8277c4ebd9dcf72b61cb3d1f463bfec8 qcipa850.cab \
	23f8f1413ffdac6d6dfc7d0876f3cd5b840db70889d5f399e586e77ab91d89af qcsubsys850.cab

do_install \
	qcadsp850.mbn qccdsp850.mbn qcdsp2850.mbn qcdsp2850_nm.mbn qcdsp1v2850.mbn qcdsp1v2850_nm.mbn qcdxkmsuc850.mbn qcslpi850.mbn qcvss850.mbn wlanmdsp.mbn ipa_fws.elf

do_install_jsn \
	adspr.jsn adspua.jsn cdspr.jsn modemr.jsn modemuw.jsn slpir.jsn slpius.jsn

do_build
