# syntax=docker/dockerfile:1
FROM raspios:latest

# TODO: Add /etc/fstab contents so fsck hook can detect the mounted filesystems

# Don't allow starting services or updating initramfs during apt update
RUN sed -i 's/^update_initramfs=.*/update_initramfs=no/' /etc/initramfs-tools/update-initramfs.conf
COPY --chmod=755 <<EOF /usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked apt-get update && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

RUN sed -i 's/^update_initramfs=.*/update_initramfs=all/' /etc/initramfs-tools/update-initramfs.conf
RUN rm /usr/sbin/policy-rc.d

# Copy new initramfs scripts
COPY --chmod=755 initramfs-tools/ /etc/initramfs-tools/

RUN update-initramfs -v -u -k all

# TODO: Clean up apt and machine ID

# TODO: Merge into single layer