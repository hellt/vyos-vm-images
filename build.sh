#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
image=vyos-vm-images:latest
iso_url=${VYOS_ISO_URL:-https://community-downloads.vyos.dev/stream/2026.03/vyos-2026.03-generic-amd64.iso}

docker build --tag "$image" "$repo_dir"
mkdir -p "$repo_dir/images" "$repo_dir/.cache"

docker run --rm --privileged \
    --volume "$repo_dir:/ansible:ro" \
    --volume "$repo_dir/images:/images" \
    --volume "$repo_dir/.cache:/cache" \
    --workdir /ansible \
    "$image" \
    ansible-playbook qemu.yml \
    -e iso_local=/cache/vyos.iso \
    -e vyos_iso_url="$iso_url" \
    -e disk_size="${DISK_SIZE:-10}" \
    -e cloud_init=true \
    -e cloud_init_ds="${CLOUD_INIT_DS:-NoCloud,ConfigDrive,None}" \
    -e vyos_images_dir=/images \
    "$@"
