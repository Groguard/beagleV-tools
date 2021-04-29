#!/bin/bash


# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]


output_dir="$(pwd)/output"
patch_dir="$(pwd)/patches/kernel"
tools_dir="$(pwd)/tools"
modules_dir="${output_dir}/modules"
headers_dir="${output_dir}/headers"
build_dir="${output_dir}/build"
linux_dir="${build_dir}/beagle_kernel_5.10"
images_dir="${output_dir}/images"

CC="${tools_dir}/compiler/bin/riscv64-unknown-linux-gnu-"

# core count for compiling with -j
cores=$(( $(nproc) * 2 ))

cross_make="make -C ${linux_dir} ARCH=riscv CROSS_COMPILE=${CC}"


echo "Building kernel release: ${release}"
mkdir -p "${build_dir}"
mkdir -p "${images_dir}"

# check for the linux directory
if [ ! -d "${linux_dir}" ]; then
	git -C ${build_dir} clone https://github.com/starfive-tech/beagle_kernel_5.10 -b Fedora
fi

# always do a checkout to see if chosen kernel version has changed
#git -C ${linux_dir} checkout ${release} -b tmp

export KBUILD_BUILD_USER="beaglev"
export KBUILD_BUILD_HOST="beaglev"

echo "preparing kernel.."
echo "cross_make: ${cross_make}"


if [ $1 == "clean" ]; then
	${cross_make} distclean
fi

# only call with defconfig if a config file doesn't exist already
if [ ! -f "${linux_dir}/.config" ]; then
	${cross_make} starfive_vic7100_evb_sd_net_fedora_defconfig
fi

${cross_make} menuconfig

# here we are grabbing the kernel version and release information from kbuild
built_version="$(${cross_make} --no-print-directory -s kernelversion 2>/dev/null)"
built_release="$(${cross_make} --no-print-directory -s kernelrelease 2>/dev/null)"

# build the dtb's, modules, and headers
${cross_make} -j"${cores}"
${cross_make} Image
DTC_FLAGS="-@" ${cross_make} dtbs -j"${cores}"


echo "done building.."
echo "copying kernel files"


# copy the kernel Image to our images directory
cp ${linux_dir}/arch/riscv/boot/Image ${images_dir}/
echo "complete!"
