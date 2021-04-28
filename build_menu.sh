#!/bin/bash

output_dir="$(pwd)/output"
build_dir="${output_dir}/build"

clear
echo "Build Options:"
echo "1: Setup Build Environment.(Run on first setup.)"
echo "2: Build u-boot"
echo "3: Build opensbi"
echo "4: Build kernel/clean"
echo "5: Rebuild kernel"
echo "6: Build rootfs"
echo "7: Make Image"

setup_env () {
	chmod +x scripts/setup_env.sh
	chmod +x scripts/build_u-boot.sh
	chmod +x scripts/build_opensbi.sh
	chmod +x scripts/build_kernel.sh
	chmod +x scripts/build_rootfs.sh
	chmod +x scripts/make_image.sh
	scripts/setup_env.sh
}

build_uboot () {
	scripts/build_u-boot.sh
}

build_opensbi () {
	scripts/build_opensbi.sh
}

build_kernel () {
	scripts/build_kernel.sh clean
}

rebuild_kernel () {
	scripts/build_kernel.sh
}

build_rootfs () {
	scripts/build_rootfs.sh
}

make_image () {
	scripts/make_image.sh
}

read -p "Enter selection [1-4] > " option

case $option in
	1)
		clear
		echo "Setting up build enviroment.."
		setup_env
		;;
	2)
		clear
		echo "Preparing to build u-boot.."
		build_uboot
		;;
	3)
		clear
		echo "Preparing to build opensbi.."
		build_opensbi
		;;
	4)
		clear
		echo "Preparing to build kernel.."
		build_kernel
		;;
	5) 
		clear
		echo "Preparing to rebuild kernel.."
		rebuild_kernel
		;;
	6) 
		clear
		echo "Preparing to build rootfs.."
		build_rootfs
		;;
	7) 
		clear
		echo "Preparing to make sd image.."
		make_image
		;;
	*)
		echo "No Option Selected, exiting.."
		;;
esac
