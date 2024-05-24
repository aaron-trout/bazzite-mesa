FROM fedora:40 as builder

RUN dnf install -y git \
    dnf-plugins-core \
    rpm-build \
    rpmdevtools \
    @development-tools

RUN git clone https://github.com/ublue-os/bazzite.git /src/github.com/ublue-os/bazzite
# RUN git clone https://gitlab.freedesktop.org/mesa/mesa.git /root/rpmbuild/SOURCES/mesa
# RUN tar -cvJf /root/rpmbuild/SOURCES/mesa.tar.xz --exclude='.git' /root/rpmbuild/SOURCES/mesa
WORKDIR /src/github.com/ublue-os/bazzite/spec_files/mesa
RUN sed -i "s|Source0:        https://archive.mesa3d.org/mesa-%{ver}.tar.xz|Source0: https://gitlab.freedesktop.org/mesa/mesa/-/archive/main/mesa-main.tar.gz|g" mesa.spec
RUN sed -i "s/%autosetup -n %{name}-%{ver} -p1/%autosetup -n %{name} -p1/g" mesa.spec
RUN spectool --get-files --sourcedir mesa.spec

RUN sed -i "s/%global ver 24.1.0/%global ver $(tar -Oxf /root/rpmbuild/SOURCES/mesa-main.tar.gz mesa-main/VERSION | tr -d '\n')/g" mesa.spec
RUN sed -i "s/bazzite.{{{ git_dir_version }}}/mesa.main/g" mesa.spec
RUN dnf builddep mesa.spec -y
RUN cp ./* /root/rpmbuild/SOURCES/
RUN rpmbuild -ba mesa.spec

FROM ghcr.io/ublue-os/bazzite-gnome
COPY --from=builder /root/rpmbuild/RPMS /tmp/RPMS
RUN find /tmp/RPMS -name '*.rpm' | xargs rpm-ostree override replace && \
    ostree container commit && \
    rm -rf /tmp/RPMS
