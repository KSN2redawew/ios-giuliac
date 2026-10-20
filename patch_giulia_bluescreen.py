import struct

print("=== Patching Giulia Kernel with Blue Screen Panic & Vector Hooks ===")
with open('/home/ksn/ios-giuluac/kernel-in/kernel.development.dodge.new', 'rb') as f:
    buf = bytearray(f.read())

# 1. TCR_EL1 in sysreg_restore
tcr_off = 0x16fa18
struct.pack_into('<Q', buf, tcr_off, 0x226516a519)

# 2. start.s bootstrap TTBR1 L1 mapping
l1_off = 0x47921c
l1_patch = bytes.fromhex('6b0080d2 4c8c7492 6c010caa 6c0000f9 6c8000f9 6c801ff9 1f2003d5 1f2003d5')
buf[l1_off:l1_off+len(l1_patch)] = l1_patch

# 3. start.s framebuffer bootstrap mapping
fb_off = 0x479290
fb_patch = bytes.fromhex(
    '0a80bad2 0b0ce0d2 abc080f2 6b010aaa 4cfd59d3 2d234091 '
    'ab792cf8 2e0080d2 6e650e8b 8f050091 ae792ff8 9f3b03d5 '
    '1f2003d5 1f2003d5'
)
buf[fb_off:fb_off+len(fb_patch)] = fb_patch

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

# 5. Injected early_putc at 0x4704f4
with open('/tmp/p.bin', 'rb') as f:
    putc_bin = f.read()
buf[0x4704f4:0x4704f4+len(putc_bin)] = putc_bin

# 6. Injected early_mark at 0x4707ac
with open('/tmp/m.bin', 'rb') as f:
    mark_bin = bytearray(f.read())
struct.pack_into('<I', mark_bin, 0xa4, 0x17ffff29) # b 0xfffffe00074744f4
buf[0x4707ac:0x4707ac+len(mark_bin)] = mark_bin

# 7. Pre-initialize kputc function pointer at VA 0xfffffe0007296c18 (foff: 0x292c18)
struct.pack_into('<Q', buf, 0x292c18, 0xfffffe00074744f4)

# 8. Hook _serial_putc (foff: 0xa4c4dc) -> b early_putc
struct.pack_into('<I', buf, 0xa4c4dc, 0x17e89006)

# 9. NOP out dodge_early_disable() call in arm_vm_init (foff: 0x46f620)
struct.pack_into('<I', buf, 0x46f620, 0xd503201f)

# 10. NOP out set_mmu_ttb(invalid_ttep) call in arm_vm_init (foff: 0x46f634)
struct.pack_into('<I', buf, 0x46f634, 0xd503201f)

# =========================================================================
# 11. INJECT BLUE SCREEN HANDLER AT 0x4743ec (VA 0xfffffe00074783ec)
# =========================================================================
with open('/tmp/blue_screen.bin', 'rb') as f:
    bs_bin = f.read()

bs_off = 0x4743ec
buf[bs_off:bs_off+len(bs_bin)] = bs_bin
print(f"11. Injected Blue Screen Handler ({len(bs_bin)} bytes) at foff {hex(bs_off)}")

# VA of blue_screen_handler (offset 0x68 in blue_screen.bin):
# VA = 0xfffffe00074783ec + 0x68 = 0xfffffe0007478454
# VA of blue_screen_panic_msg (offset 0x00 in blue_screen.bin):
# VA = 0xfffffe00074783ec

# 12. Hook LowResetVector Exception Table Entries:
# All vectors in start.s now branch directly to blue_screen_handler!
def branch_insn(from_va, to_va):
    diff = to_va - from_va
    imm26 = (diff >> 2) & 0x3ffffff
    return 0x14000000 | imm26

bs_handler_va = 0xfffffe00074783ec + 0x68
bs_panic_va = 0xfffffe00074783ec

# Vectors in LowResetVector:
# 0x473000 (VA 0xfffffe0007477000): SP0 Sync
struct.pack_into('<I', buf, 0x473000, branch_insn(0xfffffe0007477000, bs_handler_va))
# 0x473080 (VA 0xfffffe0007477080): SP0 IRQ
struct.pack_into('<I', buf, 0x473080, branch_insn(0xfffffe0007477080, bs_handler_va))
# 0x473180 (VA 0xfffffe0007477180): SP0 SError
struct.pack_into('<I', buf, 0x473180, branch_insn(0xfffffe0007477180, bs_handler_va))

# 0x473200 (VA 0xfffffe0007477200): SPx Sync (THE PRIMARY KERNEL EXCEPTION ENTRY!)
struct.pack_into('<I', buf, 0x473200, branch_insn(0xfffffe0007477200, bs_handler_va))
# 0x473280 (VA 0xfffffe0007477280): SPx IRQ
struct.pack_into('<I', buf, 0x473280, branch_insn(0xfffffe0007477280, bs_handler_va))
# 0x473380 (VA 0xfffffe0007477380): SPx SError
struct.pack_into('<I', buf, 0x473380, branch_insn(0xfffffe0007477380, bs_handler_va))
print("12. All 6 LowResetVector entries hooked to blue_screen_handler!")

# 13. Hook _panic (foff: 0xa75348, VA 0xfffffe0007a79348) -> blue_screen_panic_msg
struct.pack_into('<I', buf, 0xa75348, branch_insn(0xfffffe0007a79348, bs_panic_va))
print("13. Hooked _panic -> blue_screen_panic_msg!")

out_path = '/home/ksn/ios-giuluac/kernel.development.giulia'
with open(out_path, 'wb') as f:
    f.write(buf)

print(f"\nSUCCESS: Generated {out_path} ({len(buf)} bytes) with BLUE SCREEN EXCEPTION CAPTURE!")
