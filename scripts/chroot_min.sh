#!/bin/bash

rfs_username="debian"
rfs_password="temppwd"
rfs_fullname="debian"
rfs_hostname="beaglev"

export LC_ALL=C
export LANGUAGE=C
export LANG=C

add_user () {
	echo "Log: (chroot): add_user"
	groupadd -r admin || true
	groupadd -r spi || true
	cat /etc/group | grep ^i2c || groupadd -r i2c || true
	cat /etc/group | grep ^kmem || groupadd -r kmem || true
	cat /etc/group | grep ^netdev || groupadd -r netdev || true
	cat /etc/group | grep ^systemd-journal || groupadd -r systemd-journal || true
	cat /etc/group | grep ^gpio || groupadd -r gpio || true
	cat /etc/group | grep ^pwm || groupadd -r pwm || true
	cat /etc/group | grep ^eqep || groupadd -r eqep || true
	#echo "KERNEL==\"hidraw*\", GROUP=\"plugdev\", MODE=\"0660\"" > /etc/udev/rules.d/50-hidraw.rules
	#echo "KERNEL==\"spidev*\", GROUP=\"spi\", MODE=\"0660\"" > /etc/udev/rules.d/50-spi.rules
	#echo "#SUBSYSTEM==\"uio\", SYMLINK+=\"uio/%s{device/of_node/uio-alias}\"" > /etc/udev/rules.d/uio.rules
	#echo "SUBSYSTEM==\"uio\", GROUP=\"users\", MODE=\"0660\"" >> /etc/udev/rules.d/uio.rules
	default_groups="admin,adm,dialout,gpio,pwm,eqep,i2c,kmem,spi,cdrom,floppy,audio,dip,video,netdev,plugdev,users,systemd-journal"


	echo "Log: (chroot) adding admin group to /etc/sudoers.d/admin"
	echo "Defaults	env_keep += \"NODE_PATH\"" >/etc/sudoers.d/admin
	echo "%admin ALL=(ALL:ALL) ALL" >>/etc/sudoers.d/admin
	chmod 0440 /etc/sudoers.d/admin
	chmod u+s /bin/ping
	
	pass_crypt=$(perl -le "print crypt("${rfs_password}", "beaglev")")
	useradd -G "${default_groups}" -s /bin/bash -m -p ${pass_crypt} -c "${rfs_fullname}" ${rfs_username}
	grep ${rfs_username} /etc/passwd
	mkdir -p /home/${rfs_username}/bin
	chown ${rfs_username}:${rfs_username} /home/${rfs_username}/bin
	
	#set root password
	passwd <<-EOF
	root
	root
	EOF

	sed -i -e 's:#EXTRA_GROUPS:EXTRA_GROUPS:g' /etc/adduser.conf
	sed -i -e 's:dialout:dialout i2c spi:g' /etc/adduser.conf
	sed -i -e 's:#ADD_EXTRA_GROUPS:ADD_EXTRA_GROUPS:g' /etc/adduser.conf

}

# Add sources
cat <<EOT > /etc/apt/sources.list

deb http://ftp.ports.debian.org/debian-ports/ sid main non-free
deb http://ftp.ports.debian.org/debian-ports/ unreleased main non-free
deb-src http://ftp.ports.debian.org/debian-ports/ sid main non-free

EOT

# Update sources
echo "Log: (chroot_min) apt-get updating rootfs packages."
apt-get update
echo "Log: (chroot_min) apt-get update complete."


echo "Log: (chroot_min) adding ${rfs_username} user"
add_user

cat > /etc/motd <<'EOF'
   _____ _             _     ____                      _
  / ____(_)           | |   |  _ \                    | |
 | |  __ _  __ _ _ __ | |_  | |_) | ___   __ _ _ __ __| |
 | | |_ | |/ _` | '_ \| __| |  _ < / _ \ / _` | '__/ _` |
 | |__| | | (_| | | | | |_  | |_) | (_) | (_| | | | (_| |
  \_____|_|\__,_|_| |_|\__| |____/ \___/ \__,_|_|  \__,_|

EOF

# Set new hostname
echo ${rfs_hostname} > /etc/hostname

# Set new hostname in hosts
sed -i -e 's/localhost/beaglev/g' /etc/hosts

apt-get clean

sh -c "echo 'UUID=29f097dc-eba8-4043-a650-cfd06eef5461  / ext4    defaults,noatime,x-systemd.device-timeout=300s,x-systemd.mount-timeout=300s 0 0' >> /etc/fstab"
sh -c "echo 'UUID=7e005261-8c02-43d8-9da4-ee1ee04c5db0  /boot ext4    defaults,noatime,x-systemd.device-timeout=300s,x-systemd.mount-timeout=300s 0 0' >> /etc/fstab"

echo "Log: (chroot_min) chroot_min complete, exiting.."

exit
