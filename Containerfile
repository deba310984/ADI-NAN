# ADI-NAN — a Fedora bootc based OS for DevOps & Cloud engineers
#
#   Build:   podman build -t adi-nan .        (or: bash scripts/build.sh)
#   Disk:    sudo bash scripts/build-disk.sh qcow2
#   Docs:    see README.md
#
FROM quay.io/fedora/fedora-bootc:41

# --- Metadata -------------------------------------------------------------
LABEL org.opencontainers.image.title="ADI-NAN" \
      org.opencontainers.image.description="A Fedora bootc OS tailored for DevOps and cloud engineers" \
      org.opencontainers.image.vendor="ADI-NAN" \
      containers.bootc="1"

# --- Base packages from Fedora repos -------------------------------------
COPY packages/dnf-packages.txt /tmp/dnf-packages.txt
RUN grep -vE '^[[:space:]]*(#|$)' /tmp/dnf-packages.txt | xargs dnf -y install && \
    dnf clean all && \
    rm -f /tmp/dnf-packages.txt

# --- DevOps / cloud tooling not in Fedora repos --------------------------
COPY packages/tools.sh /tmp/tools.sh
RUN bash /tmp/tools.sh && rm -f /tmp/tools.sh

# --- Baked-in configuration & branding -----------------------------------
COPY files/ /

# Default new accounts to zsh and brand the OS name.
# NOTE: os-release ID stays "fedora" on purpose so dnf/tooling keep working.
RUN sed -i 's#^SHELL=.*#SHELL=/usr/bin/zsh#' /etc/default/useradd && \
    sed -i \
      -e 's/^NAME=.*/NAME="ADI-NAN"/' \
      -e 's/^PRETTY_NAME=.*/PRETTY_NAME="ADI-NAN (Fedora bootc)"/' \
      /etc/os-release

# --- Services -------------------------------------------------------------
RUN systemctl enable podman.socket

# Validate the image is a well-formed bootc container at build time.
RUN bootc container lint
