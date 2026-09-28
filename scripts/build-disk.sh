#!/usr/bin/env bash
# Turn the ADI-NAN container image into a bootable disk image using
# bootc-image-builder. Needs rootful podman (runs --privileged), so use sudo.
#
#   TYPE: qcow2 (KVM/libvirt) | raw | ami (AWS) | vmdk | anaconda-iso (installer)
#   Usage:  sudo bash scripts/build-disk.sh qcow2
set -euo pipefail
cd "$(dirname "$0")/.."

IMAGE="${IMAGE:-adi-nan}"
TAG="${TAG:-latest}"
TYPE="${1:-qcow2}"
OUT="$(pwd)/output"
CONFIG="$(pwd)/bootc-image-builder/config.toml"

mkdir -p "$OUT"

echo "Generating '${TYPE}' image from ${IMAGE}:${TAG} ..."
podman run --rm -it --privileged \
  --security-opt label=type:unconfined_t \
  -v "${OUT}:/output" \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  -v "${CONFIG}:/config.toml:ro" \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type "${TYPE}" \
  --local "${IMAGE}:${TAG}"

echo
echo "Image written to ${OUT}/"
ls -lh "$OUT"
