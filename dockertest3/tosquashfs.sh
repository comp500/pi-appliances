#!/bin/bash
set -eux

image="image.tar"

# Extract manifest digest from index.json
manifest_digest=$(tar -xOf $image index.json | jq -r '.manifests[0].digest')
manifest_digest=${manifest_digest#sha256:}
manifest_file="blobs/sha256/$manifest_digest"

# Extract layer digests from the manifest file
layer_digests=$(tar -xOf $image $manifest_file | jq -r '.layers[].digest' | sed 's/^sha256://')

# Create a directory for layers
mkdir -p layers

# Iterate over each layer digest
for digest in $layer_digests; do
    layer_tar="blobs/sha256/$digest"
    layer_dir="layers/$digest"

    # Get mediaType for the layer
    media_type=$(tar -xOf $image $manifest_file | jq -r --arg digest "sha256:$digest" '.layers[] | select(.digest==$digest) | .mediaType')

    # Handle compression based on mediaType
	squashfs_file="layers/$digest.squashfs"

    if [[ "$media_type" == *"tar+gzip"* ]]; then
		tar -xOf $image $layer_tar | gunzip -c | sqfstar "$squashfs_file" -comp xz -noappend
    elif [[ "$media_type" == *"tar"* ]]; then
        tar -xOf $image $layer_tar | sqfstar "$squashfs_file" -comp xz -noappend
    else
        echo "Unknown media type for layer $digest: $media_type"
        continue
    fi

    echo "Created SquashFS file: $squashfs_file"
done