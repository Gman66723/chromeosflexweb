FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install QEMU, KVM, noVNC, and dependencies
RUN apt-get update && apt-get install -y \
    qemu-system-x86 qemu-utils curl unzip \
    novnc websockify python3 \
    ovmf mesa-utils libgl1-mesa-dri \
    && apt-get clean

# Set up work directory
WORKDIR /chromeos

# Copy the startup script (we will create this next)
COPY start.sh /chromeos/start.sh
RUN chmod +x /chromeos/start.sh

# Expose noVNC port
EXPOSE 6080

CMD ["/chromeos/start.sh"]
