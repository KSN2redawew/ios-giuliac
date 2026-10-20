import struct

print("=== Patching Giulia Kernel with Live Visual Console ===")
with open('/home/ksn/ios-giuluac/kernel-in/kernel.development.dodge.new', 'rb') as f:
    buf = bytearray(f.read())

# 1. TCR_EL1 in sysreg_restore
tcr_off = 0x16fa18
struct.pack_into('<Q', buf, tcr_off, 0x226516a519)
print(f"1. TCR_EL1 patched: {hex(struct.unpack_from('<Q', buf, tcr_off)[0])}")

# 2. start.s bootstrap TTBR1 L1 mapping (0xfffffe000747d21c -> foff: 0x47921c)
l1_off = 0x47921c
l1_patch = bytes.fromhex('6b0080d2 4c8c7492 6c010caa 6c0000f9 6c8000f9 6c801ff9 1f2003d5 1f2003d5')
buf[l1_off:l1_off+len(l1_patch)] = l1_patch
print(f"2. TTBR1 L1 mirror patched at {hex(l1_off)}")

# 3. start.s framebuffer bootstrap mapping (0xfffffe000747d290 -> foff: 0x479290)
fb_off = 0x479290
fb_patch = bytes.fromhex(
    '0a80bad2 0b0ce0d2 abc080f2 6b010aaa 4cfd59d3 2d234091 '
    'ab792cf8 2e0080d2 6e650e8b 8f050091 ae792ff8 9f3b03d5 '
    '1f2003d5 1f2003d5'
)
buf[fb_off:fb_off+len(fb_patch)] = fb_patch
print(f"3. Framebuffer TTBR0 mapping patched at {hex(fb_off)}")

# 4. All 9 DODGE_BAND stripes in start.s
stripe_loop_offsets = [
    0x479084, 0x4792e0, 0x47930c, 0x479344, 0x47937c,
    0x479404, 0x47945c, 0x4794ac, 0x4794dc
]
FB_BASE = 0xd5100000
STRIDE = 5056

def encode_movk(reg, imm, shift):
    hw = shift // 16
    return 0xf2800000 | (hw << 21) | (imm << 5) | reg

def encode_movz(reg, imm, shift=0):
    hw = shift // 16
    return 0xd2800000 | (hw << 21) | (imm << 5) | reg

for s, off in enumerate(stripe_loop_offsets):
    row = 1200 + s * 40
    addr = FB_BASE + row * STRIDE
    hi = (addr >> 16) & 0xffff
    lo = addr & 0xffff
    insn_hi = encode_movk(0, hi, 16)
    insn_lo = encode_movk(0, lo, 0)
    insn_w1 = 0x12800001
    insn_x2 = encode_movz(2, 0x9e00)
    patch = struct.pack('<4I', insn_hi, insn_lo, insn_w1, insn_x2)
    patch_loc = off - 16
    buf[patch_loc:patch_loc+16] = patch
print("4. All 9 white bootstrap stripes patched!")

# 5. Injected early_putc at 0x4704f4
with open('/tmp/p.bin', 'rb') as f:
    putc_bin = f.read()
putc_off = 0x4704f4
buf[putc_off:putc_off+len(putc_bin)] = putc_bin
print(f"5. Injected early_putc ({len(putc_bin)} bytes) at {hex(putc_off)}")

# 6. Injected early_mark at 0x4707ac with call to early_putc
with open('/tmp/m.bin', 'rb') as f:
    mark_bin = bytearray(f.read())
# Patch call_putc at offset 0xa4 in mark_bin
struct.pack_into('<I', mark_bin, 0xa4, 0x17ffff29) # b 0xfffffe00074744f4
mark_off = 0x4707ac
buf[mark_off:mark_off+len(mark_bin)] = mark_bin
print(f"6. Injected early_mark ({len(mark_bin)} bytes) at {hex(mark_off)}")

# 7. Pre-initialize kputc function pointer at VA 0xfffffe0007296c18 (foff: 0x292c18)
# Points directly to early_putc (0xfffffe00074744f4)
kputc_off = 0x292c18
struct.pack_into('<Q', buf, kputc_off, 0xfffffe00074744f4)
print(f"7. Pre-initialized kputc at {hex(kputc_off)} -> 0xfffffe00074744f4")

# 8. Hook _serial_putc (foff: 0xa4c4dc) -> b early_putc
serial_putc_off = 0xa4c4dc
struct.pack_into('<I', buf, serial_putc_off, 0x17e89006)
print(f"8. Hooked _serial_putc at {hex(serial_putc_off)} -> b early_putc")

# 9. NOP out dodge_early_disable() call in arm_vm_init (foff: 0x46f620)
disable_call_off = 0x46f620
struct.pack_into('<I', buf, disable_call_off, 0xd503201f)
print(f"9. NOPed out dodge_early_disable call at {hex(disable_call_off)}")

# 10. NOP out set_mmu_ttb(invalid_ttep) call in arm_vm_init (foff: 0x46f634)
ttb_call_off = 0x46f634
struct.pack_into('<I', buf, ttb_call_off, 0xd503201f)
print(f"10. NOPed out set_mmu_ttb(invalid_ttep) call at {hex(ttb_call_off)}")

out_path = '/home/ksn/ios-giuluac/kernel.development.giulia'
with open(out_path, 'wb') as f:
    f.write(buf)

print(f"\nSUCCESS: Generated {out_path} ({len(buf)} bytes) with VISUAL CONSOLE & MILESTONE TEXT!")
