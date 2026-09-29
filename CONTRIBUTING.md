# Contributing to ADI-NAN

Thanks for your interest! ADI-NAN is a Fedora `bootc` OS defined entirely in this
repo, so "contributing" mostly means editing declarative files and rebuilding the
image. This guide gets you from zero to a tested change.

## Prerequisites

You need a **Linux host with `podman`** — Linux OS images can't be built on Windows
or macOS directly. Options:

- **WSL2** on Windows (`sudo apt install -y podman`)
- Any Linux box or VM
- Or skip local builds entirely and let **GitHub Actions** build your PR

## Build & test locally

```bash
# Build the OS image
bash scripts/build.sh                 # -> adi-nan:latest

# Verify the toolchain landed
podman run --rm -it adi-nan:latest bash -lc 'kubectl version --client; tofu version'

# (optional) render a bootable VM disk to smoke-test a real boot
sudo bash scripts/build-disk.sh qcow2
```

## Making changes

| You want to… | Edit this |
|---|---|
| Add/remove a Fedora package | `packages/dnf-packages.txt` |
| Add a tool not in Fedora repos | `packages/tools.sh` (pin the version) |
| Change a default config / dotfile | `files/…` (mirror the real target path, e.g. `files/etc/skel/.zshrc`) |
| Change users, disk size, kernel args | `bootc-image-builder/config.toml` |
| Change how the OS is assembled | `Containerfile` |

**Always rebuild** (`bash scripts/build.sh`) before opening a PR — a green local build
is the bar for review.

## Line endings (important on Windows)

Every file here is consumed by Linux at build time. A `.gitattributes` forces **LF**
endings so shell scripts don't break with `\r`. Don't override it, and don't commit
CRLF line endings in `*.sh` or the `Containerfile`.

## Pull requests

1. Fork and branch from `main` (e.g. `git checkout -b add-flux-dashboard`).
2. Make your change and rebuild locally.
3. Keep the diff focused; one logical change per PR.
4. Open the PR — CI builds it automatically. A red build blocks merge.
5. Describe **what** changed and **why**, and note anything you couldn't test.

## Reporting issues

Open an issue with:

- what you expected vs. what happened,
- the build/boot step where it failed, and
- the relevant log output (the cloud-CLI installs in `tools.sh` are the most common
  point of failure — include that section's output if it's involved).

Happy building! 🚀
