#!/bin/sh

# SPDX-License-Identifier: MIT
# Copyright (c) 2024 Linaro Ltd
# Author: Dmitry Baryshkov

FW_PKG_NAME="firmware-lenovo-miix-630"
FW_SUBDIR="Lenovo/Miix630"
FW_VER="200.0.6.0"
LIB_FW_DIR="msm8998/LENOVO/81F1"
FW_DEVNAME="Lenovo Mixx 630 laptop"

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
	72689ef44a7eae8be5a6eb81a0ee3dc372cfbef988c3f3f39b4ab985b2d2bc4e qcdx8998.cab \
	169bdd9bc312b9b550f8953499c7b7c178b030a5185714e0204c117ccbc2dffe qcipa8998.cab \
	13c356d1e716ce6b3457d4e74eec8dd0c7e9916b534d273c27430df03317ecd5 qcsubsys8998.cab

do_install \
	qcadsp8998.mbn qcdsp28998.mbn qcdsp1v28998.mbn qcdxkmsuc8998.mbn qcslpi8998.mbn qcvss8998.mbn wlanmdsp.mbn ipa_fws.elf

do_install_jsn \
	adspr.jsn adspua.jsn modemr.jsn modemuw.jsn slpir.jsn slpius.jsn

do_build
