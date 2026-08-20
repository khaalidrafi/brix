#!/bin/sh
# Start Guix build daemon in background
env LANG=C.UTF-8 guix-daemon --build-users-group=guixbuild &

# Wait for daemon socket to be ready
sleep 1

# Execute the command passed to container
exec "$@"
