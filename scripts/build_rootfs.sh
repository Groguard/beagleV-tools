#!/bin/bash  

                                                                                                                               
# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]


output_dir="$(pwd)/output"
tools_dir="$(pwd)/tools"
patch_dir="$(pwd)/patches/rootfs"
rootfs_dir="${output_dir}/rootfs"

if [ ! -d "${rootfs_dir}" ]; then
	echo "Log: (debootstrap) no minimum rootfs found. Building minimum rootfs to save time in the future."
	mkdir ${rootfs_dir}
fi

debootstrap \
		--arch=riscv64 \
		--foreign \
		--variant=minbase \
		--keyring /usr/share/keyrings/debian-ports-archive-keyring.gpg \
		--include=debian-ports-archive-keyring unstable \
		${rootfs_dir} \
		http://deb.debian.org/debian-ports

cp /usr/bin/qemu-riscv64-static ${rootfs_dir}/usr/bin/
cp scripts/chroot_min.sh ${rootfs_dir}


chroot ${rootfs_dir} /debootstrap/debootstrap --second-stage

mount -t proc /proc ${rootfs_dir}/proc
mount -t sysfs /sys ${rootfs_dir}/sys
mount -o bind /dev ${rootfs_dir}/dev


chroot ${rootfs_dir} /bin/bash -e chroot_min.sh
rm ${rootfs_dir}/chroot_min.sh
sync

umount -fl ${rootfs_dir}/proc
umount -fl ${rootfs_dir}/sys
umount -fl ${rootfs_dir}/dev

rm ${rootfs_dir}/usr/bin/qemu-riscv64-static

tar -C ${rootfs_dir} -czf ${output_dir}/rootfs.tar.gz .
