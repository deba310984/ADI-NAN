#!/usr/bin/env bash
# Build the ADI-NAN bootc container image locally with podman.
#   Usage:  bash scripts/build.sh
set -euo pipefail
cd "$(dirname "$0")/.."

IMAGE="${IMAGE:-adi-nan}"
TAG="${TAG:-latest}"

echo "Building ${IMAGE}:${TAG} ..."
podman build -t "${IMAGE}:${TAG}" .

echo
echo "Built ${IMAGE}:${TAG}"
echo "  Inspect:  podman run --rm -it ${IMAGE}:${TAG} bash"
echo "  Disk:     sudo bash scripts/build-disk.sh qcow2"
