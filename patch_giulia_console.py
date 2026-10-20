import struct

print("Loading kernel.development.dodge.new...")
with open('/home/ksn/ios-giuluac/kernel-in/kernel.development.dodge.new', 'rb') as f:
    buf = bytearray(f.read())

# 1. TCR_EL1 in sysreg_restore
tcr_off = 0x16fa18
old_tcr, = struct.unpack_from('<Q', buf, tcr_off)
assert old_tcr == 0x226519a519
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
    insn_w1 = 0x12800001 # mov w1, #-1
    insn_x2 = encode_movz(2, 0x9e00) # mov x2, #0x9e00
    patch = struct.pack('<4I', insn_hi, insn_lo, insn_w1, insn_x2)
    patch_loc = off - 16
    buf[patch_loc:patch_loc+16] = patch
print("4. All 9 white bootstrap stripes patched!")

# 5. _dodge_early_mark (0xfffffe00074747ac -> foff: 0x4707ac) with 8 milestone colors
mark_off = 0x4707ac
# 9 entries (0..8): None, Green, Blue, Yellow, Magenta, Cyan, Orange, White, Grey
mark_bytes = bytes.fromhex(
    '1f200071 28020054 02058052 027c021b 03c88052 4200030b 03788252 427c239b '
    '040080d2 04a2baf2 8200028b 23010010 615860b8 03c093d2 414400b8 630400f1 '
    'c1ffff54 9f3f03d5 c0035fd6 1f2003d5 '
    '00000000 00ff00ff ff0000ff 00ffffff ffff00ff ff00ffff 00a5ffff ffffffff 808080ff'
)
buf[mark_off:mark_off+len(mark_bytes)] = mark_bytes
print(f"5. Early milestone markers patched at {hex(mark_off)}")

# 6. Inject early_putc at 0x4704f4 (_dodge_early_putc)
with open('/tmp/putc.bin', 'rb') as f:
    putc_bin = f.read()
putc_off = 0x4704f4
buf[putc_off:putc_off+len(putc_bin)] = putc_bin
print(f"6. Injected early_putc ({len(putc_bin)} bytes) at {hex(putc_off)}")

# 7. Hook _serial_putc (foff: 0xa4c4dc) to jump to early_putc (0x4704f4)
# b 0xfffffe00074744f4 = 0x17e89006
serial_putc_off = 0xa4c4dc
struct.pack_into('<I', buf, serial_putc_off, 0x17e89006)
print(f"7. Hooked _serial_putc at {hex(serial_putc_off)} -> b early_putc")

# 8. NOP out dodge_early_disable() call in arm_vm_init (foff: 0x46f620)
# This keeps early_disabled = 0 forever!
disable_call_off = 0x46f620
struct.pack_into('<I', buf, disable_call_off, 0xd503201f) # nop
print(f"8. NOPed out dodge_early_disable call at {hex(disable_call_off)}")

# 9. NOP out set_mmu_ttb(invalid_ttep) call in arm_vm_init (foff: 0x46f634)
# This keeps bootstrap TTBR0 active for the framebuffer throughout kernel boot!
ttb_call_off = 0x46f634
struct.pack_into('<I', buf, ttb_call_off, 0xd503201f) # nop
print(f"9. NOPed out set_mmu_ttb(invalid_ttep) call at {hex(ttb_call_off)}")

out_path = '/home/ksn/ios-giuluac/kernel.development.giulia'
with open(out_path, 'wb') as f:
    f.write(buf)

print(f"\nSUCCESS: Generated {out_path} ({len(buf)} bytes) with LIVE SCREEN CONSOLE!")
