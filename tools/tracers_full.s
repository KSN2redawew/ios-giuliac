
.text
.global vm_trace
vm_trace:
    stp     x19, x20, [sp, #-48]!
    stp     x21, x22, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w19, w0

    mov     w0, #0x20 // ' '
    bl      call_putc
    mov     w0, w19
    bl      call_putc

    ldp     x29, x30, [sp, #32]
    ldp     x21, x22, [sp, #16]
    ldp     x19, x20, [sp], #48
    ret

call_putc:
    mov     x16, #0x44f4
    movk    x16, #0x0747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_1
wrap_1:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x31
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x3af0
    movk    x16, #0x745, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_2
wrap_2:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x32
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1b80
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_3
wrap_3:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x33
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0xff98
    movk    x16, #0x745, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_4
wrap_4:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x34
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1b80
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_5
wrap_5:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x35
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x9a00
    movk    x16, #0x7b0, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_6
wrap_6:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x36
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1b80
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_7
wrap_7:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x37
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x9a00
    movk    x16, #0x7b0, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_8
wrap_8:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x38
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1b80
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_9
wrap_9:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp

    // 1. Print ' 9'
    mov     w0, #0x39
    bl      vm_trace

    // 2. Call bzero(x0, 0x4000)
    ldp     x0, x1, [sp]
    stp     x0, x30, [sp, #-16]!
    mov     x16, #0x9a00
    movk    x16, #0x7b0, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    blr     x16
    ldp     x0, x30, [sp], #16

    // 3. Map 32MB blocks 106 and 107 into Level 2 table (x0)
    mov     x10, #0xd4000000
    mov     x11, #0x60000000000000
    movk    x11, #0x605
    orr     x11, x11, x10
    str     x11, [x0, #848]
    mov     x14, #1
    add     x14, x11, x14, lsl #25
    str     x14, [x0, #856]

    // 4. Link Level 2 table into invalid_ttep[0]
    ldr     x8, [x23]
    mov     x12, #0x3910
    movk    x12, #0x0717, lsl #16
    movk    x12, #0xfe00, lsl #32
    movk    x12, #0xffff, lsl #48
    ldr     x12, [x12]
    str     x8, [x12]

    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    ret

.global wrap_A
wrap_A:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x41
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1b80
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_B
wrap_B:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x42
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x9a00
    movk    x16, #0x7b0, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_C
wrap_C:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x43
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1b80
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_D
wrap_D:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x44
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x9a00
    movk    x16, #0x7b0, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_E
wrap_E:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x45
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0xf380
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_F
wrap_F:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x46
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1880
    movk    x16, #0x748, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_G
wrap_G:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x47
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x4384
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_H
wrap_H:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x48
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1b80
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_I
wrap_I:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x49
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x3d60
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_J
wrap_J:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x4a
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x4384
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_K
wrap_K:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x4b
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0xcef4
    movk    x16, #0x786, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_L
wrap_L:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x4c
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1854
    movk    x16, #0x748, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_M
wrap_M:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x4d
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1280
    movk    x16, #0x748, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_N
wrap_N:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x4e
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1b80
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_O
wrap_O:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x4f
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x1b80
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_P
wrap_P:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x50
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0xf4c
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_Q
wrap_Q:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x51
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x3d60
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_R
wrap_R:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x52
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x3d60
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_S
wrap_S:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x53
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x3d60
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_T
wrap_T:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x54
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x3d60
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_U
wrap_U:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x55
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x8a68
    movk    x16, #0x745, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_V
wrap_V:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x56
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x60f0
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_W
wrap_W:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x57
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x58
    movk    x16, #0x746, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_X
wrap_X:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x58
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x8a64
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_Y
wrap_Y:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x59
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x6138
    movk    x16, #0x747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

.global wrap_Z
wrap_Z:
    stp     x0, x1, [sp, #-48]!
    stp     x2, x3, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp
    mov     w0, #0x5a
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0xe230
    movk    x16, #0x7a4, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16




.global probe_box_yellow
probe_box_yellow:
    mov     x0, #0x0000
    movk    x0, #0xd510, lsl #16
    mov     x1, #0x0300
    movk    x1, #0xa2, lsl #16 // row 2100 * 5056 = 0xa20300
    add     x0, x0, x1
    mov     w1, #0xff00
    movk    w1, #0xffff, lsl #16 // YELLOW
    mov     x2, #63200
1:  str     w1, [x0], #4
    subs    x2, x2, #1
    b.ne    1b
    dsb     sy
    ret

.global probe_box_cyan
probe_box_cyan:
    mov     x0, #0x0000
    movk    x0, #0xd510, lsl #16
    mov     x1, #0xba00
    movk    x1, #0xa9, lsl #16 // row 2200 * 5056 = 0xa9ba00
    add     x0, x0, x1
    mov     w1, #0xffff
    movk    w1, #0x00ff, lsl #16 // CYAN
    mov     x2, #63200
1:  str     w1, [x0], #4
    subs    x2, x2, #1
    b.ne    1b
    dsb     sy
    ret

.global probe_box_green
probe_box_green:
    mov     x0, #0x0000
    movk    x0, #0xd510, lsl #16
    mov     x1, #0x7100
    movk    x1, #0xb1, lsl #16 // row 2300 * 5056 = 0xb17100
    add     x0, x0, x1
    mov     w1, #0x0000
    movk    w1, #0x00ff, lsl #16 // GREEN
    mov     x2, #63200
1:  str     w1, [x0], #4
    subs    x2, x2, #1
    b.ne    1b
    dsb     sy
    ret

.global probe_box_white
probe_box_white:
    mov     x0, #0x0000
    movk    x0, #0xd510, lsl #16
    mov     x1, #0x2800
    movk    x1, #0xb9, lsl #16 // row 2400 * 5056 = 0xb92800
    add     x0, x0, x1
    mov     w1, #0xffff
    movk    w1, #0xffff, lsl #16 // WHITE
    mov     x2, #63200
1:  str     w1, [x0], #4
    subs    x2, x2, #1
    b.ne    1b
    dsb     sy
    ret

.global probe_box_blue
probe_box_blue:
    mov     x0, #0x0000
    movk    x0, #0xd510, lsl #16
    mov     x1, #0xdf00
    movk    x1, #0xc0, lsl #16 // row 2500 * 5056 = 0xc0df00
    add     x0, x0, x1
    mov     w1, #0x00ff
    movk    w1, #0x0000, lsl #16 // BLUE
    mov     x2, #63200
1:  str     w1, [x0], #4
    subs    x2, x2, #1
    b.ne    1b
    dsb     sy
    ret

.global run_tlbi_probe
run_tlbi_probe:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // 1. Call dodge_early_disable
    mov     x16, #0x4b84
    movk    x16, #0x0747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    blr     x16

    // 2. Row 2100: YELLOW (dodge_early_disable returned!)
    bl      probe_box_yellow

    // 3. Load invalid_ttep physical address from [0xfffffe0007173918]
    mov     x22, #0x3918
    movk    x22, #0x0717, lsl #16
    movk    x22, #0xfe00, lsl #32
    movk    x22, #0xffff, lsl #48
    ldr     x8, [x22]
    and     x0, x8, #0xffffffffffff

    // 4. Row 2200: CYAN (invalid_ttep address loaded!)
    bl      probe_box_cyan

    // 5. Call set_ttbr0(invalid_ttep)
    mov     x16, #0x1864
    movk    x16, #0x748, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    blr     x16

    // 6. Row 2300: GREEN (set_ttbr0 completed!)
    bl      probe_box_green

    // 7. Flush local TLB
    tlbi    vmalle1
    dsb     sy
    isb

    // 8. Row 2400: WHITE (tlbi completed!)
    bl      probe_box_white

    // 9. Restore arm_vm_init registers
    mov     x8, #0x4000
    movk    x8, #0x0717, lsl #16
    movk    x8, #0xfe00, lsl #32
    movk    x8, #0xffff, lsl #48
    mov     w9, #1
    str     w9, [x8, #56]
    ldr     x0, [x23]

    // 10. Row 2500: BLUE (ready to jump to wrap_N!)
    bl      probe_box_blue

    // 11. Jump to 0xfffffe0007473654
    mov     x16, #0x3654
    movk    x16, #0x0747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    ldp     x29, x30, [sp], #16
    br      x16
