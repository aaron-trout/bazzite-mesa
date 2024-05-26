FROM fedora:40 as builder

RUN dnf install -y git mock rpm-build rpmdevtools && \
    git clone https://github.com/ublue-os/bazzite.git /src/github.com/ublue-os/bazzite
WORKDIR /src/github.com/ublue-os/bazzite/spec_files/mesa
RUN sed -i "s|Source0:        https://archive.mesa3d.org/mesa-%{ver}.tar.xz|Source0: https://gitlab.freedesktop.org/mesa/mesa/-/archive/main/mesa-main.tar.gz|g" mesa.spec
RUN sed -i "s/%autosetup -n %{name}-%{ver} -p1/%autosetup -n %{name}-main -p1/g" mesa.spec
RUN sed -i "s/bazzite.{{{ git_dir_version }}}/mesa.main/g" mesa.spec
RUN spectool --get-files --sourcedir mesa.spec && cp ./* /root/rpmbuild/SOURCES/
RUN sed -i "s/%global ver 24.1.0/%global ver $(tar -Oxf /root/rpmbuild/SOURCES/mesa-main.tar.gz mesa-main/VERSION | tr -d '\n')/g" mesa.spec

# build SRPM (Output: SRPMS/mesa-24.1.0-100.bazzite.foo.src.rpm)
RUN rpmbuild -bs mesa.spec

# build i386
RUN find /root/rpmbuild/SRPMS/ -name '*.src.rpm' | xargs -n 1 \
    mock -r fedora-40-i386 --rebuild --resultdir /root/resultdir

# build x86_64
RUN find /root/rpmbuild/SRPMS/ -name '*.src.rpm' | xargs -n 1 \
    mock -r fedora-40-x86_64 --rebuild --resultdir /root/resultdir

# RUN dnf install -y \
#     --setopt=protected_multilib=false \
#     git \
#     dnf-plugins-core \
#     rpm-build \
#     rpmdevtools \
#     glibc-devel.i686 \
#     libstdc++-devel.i686 \
#     lm_sensors-devel.i686 \
#     llvm-devel.i686 \
#     clang-devel.i686 \
#     @development-tools

# RUN git clone https://github.com/ublue-os/bazzite.git /src/github.com/ublue-os/bazzite
# # RUN git clone https://gitlab.freedesktop.org/mesa/mesa.git /root/rpmbuild/SOURCES/mesa
# # RUN tar -cvJf /root/rpmbuild/SOURCES/mesa.tar.xz --exclude='.git' /root/rpmbuild/SOURCES/mesa
# WORKDIR /src/github.com/ublue-os/bazzite/spec_files/mesa
# RUN sed -i "s|Source0:        https://archive.mesa3d.org/mesa-%{ver}.tar.xz|Source0: https://gitlab.freedesktop.org/mesa/mesa/-/archive/main/mesa-main.tar.gz|g" mesa.spec
# RUN sed -i "s/%autosetup -n %{name}-%{ver} -p1/%autosetup -n %{name}-main -p1/g" mesa.spec
# RUN sed -i "s/bazzite.{{{ git_dir_version }}}/mesa.main/g" mesa.spec
# RUN spectool --get-files --sourcedir mesa.spec

# RUN sed -i "s/%global ver 24.1.0/%global ver $(tar -Oxf /root/rpmbuild/SOURCES/mesa-main.tar.gz mesa-main/VERSION | tr -d '\n')/g" mesa.spec
# RUN dnf builddep mesa.spec -y
# RUN cp ./* /root/rpmbuild/SOURCES/
# RUN rpmbuild -bb --target=i386-linux mesa.spec
# RUN rpmbuild -bb --target=x86_64-linux mesa.spec


FROM ghcr.io/ublue-os/bazzite-gnome
COPY --from=builder /root/rpmbuild/RPMS /tmp/RPMS
RUN rpm-ostree override remove mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld && \
    find /tmp/RPMS -name '*.rpm' | xargs rpm-ostree override replace && \
    ostree container commit && \
    rm -rf /tmp/RPMS
