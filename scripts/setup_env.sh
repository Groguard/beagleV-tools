#!/bin/bash


# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]


output_dir="$(pwd)/output"
build_dir="${output_dir}/build"
tools_dir="$(pwd)/tools"
compiler_dir="${tools_dir}/compiler"

compiler_version=2021.04.23
qemu_version=v5.2.0

# core count for compiling with -j
cores=$(( $(nproc) * 2 ))

echo "Installing tools.."
release=$(awk -F= '$1=="ID" { print $2 ;}' /etc/os-release)
echo ${release}
case ${release} in
debian|ubuntu)
	apt install -y \
	autoconf automake autotools-dev curl python3 libmpc-dev \
	libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
	gperf libtool patchutils libncurses-dev libssl-dev bc zlib1g-dev \
	libexpat-dev qemu-user-static binfmt-support debootstrap \
	device-tree-compiler debian-ports-archive-keyring
	;;
esac


# check if the main output dir exists
if [ ! -d "${output_dir}" ]; then
	echo "No output directory found, making one.."
	mkdir -p "${output_dir}"
else
	echo "Output directory found.."
fi


# check if the main build dir exists
if [ ! -d "${build_dir}" ]; then
	echo "No build directory found, making one.."
	mkdir -p "${build_dir}"
else
	echo "Build directory found.."
fi


# check if the tools dir exists
if [ ! -d "${tools_dir}" ]; then
	echo "No tools directory found, making one.."
	mkdir -p "${tools_dir}"
else
	echo "Tools directory found.."
fi


# check if the compiler dir exists
if [ ! -d "${compiler_dir}" ]; then
	echo "No compiler directory found, making one.."
	mkdir -p "${compiler_dir}"
else
	echo "Compiler directory found.."
fi


# check if the compiler toolchain exists
if [ ! -d "${tools_dir}/riscv-gnu-toolchain" ]; then
	echo "Riscv compiler toolchain missing!"
	git -C ${tools_dir} clone https://github.com/riscv/riscv-gnu-toolchain.git -b ${compiler_version}
else
	echo "Riscv toolchain source found.."
fi


# check if the compiler has already been built, if not build it.
if [ ! -f "${tools_dir}/compiler/bin/riscv64-unknown-linux-gnu-gcc" ]; then
	echo "Riscv compiler toolchain not built, building now.."
	cd ${tools_dir}/riscv-gnu-toolchain 
	./configure --prefix="${tools_dir}/compiler"
	make -j${cores} linux
else
	echo "Riscv toolchain already built.."
	
fi

#~ # check if the QEMU source exists
#~ if [ ! -d "${tools_dir}/qemu" ]; then
	#~ echo "QEMU source missing!"
	#~ git -C ${tools_dir} clone -b ${qemu_version} https://github.com/qemu/qemu
#~ else
	#~ echo "QEMU source found.."
#~ fi

#~ # check if QEMU has been built
#~ if [ ! -f "${tools_dir}/qemu-riscv64-static" ]; then
	#~ echo "QEMU not built, building now.."
	#~ cd ${tools_dir}/qemu 
	#~ ./configure --static --disable-system --target-list=riscv64-linux-user
	#~ make -j${cores}
	#~ cp build/riscv64-linux-user/qemu-riscv64 ${tools_dir}/qemu-riscv64-static
#~ else
	#~ echo "QEMU already built.."
#~ fi


echo "Done.."
