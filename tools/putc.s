
.text
.global early_putc
early_putc:
    stp     x19, x20, [sp, #-48]!
    stp     x21, x22, [sp, #16]
    stp     x29, x30, [sp, #32]
    mov     x29, sp

    // cursor variables at 0xd5f00000
    mov     x19, #0x0000
    movk    x19, #0xd5f0, lsl #16
    ldp     w20, w21, [x19]

    cmp     w20, #78
    csel    w20, wzr, w20, hi
    cmp     w21, #30
    csel    w21, wzr, w21, hi

    and     w0, w0, #0xff
    cmp     w0, #0x0d
    b.eq    handle_cr

    cmp     w0, #0x0a
    b.eq    handle_nl

    cmp     w20, #78
    b.lo    render_char
    mov     w20, #0
    add     w21, w21, #1
    cmp     w21, #30
    b.lo    render_char
    mov     w21, #0

render_char:
    mov     x1, #0x7800
    movk    x1, #0x2, lsl #16
    mul     x2, x21, x1
    lsl     x3, x20, #6
    add     x2, x2, x3
    mov     x4, #0x0
    movk    x4, #0xd510, lsl #16
    add     x2, x4, x2

    lsl     x5, x0, #4
    mov     x6, #0xa200
    movk    x6, #0x07b0, lsl #16
    movk    x6, #0xfe00, lsl #32
    movk    x6, #0xffff, lsl #48
    add     x5, x6, x5

    mov     w15, #5056
    mov     w6, #0
row_loop:
    ldrb    w7, [x5, w6, uxtw]
    mov     w8, #0
bit_loop:
    lsr     w9, w7, w8
    tst     w9, #1
    mov     w10, #0x0000
    movk    w10, #0xff00, lsl #16
    mov     w11, #0xffff
    movk    w11, #0xffff, lsl #16
    csel    w12, w11, w10, ne

    lsl     w13, w8, #1
    add     x14, x2, w13, uxtw #2
    stp     w12, w12, [x14]
    add     x14, x14, w15, uxtw
    stp     w12, w12, [x14]

    add     w8, w8, #1
    cmp     w8, #8
    b.ne    bit_loop

    lsl     w16, w15, #1
    add     x2, x2, w16, uxtw
    add     w6, w6, #1
    cmp     w6, #16
    b.ne    row_loop

    add     w20, w20, #1
    b       finish

handle_cr:
    mov     w20, #0
    b       finish

handle_nl:
    mov     w20, #0
    add     w21, w21, #1
    cmp     w21, #30
    b.lo    finish
    mov     w21, #0

finish:
    stp     w20, w21, [x19]
    ldp     x29, x30, [sp, #32]
    ldp     x21, x22, [sp, #16]
    ldp     x19, x20, [sp], #48
    ret
