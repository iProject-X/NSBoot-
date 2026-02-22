#!/bin/bash
# Build iPXE ROM for VirtualBox
# Output: src/ipxe/rom/intel--virtio-net--pcnet32.isarom (must be <= 56KB)
#
# Requirements: build-essential, liblzma-dev, perl, mtools (optional)
#   apt install -y build-essential liblzma-dev perl

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
ROM_OUT="$SCRIPT_DIR/rom/intel--virtio-net--pcnet32.isarom"
MAX_SIZE=57344  # 56 KB VirtualBox ROM limit

echo "=== Building iPXE ROM for VirtualBox ==="
echo "Source: $SRC_DIR"
echo "Output: $ROM_OUT"
echo "Max size: $MAX_SIZE bytes (56 KB)"
echo ""

# Create local config stubs (required by iPXE build system)
mkdir -p "$SRC_DIR/config/local"
for h in ioapi.h time.h reboot.h usb.h timer.h fdt.h crypto.h branding.h \
          entropy.h umalloc.h fault.h colour.h console.h general.h settings.h \
          serial.h sideband.h named.h nap.h sanboot.h dhcp.h isa.h; do
    touch "$SRC_DIR/config/local/$h"
done

# Build ROM
cd "$SRC_DIR"
make CONFIG=vbox \
     EXTRA_CFLAGS="-Os -Wno-error=array-bounds -Wno-error=maybe-uninitialized -Wno-error" \
     bin/intel--virtio-net--pcnet32.isarom

# Check output size
BUILT="$SRC_DIR/bin/intel--virtio-net--pcnet32.isarom"
SIZE=$(wc -c < "$BUILT")

echo ""
echo "Built ROM size: $SIZE bytes"

if [ "$SIZE" -gt "$MAX_SIZE" ]; then
    echo "ERROR: ROM is ${SIZE} bytes, exceeds VirtualBox limit of ${MAX_SIZE} bytes!"
    echo "Disable more features in src/ipxe/src/config/vbox/general.h"
    exit 1
fi

# Copy to output directory
mkdir -p "$(dirname "$ROM_OUT")"
cp "$BUILT" "$ROM_OUT"

echo "ROM saved to: $ROM_OUT"
echo ""
echo "Install in VirtualBox:"
echo "  VBoxManage setextradata global \\"
echo "      VBoxInternal/Devices/pcbios/0/Config/LanBootRom \\"
echo "      $(realpath "$ROM_OUT")"
