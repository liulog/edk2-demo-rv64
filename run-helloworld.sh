#!/bin/bash

set -euo pipefail

PFLASH0="./firmware/RISCV_VIRT_CODE.fd"
PFLASH1="./flash/RISCV_VIRT_VARS.fd"

qemu-system-riscv64 \
    -M virt,pflash0=pflash0,pflash1=pflash1,acpi=off \
    -m 2048 -smp 2 -nographic \
    -blockdev node-name=pflash0,driver=file,read-only=on,filename=${PFLASH0} \
    -blockdev node-name=pflash1,driver=file,filename=${PFLASH1} \
    -hda fat:rw:hda-contents