docker run -it --privileged \
    --device /dev/kvm \
    -p 6080:6080 \
    -v $(pwd):/chromeos \
    chromeos-flex-web
