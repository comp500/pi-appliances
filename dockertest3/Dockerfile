# syntax=docker/dockerfile:1
FROM raspios:latest

# Add /etc/fstab contents so fsck hook can detect the mounted filesystems

# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOT
# apt-get update
# apt-get upgrade -y
# EOT
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked apt-get update && apt-get upgrade -y

# Copy new initramfs scripts

RUN update-initramfs -v -u -k all

# Clean up apt and machine ID