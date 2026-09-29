<p align="center">
  <img src="docs/banner.svg" alt="ADI-NAN — a Fedora bootc OS for DevOps & Cloud engineers" width="100%">
</p>

<h1 align="center">ADI-NAN</h1>

<p align="center">
  <b>An image-based Linux OS, built like a container, shipped like a cloud image —</b><br>
  purpose-built for DevOps and cloud engineers, with the whole toolchain baked in.
</p>

<p align="center">
  <a href="https://github.com/deba310984/ADI-NAN/actions/workflows/build.yml"><img src="https://github.com/deba310984/ADI-NAN/actions/workflows/build.yml/badge.svg" alt="Build status"></a>
  <img src="https://img.shields.io/badge/base-Fedora%20bootc%2041-51A2DA?logo=fedora&logoColor=white" alt="Base: Fedora bootc 41">
  <img src="https://img.shields.io/badge/built%20with-bootc-1793D1" alt="Built with bootc">
  <img src="https://img.shields.io/badge/PRs-welcome-b18cff" alt="PRs welcome">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-3fb950" alt="License: MIT"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Podman-892CA0?style=for-the-badge&logo=podman&logoColor=white" alt="Podman">
  <img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" alt="Kubernetes">
  <img src="https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white" alt="Helm">
  <img src="https://img.shields.io/badge/OpenTofu-FFDA18?style=for-the-badge&logo=opentofu&logoColor=black" alt="OpenTofu">
  <img src="https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white" alt="Ansible">
  <img src="https://img.shields.io/badge/Argo%20CD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white" alt="Argo CD">
  <br>
  <img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonwebservices&logoColor=white" alt="AWS">
  <img src="https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white" alt="Azure">
  <img src="https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" alt="Google Cloud">
  <img src="https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white" alt="GitHub Actions">
</p>

---

## 🧭 What is ADI-NAN?

ADI-NAN is a Linux operating system whose **entire definition lives in a `Containerfile`** — the same syntax you already use for containers. You build it like an image, publish it to a registry, and turn that one image into whatever bootable form you need: a VM disk, a cloud AMI, or a bare-metal installer ISO.

Because it's built on **[Fedora `bootc`](https://docs.fedoraproject.org/en-US/bootc/)**, updates are **atomic** (they either fully apply or don't) and **roll back cleanly**. The base is immutable, so every machine running ADI-NAN is identical and reproducible — the dream for fleets, CI runners, and dev workstations alike.

And it ships **ready to work**: `kubectl`, `helm`, `tofu`, `ansible`, the AWS/Azure/GCP CLIs, and dozens more are already installed and wired into a cloud-aware shell.

> 💡 **In one line:** your OS is code — version-controlled, CI-built, and updated with `bootc upgrade`.

---

## 🎯 Why build an OS this way?

| Traditional distro | ADI-NAN (image-based) |
|---|---|
| Configured by hand or drifting scripts | Defined once in a `Containerfile` |
| "Works on my machine" snowflakes | Every machine is byte-identical |
| Risky in-place `dnf upgrade` | Atomic update + instant rollback |
| One install target | One image → VM, cloud, and bare metal |
| Tools installed ad-hoc later | Full DevOps toolchain baked in |

---

## 🏗️ How it works

Define the OS once, then render it into any bootable form — and machines update straight from the registry.

```mermaid
flowchart LR
    subgraph SRC["Define once — this repo"]
        CF["Containerfile"]
        PKG["packages/ tools"]
        CFG["files/ configs"]
    end

    SRC --> IMG["OCI image<br/>ghcr.io/deba310984/adi-nan"]
    IMG --> BIB["bootc-image-builder"]

    BIB --> VM["VM image · qcow2"]
    BIB --> CLOUD["Cloud image · AMI / VHD"]
    BIB --> ISO["Installer ISO"]

    VM --> RUN["Running ADI-NAN"]
    CLOUD --> RUN
    ISO --> RUN

    RUN -->|bootc upgrade| IMG
```

## 🔁 Build & update pipeline

Every push rebuilds the image in CI and publishes it; a weekly job absorbs upstream Fedora updates automatically.

```mermaid
flowchart LR
    A["git push"] --> B["GitHub Actions"]
    B --> C["buildah build"]
    C --> D["push image"]
    D --> E[("ghcr.io registry")]
    E --> F["bootc upgrade on machines"]
    F --> G["atomic reboot + rollback"]
```

