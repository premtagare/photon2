#!/bin/bash
# setup_floppy.sh

sudo mkfs.msdos floppy_photon.img
sudo losetup /dev/loop0 floppy_photon.img
sudo mount /dev/loop0 /mnt
sudo dd if=src/bootloader/loadb.bin of=/dev/loop0 ibs=1 obs=1 seek=62 count=450 conv=notrunc
sudo cp src/bootloader/loadk.bin /mnt
sudo cp src/kernel/kernel.bin /mnt
sudo umount /dev/loop0
sudo losetup -d /dev/loop0
