
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
    mov     w0, #0x39
    bl      vm_trace
    ldp     x29, x30, [sp, #32]
    ldp     x2, x3, [sp, #16]
    ldp     x0, x1, [sp], #48
    mov     x16, #0x9a00
    movk    x16, #0x7b0, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

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

