#!/bin/bash -e


# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]


patch_dir="$(pwd)/patches/"
output_dir="$(pwd)/output"
at91boot_bin="${output_dir}/at91bootstrap"
uboot_bin="${output_dir}/u-boot"
images_dir="${output_dir}/images"
modules_dir="${output_dir}/modules"
rootfs_dir="${output_dir}/rootfs"
overlays_dir="${output_dir}/overlays"


IMAGE_FILE=beaglevdebian.img

SIZE_IN_MB=$(( $(sudo du ./output/rootfs -s | tr -dc '0-9') / 1000 + 256 ))
echo "creating $SIZE_IN_MB MB image"

# Create empty image file
dd if=/dev/zero of=${IMAGE_FILE} bs=1M count=${SIZE_IN_MB}

# Find a free loop
ld=$(losetup --show -f ${IMAGE_FILE})

# create partition layout
sudo sfdisk ${ld} <<-__EOF__
4096,266239,0xE,*
270336,2047,,-
272384,,,-
__EOF__


# add the partitions to the loop
# unmount and remount so losetup can rescan the paritions
losetup -d ${ld}
losetup --partscan ${ld} ${IMAGE_FILE}

# Create boot partition 
mkfs.vfat -F 16 ${ld}p1 -n BOOT

# create rootfs partition
mkfs.ext4 ${ld}p3 -L rootfs

# make dirs for mounting
mkdir -p /media/boot/
mkdir -p /media/rootfs/

# mount the dirs
mount ${ld}p1 /media/boot/
mount ${ld}p3 /media/rootfs/

# copy u-boot
cp -v ${uboot_bin}/u-boot.bin /media/boot/

# copy the rootfs
cp -av ${rootfs_dir} /media/
sync
chown root:root /media/rootfs/
chmod 755 /media/rootfs/

# copy kernel image
cp -v ${images_dir}/Image /media/boot/Image

# copy kernel dtbs
mkdir -p /media/boot/dtbs/
cp -v ${images_dir}/at91-sama5d27_giantboard.dtb /media/boot/dtbs/

# copy kernel modules
cp -av ${modules_dir}/lib/ /media/rootfs/

# copy overlays
mkdir -p /media/boot/overlays/
cp -av ${overlays_dir}/ /media/boot/

# copy the default uEnv.txt
cp -v ${patch_dir}/uEnv.txt /media/boot/

# sync and unmount
sync
umount /media/boot
umount /media/rootfs
losetup -d ${ld}

echo "done making ${IMAGE_FILE}"
