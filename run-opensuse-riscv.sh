#!/usr/bin/env bash

set -euo pipefail
#-------------------------------------------
# Run openSUSE Tumbleweed RISC-V EFI image in QEMU
#-------------------------------------------

# === Configuration ===
IMG_URL="https://download.opensuse.org/ports/riscv/tumbleweed/images/openSUSE-Tumbleweed-RISC-V-E20-efi.riscv64.raw.xz"
IMG_XZ=$(basename "$IMG_URL")
IMG_RAW="${IMG_XZ%.xz}"
PFLASH0="./firmware/RISCV_VIRT_CODE.fd"
PFLASH1="./flash/RISCV_VIRT_VARS.fd"

# === Helper functions ===
info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERR ]\033[0m $*" >&2; exit 1; }

# === Download image ===
if [[ ! -f "$IMG_XZ" && ! -f "$IMG_RAW" ]]; then
    info "Downloading openSUSE RISC-V EFI image..."
    wget -c "$IMG_URL"
else
    info "Image already exists, skipping download."
fi

# === Decompress image if needed ===
if [[ ! -f "$IMG_RAW" ]]; then
    info "Decompressing image..."
    xz -dk "$IMG_XZ"
else
    info "Raw image already decompressed."
fi

# === Run QEMU ===
info "Starting QEMU (RISC-V 64, EFI mode)..."

warn "Qemu's graphical output may be slow. Please be patient."

qemu-system-riscv64 \
    -M virt,pflash0=pflash0,pflash1=pflash1,acpi=off \
    -m 4G -smp 4 \
    -device virtio-gpu-pci \
    -device qemu-xhci \
    -device usb-kbd \
    -device virtio-rng-pci \
    -blockdev node-name=pflash0,driver=file,read-only=on,filename=${PFLASH0} \
    -blockdev node-name=pflash1,driver=file,filename=${PFLASH1} \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    -device virtio-blk-device,drive=hd0 \
    -drive if=none,file=${IMG_RAW},format=raw,id=hd0