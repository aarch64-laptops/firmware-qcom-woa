# SPDX-License-Identifier: MIT
# Copyright (c) 2024 Linaro Ltd
# Author: Dmitry Baryshkov

set -e

GITHUB_REPO="https://github.com/WOA-Project/Qualcomm-Reference-Drivers"

do_prepare() {
	FWTEMPDIR=$(mktemp -d firmware-woa.XXXXXX --tmpdir )
	trap "rm -rf ${FWTEMPDIR}" EXIT

	UNPACKDIR="${FWTEMPDIR}/unpack"
	mkdir -p "${UNPACKDIR}"

	if [ -z "${DLDIR}" ]
	then
		DLDIR="${FWTEMPDIR}/dl"
		mkdir -p "${DLDIR}"
	fi

	WORKDIR="${FWTEMPDIR}/package"
	rm -rf "${WORKDIR}"
	mkdir -p "${WORKDIR}"

	FW_OUT="${WORKDIR}/qcom/${LIB_FW_DIR}"
	mkdir -p "${FW_OUT}"

	DEBDIR="${WORKDIR}/debian"
	mkdir -p "${DEBDIR}"

	cat > "${DEBDIR}/rules" << EOF
#!/usr/bin/make -f

%:
	dh \$@

# comaptibility with old and new Debian repos.
override_dh_installdeb:
	dh_installdeb
	if command -v dh_movetousr >/dev/null; then dh_movetousr; fi
EOF

	cat > "${DEBDIR}/control" << EOF
Source: ${FW_PKG_NAME}
Section: non-free-firmware/kernel
Priority: optional
Maintainer: Dmitry Baryshkov <dmitry.baryshkov@linaro.org>
Standards-Version: 4.6.2
Build-Depends: debhelper-compat (= 12)

Package: ${FW_PKG_NAME}
Architecture: all
Depends: firmware-qcom-soc, firmware-atheros, \${misc:Depends}
Description: Binary firmware for the ${FW_DEVNAME}
 This package contains the binary firmware for
 the ${FW_DEVNAME}.
 .
 The firmware has been repackaged from WoA cab archives.
EOF

	cat > "${DEBDIR}/changelog" << EOF
${FW_PKG_NAME} (${FW_VER}-1) unstable; urgency=medium

  * Initial upload.

 -- Dmitry Baryshkov <dmitry.baryshkov@linaro.org>  Mon, 1 Jan 2024 00:00:00 +0000
EOF

	cat > "${DEBDIR}/install" << EOF
qcom /lib/firmware/
EOF
}

do_shacheck() {
	[ ! -r $2 ] && return 1

	[ `sha256sum $2 | cut -d' ' -f 1` = "$1" ]
}

do_dl() {
	while [ -n "$1" ]
	do
		sha="$1"
		cab="$2"
		dlcab="${DLDIR}/${cab}"

		if ! do_shacheck $sha "${dlcab}"
		then
			rm -f "${dlcab}"
			wget "${GITHUB_REPO}/raw/master/${FW_SUBDIR}/${FW_VER}/${cab}" -O "${dlcab}"
		fi

		if ! do_shacheck $sha "${dlcab}"
		then
			echo "Checksum failure for ${cab}"
			exit 1
		fi

		cabextract -q -d "${UNPACKDIR}" -L "${dlcab}"

		shift
		shift
	done
}

do_install() {
	for file in $@
	do
		cp "${UNPACKDIR}/${file}" "${FW_OUT}"
	done
}

do_install_jsn() {
	for file in $@
	do
		cp "${SHAREDIR}/jsn/${file}" "${FW_OUT}"
	done
}

do_build() {
	cd ${WORKDIR}
	dpkg-buildpackage -b --no-sign
	cd -

	mv ${FWTEMPDIR}/*.* .
}
