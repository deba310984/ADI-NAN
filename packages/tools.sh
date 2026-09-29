#!/usr/bin/env bash
# ADI-NAN — install DevOps/cloud tools that are NOT in the Fedora repos.
# Runs during the image build (dnf + network available). Pin versions below
# and bump them over time; CI rebuilds pick up the new pins.
set -euo pipefail

# --- pinned versions (bump these periodically) ---------------------------
HELM_VERSION="v3.16.1"
K9S_VERSION="v0.32.7"
KUSTOMIZE_VERSION="v5.4.3"
STERN_VERSION="1.30.0"
KUBECTX_VERSION="v0.9.5"
OPENTOFU_VERSION="1.8.2"
YQ_VERSION="v4.44.3"
ARGOCD_VERSION="v2.12.3"
SOPS_VERSION="v3.9.1"
AGE_VERSION="v1.2.0"
COSIGN_VERSION="v2.4.0"
GH_VERSION="2.57.0"

# --- arch detection -------------------------------------------------------
case "$(uname -m)" in
  x86_64)  ARCH=amd64; ARCH_ALT=x86_64  ;;
  aarch64) ARCH=arm64; ARCH_ALT=aarch64 ;;
  *) echo "Unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

BIN=/usr/local/bin
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

dl()          { curl -fsSL "$1" -o "$2"; }
install_bin() { install -m 0755 "$1" "$BIN/$2"; }

echo "==> kubectl"
KVER="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
dl "https://dl.k8s.io/release/${KVER}/bin/linux/${ARCH}/kubectl" kubectl
install_bin kubectl kubectl

echo "==> helm"
dl "https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz" helm.tgz
tar -xzf helm.tgz "linux-${ARCH}/helm" && install_bin "linux-${ARCH}/helm" helm

echo "==> k9s"
dl "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz" k9s.tgz
tar -xzf k9s.tgz k9s && install_bin k9s k9s

echo "==> kustomize"
dl "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz" kustomize.tgz
tar -xzf kustomize.tgz kustomize && install_bin kustomize kustomize

echo "==> stern"
dl "https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_${ARCH}.tar.gz" stern.tgz
mkdir -p stern-x && tar -xzf stern.tgz -C stern-x
install_bin "$(find stern-x -type f -name stern | head -1)" stern

echo "==> kubectx / kubens"
dl "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_${ARCH_ALT}.tar.gz" kubectx.tgz
dl "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens_${KUBECTX_VERSION}_linux_${ARCH_ALT}.tar.gz"  kubens.tgz
tar -xzf kubectx.tgz kubectx && install_bin kubectx kubectx
tar -xzf kubens.tgz  kubens  && install_bin kubens  kubens

echo "==> OpenTofu (tofu)"
dl "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_${ARCH}.tar.gz" tofu.tgz
tar -xzf tofu.tgz tofu && install_bin tofu tofu

echo "==> yq"
dl "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}" yq
install_bin yq yq

echo "==> argocd"
dl "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${ARCH}" argocd
install_bin argocd argocd

echo "==> sops"
dl "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${ARCH}" sops
install_bin sops sops

echo "==> age"
dl "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-${ARCH}.tar.gz" age.tgz
tar -xzf age.tgz age/age age/age-keygen
install_bin age/age age && install_bin age/age-keygen age-keygen

echo "==> cosign"
dl "https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-${ARCH}" cosign
install_bin cosign cosign

echo "==> flux CLI"
curl -fsSL https://fluxcd.io/install.sh | bash

echo "==> GitHub CLI (gh)"
dl "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${ARCH}.tar.gz" gh.tgz
tar -xzf gh.tgz "gh_${GH_VERSION}_linux_${ARCH}/bin/gh"
install_bin "gh_${GH_VERSION}_linux_${ARCH}/bin/gh" gh

echo "==> mise (polyglot runtime/version manager)"
curl -fsSL https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh

echo "==> starship prompt"
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir /usr/local/bin

# --- Cloud provider CLIs via vendor repos --------------------------------
# NOTE: these vendor endpoints are the most likely to drift/break over time.
echo "==> AWS CLI v2"
dl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH_ALT}.zip" awscliv2.zip
unzip -q awscliv2.zip
./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli

echo "==> Azure CLI"
rpm --import https://packages.microsoft.com/keys/microsoft.asc
dnf -y install https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
dnf -y install azure-cli
dnf clean all

echo "==> Google Cloud CLI"
tee /etc/yum.repos.d/google-cloud-sdk.repo >/dev/null <<EOF
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-${ARCH_ALT}
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
dnf -y install google-cloud-cli
dnf clean all

echo "==> ADI-NAN tool install complete."
