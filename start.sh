#!/bin/bash

# 1. Check if we already have the bin or the zip
if [ -f "chromeos.bin" ]; then
    echo "✅ Found chromeos.bin, skipping download."
elif [ -f "flex.zip" ]; then
    echo "📦 Found flex.zip, extracting..."
    unzip flex.zip
    mv *.bin chromeos.bin
else
    echo "🌐 No files found. Downloading ChromeOS Flex..."
    curl -L "https://dl.google.com/chromeos-flex/images/latest.bin.zip" -o flex.zip
    unzip flex.zip
    mv *.bin chromeos.bin
    # Optional: Zip it back if you want to keep a compressed backup
    # zip flex_backup.zip chromeos.bin 
fi

# 2. Ensure internal storage exists
if [ ! -f "internal_storage.qcow2" ]; then
    echo "💾 Creating virtual hard drive..."
    qemu-img create -f qcow2 internal_storage.qcow2 32G
fi

# 3. Start noVNC
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

# 4. Start QEMU with the 'q35' and 'cpu max' fixes
echo "🚀 Launching ChromeOS Flex..."
qemu-system-x86_64 \
    -m 4G \
    -smp 2 \
    -cpu max \
    -enable-kvm \
    -machine q35 \
    -vga std \
    -display vnc=:0 \
    -device virtio-tablet-pci \
    -bios /usr/share/ovmf/OVMF.fd \
    -device usb-ehci,id=usb \
    -device usb-storage,bus=usb.0,drive=chromeos_bin \
    -drive file=chromeos.bin,format=raw,if=none,id=chromeos_bin \
    -drive file=internal_storage.qcow2,format=qcow2,if=virtio \
    -net nic,model=virtio -net user
