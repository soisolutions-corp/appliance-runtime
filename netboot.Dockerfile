# renovate: datasource=github-releases depName=kairos-io/osbuilder
ARG OSBUILDER_VERSION=0.400.3
ARG APPLIANCE_RUNTIME_VERSION
ARG ISO_NAME=soisolutions-${TARGETARCH}-${APPLIANCE_RUNTIME_VERSION}

FROM ghcr.io/soisolutions-corp/appliance-runtime:$APPLIANCE_RUNTIME_VERSION AS image
FROM --platform=$BUILDPLATFORM quay.io/kairos/osbuilder-tools:v$OSBUILDER_VERSION AS builder
ARG ISO_NAME
WORKDIR /build
COPY . ./
COPY --from=image /IMAGE ./
COPY --from=image / ./image/
RUN /entrypoint.sh --name $ISO_NAME --debug build-iso --squash-no-compression --date=false dir:/build/image --output /build/

WORKDIR /netboot
RUN isoinfo -x /rootfs.squashfs -R -i /build/${ISO_NAME}.iso > ${ISO_NAME}.squashfs
RUN isoinfo -x /boot/kernel -R -i /build/${ISO_NAME}.iso > ${ISO_NAME}-kernel
RUN isoinfo -x /boot/initrd -R -i /build/${ISO_NAME}.iso > ${ISO_NAME}-initrd

FROM scratch AS final
ARG ISO_NAME
COPY --from=builder /build/$ISO_NAME.iso /build/$ISO_NAME.iso
COPY --from=builder /build/$ISO_NAME.iso.sha256 /build/$ISO_NAME.iso.sha256
COPY --from=builder /netboot /build/