---

## 📦 What's inside

| Category | Tools |
|---|---|
| 🐳 Containers | podman · buildah · skopeo · cosign |
| ☸️ Kubernetes | kubectl · helm · k9s · kustomize · stern · kubectx/kubens · argocd · flux |
| 🏗️ IaC / config | OpenTofu (`tofu`) · Ansible |
| ☁️ Cloud CLIs | AWS CLI v2 · Azure CLI · Google Cloud CLI |
| 🔐 Secrets | sops · age |
| 🛠️ Dev / CI | git · git-lfs · gh · direnv · mise · pre-baked completions |
| 🖥️ Shell / TUI | zsh + starship (kube/cloud-aware prompt) · fish · tmux · neovim · fzf · ripgrep · bat · btop · fastfetch |
| 🌐 Net / debug | dig · nmap · tcpdump · mtr · httpie · socat · jq · yq |

> The OS `ID` in `/etc/os-release` stays `fedora` on purpose so `dnf` and Fedora tooling keep working — only the display name is branded ADI-NAN.

---

## 🚀 Quickstart

You need a **Linux build host with `podman`** (Linux images can't be built on Windows directly). On Windows 11, use **WSL2**; or let GitHub Actions build it for you and only boot-test in a VM.

```bash
# 1. Build the OS image
bash scripts/build.sh                 # -> adi-nan:latest

# 2. Verify the toolchain inside it
podman run --rm -it adi-nan:latest bash -lc 'kubectl version --client; tofu version; aws --version'

# 3. Build a bootable VM disk (edit bootc-image-builder/config.toml first to add your SSH key)
sudo bash scripts/build-disk.sh qcow2 # -> output/qcow2/disk.qcow2
```

Other disk types: `ami` (AWS), `raw`, `vmdk`, `anaconda-iso` (bare-metal installer).

Once a machine is running ADI-NAN, it updates itself from the registry:

```bash
sudo bootc upgrade    # pulls the newest image, stages it; reboot to apply
```

---

## 🗂️ Repository layout

```
ADI-NAN/
├── Containerfile               ← the OS definition (start here)
├── packages/
│   ├── dnf-packages.txt         ← packages from Fedora repos
│   └── tools.sh                 ← tools not in repos, version-pinned
├── files/                       ← configs copied verbatim into the image (/)
│   └── etc/…                    ← profile.d, /etc/skel dotfiles, motd, starship
├── bootc-image-builder/
│   └── config.toml              ← users, filesystem, kernel args for disk images
├── scripts/
│   ├── build.sh                 ← build the container image
│   └── build-disk.sh            ← render a bootable disk / ISO
├── docs/banner.svg              ← README hero art
└── .github/workflows/build.yml  ← CI: build + push image to ghcr.io
```

---

## 🛠️ Customizing

- **Add/remove Fedora packages** → edit [`packages/dnf-packages.txt`](packages/dnf-packages.txt)
- **Add a tool not in Fedora** → add a block to [`packages/tools.sh`](packages/tools.sh) (pin its version)
- **Change defaults/dotfiles** → drop files under [`files/`](files/) mirroring the target path
- **Change users / disk / kernel** → edit [`bootc-image-builder/config.toml`](bootc-image-builder/config.toml)

Rebuild after any change with `bash scripts/build.sh`.

---

## 🗺️ Roadmap

- [ ] A local `k3s` / `kind` cluster that comes up on first boot
- [ ] Signed images (`cosign`) + verified `bootc` updates
- [ ] A GNOME desktop variant for engineer workstations
- [ ] A committed `mise.toml` toolset (Go, Node, Python)
- [ ] Hardening pass (SSH, firewalld defaults, auditd)

---

## 🤝 Contributing & License

Contributions are welcome — big or small. See **[CONTRIBUTING.md](CONTRIBUTING.md)** for how to build, test, and open a pull request. Every push and PR is built automatically by CI.

Released under the **[MIT License](LICENSE)** — free to use, modify, and share.

---

<p align="center">
  <sub>Built with ☕ and <a href="https://containers.github.io/bootc/">bootc</a> · Powered by <a href="https://docs.fedoraproject.org/en-US/bootc/">Fedora</a> · Inspired by <a href="https://universal-blue.org/">Universal Blue</a></sub>
</p>
