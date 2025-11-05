qemu-system-x86_64 \
-enable-kvm \
-M q35 \
-m 4G \
-smp 2 \
-cpu host \
\
-drive if=pflash,format=raw,readonly=on,file=/nix/store/4chhzhd2hids7dh0yrilnh1788v8bcz8-qemu-host-cpu-only-10.1.2/share/qemu/edk2-x86_64-code.fd \
-drive if=pflash,format=raw,file=$(pwd)/ws-rafael-vm_VARS.fd \
-drive file=$(pwd)/ws-rafael-vm.qcow2,if=virtio,format=qcow2 \
-cdrom $(pwd)/nixos-minimal-25.11-x86_64-linux.iso \
\
-usb \
-netdev user,id=net0,hostfwd=tcp::2222-:22 \
-device virtio-net-pci,netdev=net0,addr=0x05 \
\
-device virtio-vga-gl,addr=0x06 \
-display sdl,gl=on \
-boot order=dc
