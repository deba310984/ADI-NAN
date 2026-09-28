# ADI-NAN

**A Fedora `bootc` operating system built for DevOps and cloud engineers.**

ADI-NAN is an *image-based* Linux OS: the entire system is defined in a
`Containerfile`, built like a container image, and shipped as bootable disk
images (VM `qcow2`, cloud AMI/VHD, or an installer ISO). Updates are atomic
and roll back cleanly — the OS is code, versioned in git and built in CI.

It comes with the DevOps/cloud toolchain and sane defaults preinstalled, so a
fresh boot is ready to talk to Kubernetes and the big three clouds.

---

## What's inside

| Category      | Tools |
|---------------|-------|
| Containers    | podman, buildah, skopeo, cosign |
| Kubernetes    | kubectl, helm, k9s, kustomize, stern, kubectx/kubens, argocd, flux |
| IaC / config  | OpenTofu (`tofu`), Ansible |
| Cloud CLIs    | AWS CLI v2, Azure CLI, Google Cloud CLI |
| Secrets       | sops, age |
| Dev / CI      | git, git-lfs, gh, direnv, mise, pre-baked completions |
| Shell / TUI   | zsh + starship (kube/cloud-aware prompt), fish, tmux, neovim, fzf, ripgrep, bat, btop, fastfetch |
| Net / debug   | dig, nmap, tcpdump, mtr, httpie, socat, jq, yq |

> The OS `ID` in `/etc/os-release` stays `fedora` on purpose so `dnf` and other
> Fedora tooling keep working; only the display name is branded ADI-NAN.

## Repository layout

```
ADI-NAN/
├── Containerfile               # the OS definition (start here)
├── packages/
│   ├── dnf-packages.txt        # packages from Fedora repos (edit freely)
│   └── tools.sh                # tools not in repos, version-pinned
├── files/                      # configs copied verbatim into the image (/)
│   └── etc/…                   # profile.d, /etc/skel dotfiles, motd, starship
├── bootc-image-builder/
│   └── config.toml             # users, filesystem, kernel args for disk images
├── scripts/
│   ├── build.sh                # build the container image (podman)
│   └── build-disk.sh           # produce a bootable disk (bootc-image-builder)
├── .github/workflows/build.yml # CI: build + push image to ghcr.io
└── README.md
```

## Prerequisites

You need a **Linux build host** with `podman` (you cannot build Linux images on
Windows directly). On Windows 11, the easiest path is **WSL2**:

```bash
# in an Ubuntu WSL2 shell
sudo apt update && sudo apt install -y podman
```

Or build entirely in CI (see below) and only need a Linux VM to boot-test.

## Quickstart

```bash
# 1. Build the OS container image
bash scripts/build.sh
# -> adi-nan:latest

# 2. Sanity-check the toolchain inside it
podman run --rm -it adi-nan:latest bash -lc 'kubectl version --client; tofu version; aws --version'

# 3. Build a bootable VM disk (needs root for privileged podman)
sudo bash scripts/build-disk.sh qcow2
# -> output/qcow2/disk.qcow2

# 4. Boot it (example with libvirt/virt-install, or import into your hypervisor)
#    Edit bootc-image-builder/config.toml first to add YOUR ssh key.
```

Other disk types: `sudo bash scripts/build-disk.sh ami` (AWS), `raw`, `vmdk`,
`anaconda-iso` (a graphical installer ISO for bare metal / VirtualBox).

## Continuous builds (CI)

`.github/workflows/build.yml` builds the image on every push to `main`, on a
weekly schedule (to absorb upstream Fedora updates), and on demand. It pushes to
the GitHub Container Registry:

```
ghcr.io/<your-user>/adi-nan:latest
```

No secrets to configure — it uses the built-in `GITHUB_TOKEN`. After the first
successful run, make the package public in your GitHub **Packages** settings if
you want to pull it without authenticating. A running ADI-NAN machine can then
update itself with:

```bash
sudo bootc upgrade      # pulls the newest image, stages it, reboot to apply
```

## Customizing

- **Add/remove repo packages** → edit `packages/dnf-packages.txt`.
- **Add a tool not in Fedora** → add a block to `packages/tools.sh` (pin its version).
- **Change defaults/dotfiles** → drop files under `files/` mirroring the target path
  (e.g. `files/etc/skel/.zshrc` lands at `/etc/skel/.zshrc`).
- **Change users / disk / kernel args** → edit `bootc-image-builder/config.toml`.

Rebuild after any change: `bash scripts/build.sh`.

## Roadmap ideas

- [ ] A local `k3s` / `kind` cluster that comes up on first boot
- [ ] Signed images (`cosign`) + verified `bootc` updates
- [ ] A desktop variant (GNOME) for engineer workstations
- [ ] Preconfigured `mise` toolset (Go, Node, Python) via a committed `mise.toml`
- [ ] Hardening pass (SSH, firewalld defaults, auditd)

## How it works (the short version)

`bootc` boots a machine from an OCI container image and manages it transactionally
via ostree. You define the OS declaratively (this repo), build it as an image, and
`bootc-image-builder` renders that image into whatever disk format your target
platform wants. Same artifact runs as a VM, a cloud instance, or bare metal.

Learn more: [bootc](https://containers.github.io/bootc/) ·
[Fedora bootc](https://docs.fedoraproject.org/en-US/bootc/) ·
[Universal Blue](https://universal-blue.org/) (a large real-world example).
