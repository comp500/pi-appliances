# Use an Ubuntu base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary tools
RUN apt-get update && apt-get install -y \
    libguestfs-tools \
    e2fsprogs \
    mtools \
    dosfstools \
    squashfs-tools \
    parted \
	linux-image-generic \
    && rm -rf /var/lib/apt/lists/*

# Create the working directory
WORKDIR /workspace

# Copy the script to the container
COPY create_squashfs_and_replace.sh /workspace/create_squashfs_and_replace.sh

# Make the script executable
RUN chmod +x /workspace/create_squashfs_and_replace.sh

# Set the default command to run the script
CMD ["/workspace/create_squashfs_and_replace.sh"]
