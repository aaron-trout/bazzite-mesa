FROM ghcr.io/ublue-os/bazzite-gnome
RUN find /root/rpmbuild/RPMS -name '*.rpm' | xargs rpm-ostree override replace && \
    ostree container commit
