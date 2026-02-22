#!/bin/bash
# NSBoot VirtualBox Test Environment Setup Script
# Sets up a VirtualBox VM for diskless PXE boot testing with NSBoot
#
# Requirements:
#   - VirtualBox installed on host machine
#   - NSBoot server running on 172.16.0.2 (Host-Only network)
#   - Built iPXE ROM: src/ipxe/rom/intel--virtio-net--pcnet32.isarom

set -e

VBOX_NAME="${1:-NSBoot-TestClient}"
VBOX_RAM="${2:-2048}"
VBOX_HOSTONLY_NET="vboxnet0"
NSBOOT_SERVER_IP="172.16.0.2"
IPXE_ROM_PATH="$(dirname "$0")/../../src/ipxe/rom/intel--virtio-net--pcnet32.isarom"

echo "=== NSBoot VirtualBox Test Environment Setup ==="
echo "VM Name: $VBOX_NAME"
echo "RAM: ${VBOX_RAM}MB"
echo "Network: $VBOX_HOSTONLY_NET ($NSBOOT_SERVER_IP/24)"
echo ""

# Resolve absolute path to ROM
IPXE_ROM_ABS="$(realpath "$IPXE_ROM_PATH" 2>/dev/null || echo "$IPXE_ROM_PATH")"

# Step 1: Configure iPXE ROM globally in VirtualBox
echo "[1/5] Installing iPXE ROM for VirtualBox..."
if [ ! -f "$IPXE_ROM_ABS" ]; then
    echo "ERROR: iPXE ROM not found at: $IPXE_ROM_ABS"
    echo "Build it first:"
    echo "  cd src/ipxe/src"
    echo "  make CONFIG=vbox EXTRA_CFLAGS=\"-Wno-error\" bin/intel--virtio-net--pcnet32.isarom"
    exit 1
fi

ROM_SIZE=$(wc -c < "$IPXE_ROM_ABS")
if [ "$ROM_SIZE" -gt 57344 ]; then
    echo "WARNING: ROM size ${ROM_SIZE} bytes exceeds VirtualBox limit of 57344 bytes!"
    echo "VirtualBox may refuse to load this ROM."
fi

VBoxManage setextradata global \
    "VBoxInternal/Devices/pcbios/0/Config/LanBootRom" \
    "$IPXE_ROM_ABS"
echo "    ROM installed: $IPXE_ROM_ABS (${ROM_SIZE} bytes)"

# Step 2: Create Host-Only network if needed
echo "[2/5] Setting up Host-Only network ($VBOX_HOSTONLY_NET)..."
if ! VBoxManage list hostonlyifs | grep -q "$VBOX_HOSTONLY_NET"; then
    VBoxManage hostonlyif create
    echo "    Created new host-only interface"
fi
VBoxManage hostonlyif ipconfig "$VBOX_HOSTONLY_NET" \
    --ip "$NSBOOT_SERVER_IP" --netmask "255.255.255.0"
echo "    Configured: $NSBOOT_SERVER_IP/24"

# Disable VirtualBox built-in DHCP on this interface (NSBoot handles DHCP)
VBoxManage dhcpserver remove --ifname "$VBOX_HOSTONLY_NET" 2>/dev/null || true
echo "    Disabled VirtualBox DHCP (NSBoot provides DHCP)"

# Step 3: Create VM
echo "[3/5] Creating VM: $VBOX_NAME..."
if VBoxManage showvminfo "$VBOX_NAME" >/dev/null 2>&1; then
    echo "    VM '$VBOX_NAME' already exists, skipping creation"
else
    VBoxManage createvm --name "$VBOX_NAME" --ostype "Windows10_64" --register
    echo "    VM created"
fi

# Step 4: Configure VM
echo "[4/5] Configuring VM settings..."
VBoxManage modifyvm "$VBOX_NAME" \
    --memory "$VBOX_RAM" \
    --cpus 2 \
    --boot1 net \
    --boot2 none \
    --boot3 none \
    --boot4 none \
    --nic1 hostonly \
    --hostonlyadapter1 "$VBOX_HOSTONLY_NET" \
    --nictype1 "Am79C973" \
    --audio none \
    --usb off

# Enable PCNet ISA ROM (needed for iPXE PXE boot)
VBoxManage setextradata "$VBOX_NAME" \
    "VBoxInternal/Devices/pcnet/0/LUN#0/Config/BootPrio" "1"

echo "    RAM: ${VBOX_RAM}MB, CPU: 2, NIC: PCnet-FAST III (Am79C973)"
echo "    Boot order: Network first (diskless)"

# Step 5: Get VM MAC address for DHCP registration
VM_MAC=$(VBoxManage showvminfo "$VBOX_NAME" --machinereadable | \
    grep "macaddress1" | cut -d= -f2 | tr -d '"' | \
    sed 's/../&:/g;s/:$//')
echo "[5/5] VM MAC address: $VM_MAC"
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Add this VM to NSBoot DHCP config with MAC: $VM_MAC"
echo "   Edit /etc/dhcp/dhcpd.conf or use NSBoot web interface at http://${NSBOOT_SERVER_IP}:8888"
echo ""
echo "2. Create a disk image for this VM:"
echo "   qemu-img create -f qcow2 /srv/images/boot/${VBOX_NAME}.qcow2 20G"
echo ""
echo "3. Register VM in NSBoot web interface:"
echo "   - Name: $VBOX_NAME"
echo "   - MAC: $VM_MAC"
echo "   - IP: 172.16.0.10 (or next available)"
echo "   - Image: ${VBOX_NAME}.qcow2"
echo ""
echo "4. Start VM:"
echo "   VBoxManage startvm \"$VBOX_NAME\""
echo ""
echo "VirtualBox VM '$VBOX_NAME' is ready for NSBoot PXE testing!"
