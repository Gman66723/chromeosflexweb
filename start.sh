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
#!/bin/bash

# ... (keep your download/unzip logic the same) ...

# 3. Start noVNC
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

# 4. Start QEMU with compatible settings
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
