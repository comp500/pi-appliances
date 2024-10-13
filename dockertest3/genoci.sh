#!/bin/bash
set -e

# This script must be run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# Variables
IMAGE_URL="https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz"
TMPFS_DIR="/mnt/tmpfs_work"
WORK_DIR="/home/comp500/raspiosworkdir"
TMPFS_SIZE="4G"  # Adjust the size according to your available RAM

# Install dependencies
apt-get update
apt-get install -y wget xz-utils kpartx

# Create and mount tmpfs for working directory
mkdir -p "$TMPFS_DIR"
mount -t tmpfs -o size=$TMPFS_SIZE tmpfs "$TMPFS_DIR"

# Download the Raspberry Pi OS Lite 64-bit image into tmpfs
wget -O "$TMPFS_DIR/raspios_lite_latest.img.xz" "$IMAGE_URL"

# Decompress the image in tmpfs
unxz "$TMPFS_DIR/raspios_lite_latest.img.xz"

# Find the .img file in tmpfs
IMAGE_FILE="$TMPFS_DIR/raspios_lite_latest.img"
if [ ! -f "$IMAGE_FILE" ]; then
    echo "Image file not found!"
    umount "$TMPFS_DIR"
    rm -rf "$TMPFS_DIR"
    exit 1
fi

# Setup loop device and map partitions
losetup -fP "$IMAGE_FILE"
LOOP_DEV=$(losetup -l | grep "$IMAGE_FILE" | awk '{print $1}')

# Use kpartx to create device mappings
kpartx -av "$LOOP_DEV"

# Wait for the device nodes to be available
udevadm settle

# Find the mapped partitions
LOOP_NAME=$(basename "$LOOP_DEV")
BOOT_PART="/dev/mapper/${LOOP_NAME}p1"
ROOT_PART="/dev/mapper/${LOOP_NAME}p2"

# Create mount points in tmpfs
MOUNT_DIR="$TMPFS_DIR/mount"
mkdir -p "$MOUNT_DIR/boot"

# Mount partitions
mount "$ROOT_PART" "$MOUNT_DIR"
mount "$BOOT_PART" "$MOUNT_DIR/boot"

# Create a tarball of the root filesystem and pipe it to docker import
tar --numeric-owner -cf - -C "$MOUNT_DIR" . | docker import --platform linux/arm64 - raspios:latest

echo "Docker image 'raspios:latest' has been created."

# Clean up mounts and loop devices
umount "$MOUNT_DIR/boot"
umount "$MOUNT_DIR"
kpartx -dv "$LOOP_DEV"
losetup -d "$LOOP_DEV"

# Unmount and remove tmpfs
umount "$TMPFS_DIR"
rm -rf "$TMPFS_DIR"
