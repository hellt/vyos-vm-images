FROM ghcr.io/srl-labs/ansible-core/2.15.9:py3.11

RUN ansible-galaxy collection install ansible.posix:1.5.4 community.general:8.5.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    dosfstools \
    e2fsprogs \
    gdisk \
    grub-common \
    grub-efi-amd64-bin \
    kpartx \
    python3-lxml \
    python3-requests \
    qemu-utils \
    rsync \
    squashfs-tools \
    util-linux \
    xorriso \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ansible
