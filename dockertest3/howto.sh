docker run --privileged --rm tonistiigi/binfmt --install all
./genoci.sh
docker build --platform linux/arm64 -t base-image .
docker save base-image -o image.tar
./tosquashfs.sh