import struct

print("=== Patching Giulia Kernel with Full 35 Step Tracers & HighResetVector Traps ===")
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

# 9. Keep TTBR0 active by skipping TCR_EL1.EPD0 disable (foff: 0x46f4c8)
# Replace 'orr x22, x0, #0x2000000000' with 'mov x22, x0' (0xaa0003f6)
struct.pack_into('<I', buf, 0x46f4c8, 0xaa0003f6)

# 10. NOP out set_mmu_ttb(invalid_ttep) call in arm_vm_init (foff: 0x46f634)
struct.pack_into('<I', buf, 0x46f634, 0xd503201f)

# 10.5 Skip AuxKC checks in arm_vm_init (foff: 0x46f6c8) -> b 0x46f890
struct.pack_into('<I', buf, 0x46f6c8, 0x14000072)

# 10.6 NOP out unmapped dodge_early_disabled store (foff: 0x470ba4)
# 'strb w8, [x9, #2856]' attempts to write to unmapped 0xfffffe0008095b28!
struct.pack_into('<I', buf, 0x470ba4, 0xd503201f)

# 11. INJECT BLUE SCREEN HANDLER AT 0x474000
with open('/tmp/blue_screen.bin', 'rb') as f:
    bs_bin = f.read()

bs_off = 0x474000
buf[bs_off:bs_off+len(bs_bin)] = bs_bin

def branch_insn(from_va, to_va):
    diff = to_va - from_va
    imm26 = (diff >> 2) & 0x3ffffff
    return 0x14000000 | imm26

bs_handler_va = 0xfffffe0007478000 + 0x68
bs_panic_va = 0xfffffe0007478000

# Hook LowResetVector (0x473000):
struct.pack_into('<I', buf, 0x473000, branch_insn(0xfffffe0007477000, bs_handler_va))
struct.pack_into('<I', buf, 0x473080, branch_insn(0xfffffe0007477080, bs_handler_va))
struct.pack_into('<I', buf, 0x473180, branch_insn(0xfffffe0007477180, bs_handler_va))
struct.pack_into('<I', buf, 0x473200, branch_insn(0xfffffe0007477200, bs_handler_va))
struct.pack_into('<I', buf, 0x473280, branch_insn(0xfffffe0007477280, bs_handler_va))
struct.pack_into('<I', buf, 0x473380, branch_insn(0xfffffe0007477380, bs_handler_va))

# Hook HighResetVector (0x478000 - the ACTIVE VBAR_EL1!):
struct.pack_into('<I', buf, 0x478000, branch_insn(0xfffffe000747c000, bs_handler_va))
struct.pack_into('<I', buf, 0x478080, branch_insn(0xfffffe000747c080, bs_handler_va))
struct.pack_into('<I', buf, 0x478180, branch_insn(0xfffffe000747c180, bs_handler_va))
struct.pack_into('<I', buf, 0x478200, branch_insn(0xfffffe000747c200, bs_handler_va))
struct.pack_into('<I', buf, 0x478280, branch_insn(0xfffffe000747c280, bs_handler_va))
struct.pack_into('<I', buf, 0x478380, branch_insn(0xfffffe000747c380, bs_handler_va))

# Hook _panic (foff: 0xa75348) -> blue_screen_panic_msg
struct.pack_into('<I', buf, 0xa75348, branch_insn(0xfffffe0007a79348, bs_panic_va))

# =========================================================================
# 12. INJECT 35 STEP TRACERS (1..Z) INTO FREE PADDING AT 0x472700
# =========================================================================
with open('/tmp/tracers_full.bin', 'rb') as f:
    tracers_bin = f.read()

tracers_off = 0x472700
buf[tracers_off:tracers_off+len(tracers_bin)] = tracers_bin
tracers_base_va = 0xfffffe0007476700

wrap_symbols = [
    (0x46eae8, '1', 0x48),
    (0x46eb00, '2', 0x80),
    (0x46eb44, '3', 0xb8),
    (0x46eb90, '4', 0xf0),
    (0x46ebc4, '5', 0x128),
    (0x46ebe4, '6', 0x160),
    (0x46ec18, '7', 0x198),
    (0x46ec98, '8', 0x1d0),
    (0x46ecc4, '9', 0x208),
    (0x46ed2c, 'A', 0x240),
    (0x46ed58, 'B', 0x278),
    (0x46f45c, 'C', 0x2b0),
    (0x46f488, 'D', 0x2e8),
    (0x46f4c4, 'E', 0x320),
    (0x46f4d8, 'F', 0x358),
    (0x46f520, 'G', 0x390),
    (0x46f534, 'H', 0x3c8),
    (0x46f558, 'I', 0x400),
    (0x46f584, 'J', 0x438),
    (0x46f5cc, 'K', 0x470),
    (0x46f618, 'L', 0x4a8),
    (0x46f61c, 'M', 0x4e0),
    (0x46f654, 'N', 0x518),
    (0x46f668, 'O', 0x550),
    (0x46f6e4, 'P', 0x588),
    (0x46f798, 'Q', 0x5c0),
    (0x46f7c8, 'R', 0x5f8),
    (0x46f7f4, 'S', 0x630),
    (0x46f81c, 'T', 0x668),
    (0x46f970, 'U', 0x6a0),
    (0x46f974, 'V', 0x6d8),
    (0x46fbe0, 'W', 0x710),
    (0x46fc1c, 'X', 0x748),
    (0x46fc20, 'Y', 0x780),
    (0xaa5ca0, 'Z', 0x7b8),
]

for call_fo, char, wrap_rel in wrap_symbols:
    if call_fo < 0xaa0000:
        call_va = 0xfffffe00072d4000 + (call_fo - 0x2d0000)
    else:
        call_va = 0xfffffe0007004000 + (call_fo - 0x4000)
    wrap_va = tracers_base_va + wrap_rel
    insn = branch_insn(call_va, wrap_va)
    bl_insn = (insn & 0x03ffffff) | 0x94000000
    struct.pack_into('<I', buf, call_fo, bl_insn)
    print(f'Hooked call {char} at {hex(call_fo)} -> wrap_{char} ({hex(wrap_va)})')

out_path = '/home/ksn/ios-giuluac/kernel.development.giulia'
with open(out_path, 'wb') as f:
    f.write(buf)

print(f'\nSUCCESS: Generated {out_path} ({len(buf)} bytes) with HighResetVector & Clean Tracers!')
