#!/bin/bash


# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]


patch_dir="$(pwd)/patches/u-boot"
output_dir="$(pwd)/output"
tools_dir="$(pwd)/tools"
build_dir="${output_dir}/build"
uboot_bin="${output_dir}/u-boot"
uboot_dir="${build_dir}/beagle_uboot-opensbi"

release="Fedora"
CC="${tools_dir}/compiler/bin/riscv64-unknown-linux-gnu-"

# core count for compiling with -j
cores=$(( $(nproc) * 2 ))

cross_make="make -C ${uboot_dir} ARCH=riscv CROSS_COMPILE=${CC}"


# check if the u-boot dir exists
if [ ! -d "${uboot_bin}" ]; then
	echo "No u-boot output directory found, making one.."
	mkdir -p "${uboot_bin}"
else
	echo "U-Boot output directory found.."
fi


# clone u-boot
git -C ${build_dir} clone https://github.com/starfive-tech/beagle_uboot-opensbi.git -b ${release}


echo "starting u-boot build.."
${cross_make} -j"${cores}" distclean
${cross_make} -j"${cores}" starfive_vic7100_beagle_v_smode_defconfig
${cross_make} -j"${cores}"

cp -v ${uboot_dir}/u-boot.bin ${uboot_bin}
cp -v ${uboot_dir}/arch/riscv/dts/starfive_vic7100_beagle_v.dtb ${uboot_bin}
echo "finished building u-boot"
