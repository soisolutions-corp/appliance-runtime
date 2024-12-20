ARG BASE_IMAGE=debian:bookworm-slim@sha256:a629e796d77a7b2ff82186ed15d01a493801c020eed5ce6adaa2704356f15a1c
# renovate: datasource=docker depName=kairos/packages
ARG DRACUT_NETWORK_VERSION=kairos-network-dracut-1.1.0
# renovate: datasource=docker depName=kairos/packages
ARG DRACUT_SYSEXT_VERSION=kairos-sysext-dracut-1.0.0
# renovate: datasource=docker depName=kairos/packages
ARG SUC_UPGRADE_VERSION=suc-upgrade-system-0.3.1
# renovate: datasource=docker depName=kairos/packages
ARG GRUB_CONFIG_VERSION=grub-config-static-0.11
# renovate: datasource=docker depName=kairos/packages
ARG OVERLAY_FILES_VERSION=kairos-overlay-files-static-1.5.1
# renovate: datasource=docker depName=kairos/packages
ARG ALPINE_INITRD_VERSION=alpine-initrd-3.8.2
# renovate: datasource=docker depName=kairos/packages
ARG KCRYPT_VERSION=kcrypt-system-0.12.2
# renovate: datasource=docker depName=kairos/packages
ARG KCRYPT_CHALLENGER_VERSION=kcrypt-challenger-system-0.9.1
# renovate: datasource=github-releases depName=kairos-io/immucore
ARG IMMUCORE_VERSION=0.6.1
# renovate: datasource=github-releases depName=kairos-io/kairos-agent
ARG KAIROS_AGENT_VERSION=2.15.4
# renovate: datasource=github-releases depName=kairos-io/provider-kairos
ARG KAIROS_PROVIDER_VERSION=2.7.5
# renovate: datasource=docker depName=ghcr.io/soisolutions-corp/k3s
ARG K3S_VERSION=v1.31.2-k3s1
ARG RELEASE

FROM quay.io/kairos/packages:${DRACUT_NETWORK_VERSION} AS dracut-kairos-network
FROM quay.io/kairos/packages:${DRACUT_SYSEXT_VERSION} AS dracut-kairos-sysext
FROM quay.io/kairos/packages:${SUC_UPGRADE_VERSION} AS suc-upgrade
FROM quay.io/kairos/packages:${GRUB_CONFIG_VERSION} AS grub-config
FROM quay.io/kairos/packages:${OVERLAY_FILES_VERSION} AS overlay-files
FROM quay.io/kairos/packages:${ALPINE_INITRD_VERSION} AS alpine-initrd
FROM quay.io/kairos/packages:${KCRYPT_VERSION} AS kcrypt
FROM quay.io/kairos/packages:${KCRYPT_CHALLENGER_VERSION} AS kcrypt-challenger
FROM quay.io/kairos/packages:immucore-system-${IMMUCORE_VERSION} AS immucore
FROM quay.io/kairos/packages:kairos-agent-system-${KAIROS_AGENT_VERSION} AS kairos-agent
FROM quay.io/kairos/packages:provider-kairos-system-${KAIROS_PROVIDER_VERSION} AS provider-kairos
FROM ghcr.io/soisolutions-corp/k3s:${K3S_VERSION} AS k3s
FROM ${BASE_IMAGE} AS builder

ARG BASE_IMAGE
ARG RELEASE
ARG FRAMEWORK_VERSION
ARG K3S_VERSION
ARG TARGETPLATFORM
ARG TARGETARCH
ARG FAMILY="debian"
ARG FLAVOR="debian"
ARG FLAVOR_RELEASE="bookworm-slim"
ARG MODEL="generic"
ARG VARIANT="standard"
ARG SOFTWARE_VERSION=${K3S_VERSION}
ARG VERSION=${RELEASE}-k3s-${SOFTWARE_VERSION}
ARG SOFTWARE_VERSION_PREFIX=-
ARG HOME_URL="https://github.com/soisolutions-corp/appliance-runtime"
ARG BUG_REPORT_URL="https://github.com/soisolutions-corp/appliance-runtime/issues"
ARG GITHUB_REPO="soisolutions-corp/appliance-runtime"
ARG ID="appliance-runtime"
ARG REGISTRY_AND_ORG="ghcr.io/soisolutions-corp"

LABEL org.opencontainers.image.authors="SOI Solutions, LLC <sales@soisolutions.co>"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.url="https://github.com/soisolutions-corp/appliance-runtime"
LABEL org.opencontainers.image.source="https://github.com/soisolutions-corp/appliance-runtime.git"
LABEL io.kairos.base_image="${BASE_IMAGE}"
LABEL io.kairos.variant="${VARIANT}"
LABEL io.kairos.family="${FAMILY}"
LABEL io.kairos.flavor="${FLAVOR}"
LABEL io.kairos.flavor_release="${FLAVOR_RELEASE}"
LABEL io.kairos.model="${MODEL}"
LABEL io.kairos.release="${RELEASE}"
LABEL io.kairos.framework-version="${FRAMEWORK_VERSION}"
LABEL io.kairos.software-version="${SOFTWARE_VERSION}"
LABEL io.kairos.software-version-prefix="${SOFTWARE_VERSION_PREFIX}"
LABEL io.kairos.targetarch="${TARGETARCH}"
LABEL io.kairos.k3s_version="${SOFTWARE_VERSION}"

