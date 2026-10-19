# iOS 16 (xnu-8796) on dodge (OnePlus 13, SM8750 / Oryon) — working notes

Fork of dipa-studio/ios-sweet. We follow their PROVEN method (they reached the
SpringBoard home screen on sweet / Redmi Note 10 Pro, SM7150). Their full bring-up
log is `NOTES-sweet-upstream.md` — READ IT; it is the step-by-step recipe. Copy no
code (no license); write our own, credit dipa.

## Agent handoff / active work (2026-10-19)

**STATE: kernel does not compile fully yet — build-enabling iteration on CI.**
- Local xnu checkout we author in: `~/ios18_op13/work/ios16/xnu/` (git, author
  palazik <gochmyradov0@gmail.com>). Patches exported to
  `~/ios18_op13/work/ios16/patches/` and copied into `dodge/patches/`.
- Patches so far:
  - 0001 DODGE board config (makedefs/MakeInc.def machine config = plain arm64,
    arm64e force guarded; pexpert/arm64/DODGE.h = NO_MONITOR, HAS_GIC_V3,
    __ARM_16K_PG__, GICR stride 0x40000, DODGE_VTIMER_INTID 27; board_config.h DODGE
    block MAX_CPUS 8 / 2 clusters; config/MASTER.arm64.dodge = MASTER.arm64.MacOSX
    + nos_arm_asm nos_arm_pmap).
  - 0002 open-build fixes (proc_reg.h DODGE shares VMAPPLE cache-line branch; pmap.h
    reserved10->reserved10b; dropped USE_APPLEARMSMP = legacy IOCPU+PSCI path;
    osfmk/arm64/ppl/{sart,uat}.h no-op stubs).
  - 0003 NO_MONITOR pmap lockdown helpers + fwd decl of pmap_phys_write_disable.
  - 0004 tunables.s no-op APPLY_TUNABLES + ptep_get_iommu NULL stub.
  - 0005 closed-lib osfmk gaps: stub osfmk/arm64/{amcc_rorgn_common,amcc_rorgn_ppl}.c,
    a real osfmk/arm64/kpc.c backend (no counters; shape from <kern/kpc.h>),
    caches_asm.s (clean_mmu_dcache label + CleanPoC_DcacheRegion_Force_nopreempt{,_nohid}
    for !APPLE_ARM64_ARCH_FAMILY), ml_enable_monitor() no-op (#if DODGE),
    pmap_pending_preemption() -> _pmap_pending_preemption_real(), SleepToken under
    WITH_CLASSIC_S2R. Fixes build 6's "No rule to make target amcc_rorgn_*/kpc.c".
- CI: `gh workflow run xnu.yml -R palazik/ios-dodge -f kernel_config=DEVELOPMENT -f machine_config=DODGE -f keep_going=true`
  (fork push events do NOT auto-trigger). Build 7 = run 39261994284 (SHA 4447d10,
  keep_going=true) — IN PROGRESS at handoff; check its log for the next gap.
- Our config matches dipa's (config_pmap_ppl nos_arm_asm nos_arm_pmap, kperf kpc,
  sched_hygiene_debug), so expect roughly dipa's remaining 0006-0009 class of fixes
  (master-config detail, stub apple-internal headers, kpc stub [done], drop
  apple-SoC-only KPI exports) before a clean kernel.development.dodge Mach-O.

## Key lessons from dipa's NOTES that change the dodge plan (apply when we boot)
- **GIC timer is NOT a simple INTID-27 FIQ.** XNU's VMAPPLE GICv3 path (pexpert/arm/
  pe_fiq.c) puts the arch timer on PPI 27, **Group 0 = FIQ**. If the GIC has
  SecurityExtn=1 (DS=0) — true on sweet, CHECK on dodge — Group 0 is *secure* and
  undeliverable from NS-EL1. dipa reworked it to a **Group 1 IRQ**: sleh_irq acks
  ICC_IAR1, routes the vtimer INTID to rtclock_intr, EOI via ICC_EOIR1, enable via
  ICC_IGRPEN1. This is our equivalent of dipa 0017/0018 (device-tree vtimer IRQ +
  boot-CPU driver).
- **vtimer INTID is device-specific.** sweet virt PPI 3 -> INTID 19 (NOT 27). Our
  DODGE.h currently has 27 from the OP13 DTS (virt PPI 11 -> 16+11 = 27); VERIFY
  against the live DTS before trusting it (see work/sm8750/).
- **PSCI conduit = SMC on Qualcomm** (VMAPPLE uses HVC). CPU_ON via SMC for SMP.
- **Debug channel = framebuffer**, likely no usable serial (sweet UART was SPI mode).
  Need an early fb console + markers like dipa 0003 (sweet-fbcon) / 0010 (early fb
  debug: PA marker band in start.s before MMU, then VA-alias putc through arm_init).
- **Machine config** (validates ours): VMAPPLE (16K, GICv3 pe_fiq.c) minus
  APPLEVIRTUALPLATFORM paravirt/HVC, plus BCM2837-style generic ARM (no
  APPLE_ARM64_ARCH_FAMILY), plain arm64 (no PAC), don't link the KDK lib.
- **SMP open question:** dipa's early plan used USE_APPLEARMSMP + built-in IOKit
  SweetGIC/SweetPMGR; we currently DROPPED USE_APPLEARMSMP (patch 0002, legacy path).
  Revisit at the SMP milestone — pick whichever reaches multi-core first.

## QEMU (Arch Linux testbed — see ~/ios18_op13/ios16-arch-qemu-prompt.txt)
dipa already built a QEMU harness (in `tools/`, study + adapt for dodge, don't copy):
- `tools/mkadt.py OUT.adt --qemu` = QEMU-virt ADT: GICD 0x08000000, GICR 0x080a0000,
  CNTFRQ 62.5 MHz.
- `tools/qemu-sweet.py PAYLOAD OUTDIR [--secs N] [--gdb]` = host-side loader (segments
  + ADT + boot_args at their PAs + a 6-insn stub that sets x0 and jumps), runs
  `-M virt,gic-version=3 -cpu cortex-a76`, 4 GB RAM (so the fb and kernel PAs are plain
  RAM), outputs fb.png / regs.txt / qemu.log (ESR/FAR/ELR), `--gdb` = stub on :1234.
- Not emulated: Qualcomm XPUs, ABL, real panel, PSCI conduit (virt uses hvc). This is
  the fast iterate loop BEFORE touching the phone.

## Two boot targets (do not conflate)
1. QEMU on Arch Linux = dev testbed (above).
2. OnePlus 13 phone via Project Silicium UEFI = real-hardware deploy. HARD CONSTRAINT:
   NON-DESTRUCTIVE — never wipe userdata, never delete Android. `fastboot boot` (RAM
   only); if a flash is ever needed use the inactive A/B slot; iOS root is a FILE/
   ramdisk, never over an Android partition. ARB1 does not gate the custom boot image
   (only the Qualcomm signed firmware chain), bootloader must be UNLOCKED. (This
   differs from sweet's AGENTS, which allowed deleting Android — ignore that here.)

## Device facts (from work/sm8750 DTS + iomem; verify on live DT)
- GICv3: GICD 0x16000000 (0x10000), GICR 0x16080000 (0x200000), redistributor-stride
  0x40000, 1 region. Arch timer 19.2 MHz. CPUs: 8 Oryon / 2 clusters. 16K granule.
  Framebuffer bootloader-provided (ABL/Silicium), address via ADT/boot-args.
