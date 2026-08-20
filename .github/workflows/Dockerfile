FROM brix-ci-base:latest

# === FHS setup ===
# /bin is already a symlink from the pack (-S /bin=bin)
RUN mkdir -p /usr && \
    ln -sf /lib /usr/lib && \
    ln -sf /lib /lib64 && \
    ln -sf /bin /usr/bin && \
    ln -sf /sbin /usr/sbin

# 1. groupadd --gid 0 root
# 2. useradd --uid 0 --gid root --shell /bin/sh --home-dir / --system root
RUN groupadd --gid 0 root && \
    useradd --uid 0 --gid root --shell /bin/sh --home-dir / --system root

RUN for f in /gnu/store/*profile/etc/*; do cp -rLf "$f" /etc/; done

# 4. groupadd --system guixbuild
# 5. for i in $(seq -w 1 10); do useradd ... guixbuilder$i; done
RUN groupadd --system guixbuild && \
    for i in $(seq -w 1 10); do \
        useradd -g guixbuild -G guixbuild -d /var/empty \
            -s "$(command -v nologin)" \
            -c "Guix build user $i" --system guixbuilder$i; \
    done

# 6. export HOME=/
ENV HOME=/

# 8. guix archive --authorize < /share/guix/ci.guix.gnu.org.pub
# 9. guix archive --authorize < /share/guix/bordeaux.guix.gnu.org.pub
RUN guix archive --authorize < /share/guix/ci.guix.gnu.org.pub && \
    guix archive --authorize < /share/guix/bordeaux.guix.gnu.org.pub

# Authorize nonguix channel
RUN wget -q https://substitutes.nonguix.org/signing-key.pub -O /tmp/nonguix.pub && \
    guix archive --authorize < /tmp/nonguix.pub

# === FHS: ld.so.conf and cache (requires glibc-for-fhs in pack) ===
RUN echo "/lib" > /etc/ld.so.conf && \
    echo "/lib/nss" >> /etc/ld.so.conf && \
    /sbin/ldconfig -X

# === Optional: cc symlink (matches Brix setup-fhs) ===
RUN PROFILE=$(echo /gnu/store/*-profile) && \
    if [ -f "$PROFILE/bin/gcc" ]; then ln -sf "$PROFILE/bin/gcc" /bin/cc; fi

# FHS PATH
ENV PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH

CMD ["/bin/sh"]
