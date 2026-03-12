#!/bin/bash

# 1. Download the latest ChromeOS Flex image if not present
if [ ! -f "chromeos.bin" ]; then
    echo "Downloading ChromeOS Flex..."
    curl -L "https://dl.google.com/chromeos-flex/images/latest.bin.zip" -o flex.zip
    unzip flex.zip
    mv *.bin chromeos.bin
    rm flex.zip
    
    # 2. Create a persistent disk (ChromeOS needs space to install)
    qemu-img create -f qcow2 internal_storage.qcow2 32G
fi

# 3. Start noVNC in the background
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

# 4. Start QEMU
# Note: ChromeOS Flex requires UEFI (OVMF) to boot correctly
qemu-system-x86_64 \
    -m 4G \
    -smp 4 \
    -cpu host \
    -enable-kvm \
    -device virtio-vga-gl -display vnc=:0 \
    -bios /usr/share/ovmf/OVMF.fd \
    -drive file=chromeos.bin,format=raw,if=virtio \
    -drive file=internal_storage.qcow2,format=qcow2,if=virtio \
    -device virtio-mouse-pci -device virtio-keyboard-pci \
    -net nic,model=virtio -net user
