#!/bin/sh
# Guix wrapper: starts guix-daemon on first invocation if not already running.
# Place this in PATH before the real guix binary (e.g. /usr/local/bin/guix).

GUIX_DAEMON_SOCKET="${GUIX_DAEMON_SOCKET:-/var/guix/daemon-socket/socket}"

if [ ! -S "$GUIX_DAEMON_SOCKET" ]; then
    env LANG=C.UTF-8 guix-daemon \
        --build-users-group=guixbuild \
        >/tmp/guix-daemon.log 2>&1 &
    sleep 2
fi

# Strip /usr/local/bin so `guix` resolves to the real binary
PATH="/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin"
export PATH

exec guix "$@"
