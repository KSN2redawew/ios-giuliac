#!/bin/bash
# Build the giulia shim (OnePlus Ace 5 / SM8650) with clang/LLVM and wrap it as a boot image.
set -euo pipefail
cd "$(dirname "$0")"
export PATH="$HOME/bin:$PATH"

PAYLOAD="${1:-}"
DTB="${2:-/home/ksn/mainline-ksn-ace5/build/linux/arch/arm64/boot/dts/qcom/sm8650-oneplus-giulia.dtb}"
OUT="${3:-out-giulia}"
mkdir -p "$OUT"

TARGET=aarch64-linux-gnu
CFLAGS="-O2 -ffreestanding -nostdlib -fno-pic -mgeneral-regs-only -mstrict-align -fno-stack-protector -Wall -Wextra"
for f in start.S shim.c console.c mmu.c fdt.c loader.c ufs.c; do
	clang --target=$TARGET $CFLAGS -c "$f" -o "$OUT/${f%.*}.o"
done

abs=$(llvm-readelf -r "$OUT"/shim.o "$OUT"/console.o "$OUT"/mmu.o "$OUT"/fdt.o "$OUT"/loader.o "$OUT"/ufs.o 2>/dev/null | grep -c ABS64 || true)
[ "$abs" = 0 ] || { echo "error: $abs absolute relocations in C objects" >&2; exit 1; }

clang --target=$TARGET $CFLAGS -static -fuse-ld=lld -T shim.ld 	-Wl,--build-id=none -Wl,-N 	"$OUT"/start.o "$OUT"/shim.o "$OUT"/console.o "$OUT"/mmu.o "$OUT"/fdt.o "$OUT"/loader.o "$OUT"/ufs.o 	-o "$OUT/shim.elf"

llvm-objcopy -O binary "$OUT/shim.elf" "$OUT/Image"
size=$(llvm-nm "$OUT/shim.elf" | awk '$3=="_end"{print strtonum("0x"$1)}')
truncate -s "$size" "$OUT/Image"

if [ -n "$PAYLOAD" ] && [ -f "$PAYLOAD" ]; then
	echo "Appending payload: $PAYLOAD"
	cat "$PAYLOAD" >> "$OUT/Image"
else
	echo "Note: Building diagnostic boot shim (no XNU payload attached)"
fi

(cd "$OUT" && rm -rf rd && mkdir rd && cd rd && find . | cpio -o -H newc --quiet | gzip -9 > ../ramdisk.bin)

mkbootimg --header_version 4 --kernel "$OUT/Image" --ramdisk "$OUT/ramdisk.bin" 	--cmdline "console=null" -o "$OUT/giulia-boot.img"

ls -lh "$OUT/Image" "$OUT/giulia-boot.img"
echo "Build complete: $OUT/giulia-boot.img"
