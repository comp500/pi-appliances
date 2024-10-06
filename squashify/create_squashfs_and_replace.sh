#!/bin/bash

#export LIBGUESTFS_DEBUG=1 LIBGUESTFS_TRACE=1

# Ensure the required directories exist
mkdir -p /mnt/ext4_partition /mnt/fat32_partition /dist

cp /dist/distro.qcow2 /workspace/distro.qcow2

# Path to the QCOW2 image
QCOW2_IMAGE="/workspace/distro.qcow2"

# Output SquashFS file
SQUASHFS_IMAGE="/mnt/fat32_partition/distro.squashfs"

# # Use guestfish to mount the second partition (ext4) from the QCOW2 image
# guestfish -a $QCOW2_IMAGE <<_EOF_
#   run
#   mount /dev/sda2 /
#   tar-out / /mnt/ext4_partition/test.tar compress:gzip
#   umount /dev/sda2
#   exit
# _EOF_

# # Create the SquashFS filesystem from the extracted ext4 partition
# mksquashfs /mnt/ext4_partition/test.tar $SQUASHFS_IMAGE -comp xz -b 1M -Xbcj x86 -noappend

# cp $SQUASHFS_IMAGE /dist/

# Use guestfish to wipe the second partition and create a FAT32 partition
guestfish -a $QCOW2_IMAGE <<_EOF_
  run
  part-remove /dev/sda 2
  part-add /dev/sda p 2 2048 -2048
  mkfs fat /dev/sda2
  mount /dev/sda2 /
  copy-in $SQUASHFS_IMAGE /
  umount /dev/sda2
  exit
_EOF_

# Clean up
rm -rf /mnt/ext4_partition /mnt/fat32_partition

echo "SquashFS image created and replaced successfully."
