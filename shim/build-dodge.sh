#!/bin/bash
# Build the dodge shim (OnePlus 13) with clang/LLVM and wrap it as a boot image.
# Same shim as dipa's build.sh, but using the LLVM toolchain (no
# aarch64-linux-gnu-gcc needed) and the OP13 dtb + framebuffer.
#
# Usage: build-dodge.sh PAYLOAD DTB [OUTDIR]
#   PAYLOAD  a DODGEXNU payload from tools/mkpayload.py (kernel + ADT + boot-args)
#   DTB      the OnePlus 13 device tree blob (e.g. sm8750.dtb) for mkbootimg
# RAM-boot the result with:  fastboot boot OUTDIR/dodge-boot.img   (writes nothing)
set -euo pipefail
cd "$(dirname "$0")"

PAYLOAD="${1:?need a DODGEXNU payload (tools/mkpayload.py)}"
DTB="${2:?need the OnePlus 13 dtb}"
OUT="${3:-out-dodge}"
mkdir -p "$OUT"

TARGET=aarch64-linux-gnu
CFLAGS="-O2 -ffreestanding -nostdlib -fno-pic -mgeneral-regs-only -mstrict-align -fno-stack-protector -Wall -Wextra"
for f in start.S shim.c console.c mmu.c fdt.c loader.c ufs.c; do
	clang --target=$TARGET $CFLAGS -c "$f" -o "$OUT/${f%.*}.o"
done
# No absolute relocations in the C objects: the image runs wherever ABL loads it.
abs=$(llvm-readelf -r "$OUT"/shim.o "$OUT"/console.o "$OUT"/mmu.o "$OUT"/fdt.o "$OUT"/loader.o "$OUT"/ufs.o 2>/dev/null | grep -c ABS64 || true)
[ "$abs" = 0 ] || { echo "error: $abs absolute relocations in C objects" >&2; exit 1; }
clang --target=$TARGET $CFLAGS -static -fuse-ld=lld -T shim.ld \
	-Wl,--build-id=none -Wl,-N \
	"$OUT"/start.o "$OUT"/shim.o "$OUT"/console.o "$OUT"/mmu.o "$OUT"/fdt.o "$OUT"/loader.o "$OUT"/ufs.o \
	-o "$OUT/shim.elf"
llvm-objcopy -O binary "$OUT/shim.elf" "$OUT/Image"
# Pad to _end so .bss/stacks exist as zeroed bytes (ABL just copies the file).
size=$(llvm-nm "$OUT/shim.elf" | awk '$3=="_end"{print strtonum("0x"$1)}')
truncate -s "$size" "$OUT/Image"
cp "$PAYLOAD" "$OUT/ramdisk.bin"

# Two candidate images — the OP13 ABL honors the header's load addresses (unlike
# the reference device, which ignored them), so they must point at real, free DRAM.
#
# (A) header v2 with explicit addresses inside the OP13 DRAM bank at 0xa3e80000
#     (size 0x14180000, carve-out free per the memory node + reserved-memory):
#       FDT/tags 0xa4000000, kernel 0xa4400000, ramdisk 0xa5000000, dtb 0xa6000000
#     All clear of each other and of XNU's destination (0xbe360000).
mkbootimg --header_version 2 --kernel "$OUT/Image" --ramdisk "$OUT/ramdisk.bin" \
	--dtb "$DTB" --base 0xa4000000 --tags_offset 0x0 --kernel_offset 0x400000 \
	--ramdisk_offset 0x1000000 --dtb_offset 0x2000000 --pagesize 4096 \
	--cmdline "console=null" -o "$OUT/dodge-boot-v2.img"

# (B) header v4 — OP13's native format. v4 stores NO load addresses and no dtb, so
#     ABL uses its own known-good ones and its own device tree. Nothing to guess.
mkbootimg --header_version 4 --kernel "$OUT/Image" --ramdisk "$OUT/ramdisk.bin" \
	--cmdline "console=null" -o "$OUT/dodge-boot-v4.img"

ls -l "$OUT/Image" "$OUT/dodge-boot-v2.img" "$OUT/dodge-boot-v4.img"
