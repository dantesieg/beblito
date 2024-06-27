#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"
KERNEL="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# rpm-ostree install screen

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File

# always disable cisco-open264 repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

#### INSTALL
# inspect to see what RPMS we copied in
find /tmp/rpms/

rpm-ostree install /tmp/rpms/ublue-os-ucore-addons-*.rpm

    curl -L https://negativo17.org/repos/fedora-nvidia.repo -o /etc/yum.repos.d/fedora-nvidia.repo

    rpm-ostree install /tmp/rpms/nvidia/ublue-os-ucore-nvidia-*.rpm
    sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/nvidia-container-toolkit.repo

    rpm-ostree install \
        /tmp/rpms/nvidia/kmod-nvidia-*.rpm \
        nvidia-driver \
        nvidia-driver-libs.i686 \
        nvidia-settings

systemctl enable podman.socket
