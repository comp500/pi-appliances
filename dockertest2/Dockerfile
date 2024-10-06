# syntax=docker/dockerfile:1-labs

FROM debian:bullseye AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        git vim parted \
        quilt coreutils qemu-user-static debootstrap zerofree zip dosfstools \
        libarchive-tools libcap2-bin rsync grep udev xz-utils curl xxd file kmod bc \
        binfmt-support ca-certificates fdisk gpg pigz arch-test \
    && rm -rf /var/lib/apt/lists/*

ADD https://github.com/RPi-Distro/pi-gen.git#48efb5fc5485fafdc9de8ad481eb5c09e1182656 /pi-gen/

VOLUME ["/pi-gen/work", "/pi-gen/deploy"]

WORKDIR /pi-gen

RUN dpkg-reconfigure qemu-user-static

RUN touch ./stage1/SKIP ./stage2/SKIP ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
RUN touch ./stage2/SKIP_IMAGES ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES

ENV GIT_HASH=48efb5fc5485fafdc9de8ad481eb5c09e1182656

RUN --security=insecure mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc && \
	./build.sh && \
	rsync -av work/*/build.log deploy/

RUN rm ./stage1/SKIP && touch ./stage0/SKIP

RUN --security=insecure mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc && \
	./build.sh && \
	rsync -av work/*/build.log deploy/

RUN rm ./stage2/SKIP ./stage2/SKIP_IMAGES && touch ./stage1/SKIP

RUN ln -s /proc/mounts /etc/mtab

RUN --security=insecure mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc && \
	./build.sh && \
	rsync -av work/*/build.log deploy/

FROM scratch
COPY --from=builder /pi-gen/deploy/ /