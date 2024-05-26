FROM ghcr.io/ublue-os/bazzite-gnome:40
ADD RPMS /tmp/RPMS
RUN rpm-ostree override remove mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld && \
    find /tmp/RPMS -type f -name '*.rpm' | \
      egrep -v '(debuginfo|devel|src)' | \
      xargs rpm-ostree override replace && \
    rm -rf /tmp/RPMS && \
    ostree container commit
