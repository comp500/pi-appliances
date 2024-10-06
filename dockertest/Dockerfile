# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM rust:alpine AS builder
RUN apk add clang lld pkgconfig
COPY --from=xx / /

WORKDIR /app
ADD https://github.com/Spotifyd/spotifyd.git#e280d84124d854af3c2f9509ba496b1c2ba6a1ae .

RUN --mount=type=cache,target=/root/.cargo/git/db \
    --mount=type=cache,target=/root/.cargo/registry/cache \
    --mount=type=cache,target=/root/.cargo/registry/index \
    cargo fetch
ARG TARGETPLATFORM
RUN xx-apk add --no-cache alsa-lib alsa-lib-dev gcc musl-dev
ENV RUSTFLAGS="-C target-feature=-crt-static"
RUN --mount=type=cache,target=/root/.cargo/git/db \
    --mount=type=cache,target=/root/.cargo/registry/cache \
    --mount=type=cache,target=/root/.cargo/registry/index \
    xx-cargo build --release --target-dir ./build && \
    xx-verify ./build/$(xx-cargo --print-target-triple)/release/spotifyd
RUN cp ./build/$(xx-cargo --print-target-triple)/release/spotifyd spotifyd

FROM alpine AS main
RUN apk add alsa-lib libgcc
COPY --from=builder /app/spotifyd /usr/local/bin/spotifyd