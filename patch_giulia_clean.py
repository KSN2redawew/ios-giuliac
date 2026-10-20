import struct
import subprocess

print("=== Patching Giulia Kernel: Full TTBR1 Framebuffer & Zero-Fault Early Console ===")
with open('/home/ksn/ios-giuluac/kernel-in/kernel.development.dodge.new', 'rb') as f:
    buf = bytearray(f.read())

# 1. TCR_EL1 in sysreg_restore
tcr_off = 0x16fa18
struct.pack_into('<Q', buf, tcr_off, 0x226516a519)

# 2. start.s bootstrap TTBR1 L1 mapping: map L2 table into TTBR1 entry 0, 32 (kernel text/data), 61 (heap/zone map), 63 (top map)
l1_off = 0x47921c
l1_patch = bytes.fromhex('6b0080d2 4c8c7492 6c010caa 6c0000f9 6c8000f9 6cf400f9 6cfc00f9 1f2003d5')
buf[l1_off:l1_off+len(l1_patch)] = l1_patch

# 3. start.s framebuffer bootstrap mapping (32MB blocks at 0xd4000000 and 0xd6000000)
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

# 5. Injected physical-framebuffer early_putc at 0x4704f4
with open('/tmp/p.bin', 'rb') as f:
    putc_bin = f.read()
buf[0x4704f4:0x4704f4+len(putc_bin)] = putc_bin

# 5.5 Embed ISO font into __TEXT_EXEC padding at 0xb06200 (VA 0xfffffe0007b0a200)
# This ensures early_putc can read font even when __DATA is not mapped yet!
with open('/tmp/iso_font.bin', 'rb') as f:
    font_bin = f.read()
buf[0xb06200:0xb06200+len(font_bin)] = font_bin
print(f"Embedded {len(font_bin)} bytes font into __TEXT_EXEC at 0xb06200 (VA 0xfffffe0007b0a200)")

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
struct.pack_into('<I', buf, 0x46f4c8, 0xaa0003f6)

# 9.5 Skip AuxKC checks in arm_vm_init (foff: 0x46f6c8) -> b 0x46f890
struct.pack_into('<I', buf, 0x46f6c8, 0x14000072)

# 9.6 NOP out unmapped dodge_early_disabled store (foff: 0x470ba4)
struct.pack_into('<I', buf, 0x470ba4, 0xd503201f)

def branch_insn(from_va, to_va):
    diff = to_va - from_va
    imm26 = (diff >> 2) & 0x3ffffff
    return 0x14000000 | imm26

# =========================================================================
# READ DYNAMIC SYMBOLS FROM tracers_full.elf
# =========================================================================
nm_out = subprocess.check_output(['aarch64-linux-gnu-nm', '/tmp/tracers_full.elf']).decode()
symbols = {}
for line in nm_out.splitlines():
    parts = line.split()
    if len(parts) >= 3 and parts[1].upper() == 'T':
        symbols[parts[2]] = int(parts[0], 16)

# 10. Keep TTBR0 active across arm_vm_init by NOPing set_ttbr0 at 0x46f634
struct.pack_into('<I', buf, 0x46f634, 0xd503201f) # nop
print('NOPed 0x46f634 (set_ttbr0) -> TTBR0 stays active for framebuffer')

# 10.1 NOP out tlbi vmalle1is / dsb / isb (tlbi hangs on SM8650 while TTBR0 is active)
struct.pack_into('<I', buf, 0x46f638, 0xd503201f) # nop tlbi
struct.pack_into('<I', buf, 0x46f63c, 0xd503201f) # nop dsb
struct.pack_into('<I', buf, 0x46f640, 0xd503201f) # nop isb
print('NOPed 0x46f638..0x46f640: keep TLB cache intact across arm_vm_init')

# 10.2 Bypass segment contiguity panics in arm_vm_init:
# 0x46f8f8: b.ne 0x46fc68 -> nop (bypass segDATACONSTB == segTEXTB + segSizeTEXT)
struct.pack_into('<I', buf, 0x46f8f8, 0xd503201f) # nop
# 0x46f914: b.ne 0x46fc6c -> nop (bypass segTEXTEXECB == segDATACONSTB + segSizeDATACONST)
struct.pack_into('<I', buf, 0x46f914, 0xd503201f) # nop
print('NOPed 0x46f8f8 and 0x46f914 -> bypassed segment contiguity panics!')

# 10.3 Bypass ml_phys_read_data and ml_phys_write_data latency timeout panics
# On Snapdragon SM8650, bus latency differs from Apple Silicon, triggering watchdog timeout.
struct.pack_into('<I', buf, 0x4713d8, 0xd503201f) # nop (ml_phys_read_data timeout panic)
struct.pack_into('<I', buf, 0x471768, 0xd503201f) # nop (ml_phys_write_data timeout panic)
print('NOPed 0x4713d8 and 0x471768 -> bypassed ml_phys latency watchdog panics!')

# 11. INJECT BLUE SCREEN HANDLER AT 0x474000
with open('/tmp/blue_screen.bin', 'rb') as f:
    bs_bin = f.read()

bs_off = 0x474000
buf[bs_off:bs_off+len(bs_bin)] = bs_bin

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
assert len(tracers_bin) <= (0x473000 - tracers_off), f'tracers_bin {len(tracers_bin)} overflows into 0x473000!'
buf[tracers_off:tracers_off+len(tracers_bin)] = tracers_bin

call_sites = [
    (0x46eae8, '1'),
    (0x46eb00, '2'),
    (0x46eb44, '3'),
    (0x46eb90, '4'),
    (0x46ebc4, '5'),
    (0x46ebe4, '6'),
    (0x46ec18, '7'),
    (0x46ec98, '8'),
    (0x46ecc4, '9'),
    (0x46ed2c, 'A'),
    (0x46ed58, 'B'),
    (0x46f45c, 'C'),
    (0x46f488, 'D'),
    (0x46f4c4, 'E'),
    (0x46f4d8, 'F'),
    (0x46f520, 'G'),
    (0x46f534, 'H'),
    (0x46f558, 'I'),
    (0x46f584, 'J'),
    (0x46f5cc, 'K'),
    (0x46f618, 'L'),
    (0x46f61c, 'M'),
    (0x46f654, 'N'),
    (0x46f668, 'O'),
    (0x46f6e4, 'P'),
    (0x46f798, 'Q'),
    (0x46f7c8, 'R'),
    (0x46f7f4, 'S'),
    (0x46f81c, 'T'),
    (0x46f970, 'U'),
    (0x46f974, 'V'),
    (0x46fbe0, 'W'),
    (0x46fc1c, 'X'),
    (0x46fc20, 'Y'),
    (0xaa5ca0, 'Z'),
]

for call_fo, char in call_sites:
    if call_fo < 0xaa0000:
        call_va = 0xfffffe00072d4000 + (call_fo - 0x2d0000)
    else:
        call_va = 0xfffffe0007004000 + (call_fo - 0x4000)
    wrap_va = symbols[f'wrap_{char}']
    insn = branch_insn(call_va, wrap_va)
    bl_insn = (insn & 0x03ffffff) | 0x94000000
    struct.pack_into('<I', buf, call_fo, bl_insn)
    print(f'Hooked call {char} at {hex(call_fo)} -> wrap_{char} ({hex(wrap_va)})')

out_path = '/home/ksn/ios-giuluac/kernel.development.giulia'
with open(out_path, 'wb') as f:
    f.write(buf)

print(f'\nSUCCESS: Generated {out_path} ({len(buf)} bytes) with TTBR1-aware framebuffer!')
