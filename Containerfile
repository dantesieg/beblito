## 1. BUILD ARGS
# These allow changing the produced image by passing different build args to adjust
# the source from which your image is built.
# Build args can be provided on the commandline when building locally with:
#   podman build -f Containerfile --build-arg FEDORA_VERSION=40 -t local-image

# SOURCE_IMAGE arg can be anything from ublue upstream which matches your desired version:
# See list here: https://github.com/orgs/ublue-os/packages?repo_name=main
# - "silverblue"
# - "kinoite"
# - "sericea"
# - "onyx"
# - "lazurite"
# - "vauxite"
# - "base"
#
#  "aurora", "bazzite", "bluefin" or "ucore" may also be used but have different suffixes.
ARG SOURCE_IMAGE="kinoite"

## SOURCE_SUFFIX arg should include a hyphen and the appropriate suffix name
# These examples all work for silverblue/kinoite/sericea/onyx/lazurite/vauxite/base
# - "-main"
# - "-nvidia"
# - "-asus"
# - "-asus-nvidia"
# - "-surface"
# - "-surface-nvidia"
#
# aurora, bazzite and bluefin each have unique suffixes. Please check the specific image.
# ucore has the following possible suffixes
# - stable
# - stable-nvidia
# - stable-zfs
# - stable-nvidia-zfs
# - (and the above with testing rather than stable)
ARG SOURCE_SUFFIX="-main"

## SOURCE_TAG arg must be a version built for the specific image: eg, 39, 40, gts, latest
ARG SOURCE_TAG="latest"

ARG IMAGE_NAME="${IMAGE_NAME:-beblito}"
ARG KMOD_SRC="${KMOD_SRC:-ghcr.io/ublue-os/ucore-kmods:40}"

### 2. SOURCE IMAGE
## this is a standard Containerfile FROM using the build ARGs above to select the right upstream image
FROM quay.io/fedora-ostree-desktops/kinoite:40


### 3. MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

COPY --from=ghcr.io/ublue-os/ucore-kmods:stable /rpms/kmods/nvidia/*.rpm /tmp/rpms/nvidia/
COPY *.sh /tmp/

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit

RUN curl -Lo /usr/bin/copr https://raw.githubusercontent.com/ublue-os/COPR-command/main/copr && \
    chmod +x /usr/bin/copr && \
    curl -Lo /etc/yum.repos.d/whitehara-kernel-tkg-fedora-40.repo https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/repo/fedora-40/whitehara-kernel-tkg-fedora-40.repo && \
    curl -Lo /etc/yum.repos.d/fedora-nvidia.repo https://negativo17.org/repos/fedora-nvidia.repo && \
    ostree container commit

# RUN rm -rf /etc/yum.repos.d/rpmfusion-nonfree-nvidia-driver.repo && /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo && /etc/yum.repos.d/_copr_ublue-os-akmods.repo && ostree container commit

RUN rpm-ostree cliwrap install-to-root /

# RUN rpm-ostree override replace --experimental --from repo='copr:copr.fedorainfracloud.org:whitehara:kernel-tkg' kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra && ostree container commit

# RUN rpm-ostree install libglvnd-gles && ostree container commit

# RUN rpm-ostree install nvidia-driver nvidia-driver-libs.i686 && ostree container commit

RUN rpm-ostree override remove firefox firefox-langpacks && ostree container commit

# RUN rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1 && ostree container commit

# RUN rpm-ostree override remove steam lutris winetricks protontricks && ostree container commit
# RUN rpm-ostree override remove gamescope gamescope-shaders && ostree container commit

## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
