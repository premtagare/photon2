#!/bin/bash
# system_boot.sh
# mounts the correct loopback device, runs QEMU, then unmounts.

sudo /sbin/losetup /dev/loop0 floppy_photon.img
#sudo qemu -fda /dev/loop0 -S -gdb tcp::5022
sudo qemu -fda /dev/loop0
sudo /sbin/losetup -d /dev/loop0 
