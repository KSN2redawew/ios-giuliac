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
	-Wl,--build-id=none -Wl,--no-warn-rwx-segments -Wl,-N \
	"$OUT"/start.o "$OUT"/shim.o "$OUT"/console.o "$OUT"/mmu.o "$OUT"/fdt.o "$OUT"/loader.o "$OUT"/ufs.o \
	-o "$OUT/shim.elf"
llvm-objcopy -O binary "$OUT/shim.elf" "$OUT/Image"
# Pad to _end so .bss/stacks exist as zeroed bytes (ABL just copies the file).
size=$(llvm-nm "$OUT/shim.elf" | awk '$3=="_end"{print strtonum("0x"$1)}')
truncate -s "$size" "$OUT/Image"
cp "$PAYLOAD" "$OUT/ramdisk.bin"

# Boot-image offsets: starting from dipa's SM7150 values (relocatable shim, so
# low-risk). Adjust if the OP13 ABL rejects the image. fastboot boot is RAM-only.
mkbootimg --header_version 2 --kernel "$OUT/Image" --ramdisk "$OUT/ramdisk.bin" \
	--dtb "$DTB" --base 0 --kernel_offset 0x8000 --ramdisk_offset 0x1000000 \
	--tags_offset 0x100 --dtb_offset 0x1f00000 --pagesize 4096 \
	--cmdline "console=null" -o "$OUT/dodge-boot.img"
ls -l "$OUT/Image" "$OUT/dodge-boot.img"
