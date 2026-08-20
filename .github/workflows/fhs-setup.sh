#!/bin/bash
set -e

SYSTEM="/run/current-system"
PROFILE="$SYSTEM/profile"

# ---------------------------------------------------------------------------
echo "Profile: $PROFILE"
# ---------------------------------------------------------------------------

source "$SYSTEM/etc/profile"

# ===========================================================================
# ROOT PHASE: FHS emulation
# ===========================================================================

echo "Starting FHS setup..."

# # --- FHS directory mappings ---

# echo "Creating FHS directory mappings..."

# mkdir -p /usr

# ln -s "$PROFILE/lib"       /lib
# ln -s "$PROFILE/sbin"      /sbin
# ln -s "$PROFILE/include"   /usr/include
# ln -s "$PROFILE/libexec"   /usr/libexec
# ln -s "$PROFILE/share"     /usr/share


# # --- FHS compatibility symlinks ---

# echo "Creating FHS symlinks..."

# ln -s /lib  /usr/lib
# ln -s /lib  /lib64
# ln -s /bin  /usr/bin
# ln -s /sbin /usr/sbin

# --- Populate /bin ---

echo "Populating /bin..."

for src in "$PROFILE/bin"/*; do
    # [ -e "$src" ] || continue
    name=$(basename "$src")
    # Skip 'sh': the base image provides its own /bin/sh.
    # [ "$name" = "sh" ] && continue
    symlink="/bin/$name"
    [ -e "$symlink" ] || ln -s "$src" "$symlink"
done


# --- Populate /etc ---
# Backfill missing files that activate-etc failed to create.
# Needed for /etc/profile to source /etc/profile.d/*.sh.

echo "Populating /etc..."

for src in "$PROFILE/etc"/*; do
    # [ -e "$src" ] || continue
    name=$(basename "$src")
    symlink="/etc/$name"
    [ -e "$symlink" ] || ln -s "$src" "$symlink"
done


# --- Dynamic linker cache ---
# See explanation outside this script.

echo "Writing /etc/ld.so.conf..."

printf '/lib\n/lib/nss\n' > /etc/ld.so.conf

echo "Running ldconfig..."
echo "Running ldconfig from $(readlink -f /sbin/ldconfig)..."

/sbin/ldconfig -X


# --- /bin/cc ---

echo "Setting up /bin/cc..."

if [ -e "$PROFILE/bin/gcc" ] && [ ! -e /bin/cc ]; then
    echo "/bin/cc -> $PROFILE/bin/gcc"
    
    ln -s "$PROFILE/bin/gcc" /bin/cc
fi

echo "FHS setup complete."
