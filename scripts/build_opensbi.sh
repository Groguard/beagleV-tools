#!/bin/bash


# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]


patch_dir="$(pwd)/patches/u-boot"
output_dir="$(pwd)/output"
tools_dir="$(pwd)/tools"
build_dir="${output_dir}/build"
opensbi_bin="${output_dir}/opensbi"
opensbi_dir="${build_dir}/beagle_opensbi"

CC="riscv64-unknown-elf-"
release="Fedora"

cross_make="make -C ${opensbi_dir} ARCH=riscv CROSS_COMPILE=${CC}"

# check if the opensbi dir exists
if [ ! -d "${opensbi_bin}" ]; then
	echo "No opensbi output directory found, making one.."
	mkdir -p "${opensbi_bin}"
else
	echo "Opensbi output directory found.."
fi

git -C ${build_dir} clone https://github.com/starfive-tech/beagle_opensbi.git -b ${release}

${cross_make} -j"${cores}" PLATFORM=starfive/vic7100 O=${opensbi_bin}