# Install Kairos packages
COPY --from=dracut-kairos-network / /
COPY --from=dracut-kairos-sysext / /
COPY --from=suc-upgrade / /
COPY --from=grub-config / /
COPY --from=overlay-files / /
COPY --from=alpine-initrd / /
COPY --from=kcrypt / /
COPY --from=kcrypt-challenger / /
COPY --from=immucore / /
COPY --from=kairos-agent / /
COPY --from=provider-kairos / /
COPY --from=k3s / /

ENV DEBIAN_FRONTEND=noninteractive
RUN if [ "${TARGETARCH}" = "amd64" ]; then \
    apt-get update && apt-get install -y --no-install-recommends grub-pc-bin \
    && apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi
RUN apt-get update && apt-get install -y --no-install-recommends \
    binutils \
    ca-certificates \
    cloud-guest-utils \
    conntrack \
    console-setup \
    coreutils \
    cryptsetup \
    curl \
    debianutils \
    dmraid \
    dosfstools \
    dracut \
    dracut-live \
    dracut-network \
    e2fsprogs \
    e2fsprogs-l10n \
    efibootmgr \
    ethtool \
    firmware-linux-free \
    fuse3 \
    gawk \
    gdisk \
    gnupg \
    gnupg1-l10n \
    grub-efi \
    grub-efi-${TARGETARCH}-signed \
    haveged \
    iproute2 \
    iptables \
    iputils-ping \
    isc-dhcp-common \
    isc-dhcp-client \
    jq \
    libglib2.0-data \
    libgpm2 \
    libnss-systemd \
    libpam-cap \
    linux-image-${TARGETARCH} \
    lvm2 \
    mdadm \
    nbd-client \
    nfs-common \
    nftables \
    nohang \
    open-iscsi \
    openssh-server \
    open-vm-tools \
    os-prober \
    parted \
    patch \
    pkg-config \
    polkitd \
    psmisc \
    publicsuffix \
    qemu-guest-agent \
    rsync \
    shim-signed \
    squashfs-tools \
    sudo \
    systemd \
    systemd-resolved \
    systemd-sysv \
    systemd-timesyncd \
    tar \
    xxd \
    xz-utils \
    zerofree \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN systemctl enable systemd-networkd

# Symlinks to make elemental installer work
RUN ORIG=/usr/sbin/grub-install; DEST=/usr/sbin/grub2-install; [ -e $ORIG ] && [ ! -e $DEST ] && ln -s $ORIG $DEST || true
RUN ORIG=/usr/bin/grub-editenv; DEST=/usr/sbin/grub2-editenv; [ -e $ORIG ] && [ ! -e $DEST ] && ln -s $ORIG $DEST || true

# symlink initrd
RUN kernel=$(ls /boot/initrd.* 2>/dev/null | head -n1) &&  if [ -e "$kernel" ]; then ln -sf "$kernel" /boot/initrd; fi || true

# symlink kernel to /boot/vmlinuz
RUN kernel=$(ls /boot/vmlinuz-* 2>/dev/null | head -n1) && if [ -e "$kernel" ]; then ln -sf "$kernel" /boot/vmlinuz; fi || true
RUN kernel=$(ls /boot/Image* 2>/dev/null | head -n1) && if [ -e "$kernel" ]; then ln -sf "$kernel" /boot/vmlinuz; fi || true

# Set release information
RUN kairos-agent versioneer os-release-variables > /etc/kairos-release
RUN kairos-agent versioneer container-artifact-name | tee /IMAGE

# Set empty machine-id
# This prevents systemd from thinking that the machine is on first boot
# and recreating /etc/ dependencies in services and such
# do this before initramfs so its in the initramfs
RUN echo "" > /etc/machine-id || true

# General image cleanup
RUN rm -rf /etc/machine-id
RUN rm -rf /etc/ssh/ssh_host_*
RUN rm -rf /boot/initramfs-* || true
RUN rm /etc/machine-id || true
RUN rm /var/lib/dbus/machine-id || true
RUN rm /etc/hostname || true
RUN journalctl --vacuum-size=1K
RUN rm -rf /tmp/*
RUN rm -rf /var/cache/apt /var/lib/apt
RUN rm -rf /var/cache/debconf
RUN rm -rf /var/lib/dpkg

# Flatten the image
FROM scratch
COPY --from=builder / /
