.text
.global blue_screen_panic_msg
blue_screen_panic_msg:
    mov     x19, x0

    // Fill screen with blue (0xff0000ff):
    mov     x1, #0x0000
    movk    x1, #0xd510, lsl #16
    movk    x1, #0xfe00, lsl #32
    movk    x1, #0xffff, lsl #48
    mov     w2, #0x00ff
    movk    w2, #0xff00, lsl #16
    mov     x3, #0xa000
    movk    x3, #0x0035, lsl #16
fill_panic_loop:
    str     w2, [x1], #4
    subs    x3, x3, #1
    b.ne    fill_panic_loop
    dsb     sy

    // Reset cursor at 0xfffffe00d5f00000:
    mov     x1, #0x0000
    movk    x1, #0xd5f0, lsl #16
    movk    x1, #0xfe00, lsl #32
    movk    x1, #0xffff, lsl #48
    mov     w2, #1
    mov     w3, #1
    stp     w2, w3, [x1]

    adr     x0, panic_title
    bl      bs_puts

    cbz     x19, freeze_loop
    mov     x23, x19
print_msg:
    ldrb    w0, [x23], #1
    cbz     w0, freeze_loop
    bl      bs_putc
    b       print_msg

freeze_loop:
    wfe
    b       freeze_loop

.global blue_screen_handler
blue_screen_handler:
    mrs     x19, esr_el1
    mrs     x20, elr_el1
    mrs     x21, far_el1
    mrs     x22, spsr_el1

    // Fill screen with blue (0xff0000ff):
    mov     x1, #0x0000
    movk    x1, #0xd510, lsl #16
    movk    x1, #0xfe00, lsl #32
    movk    x1, #0xffff, lsl #48
    mov     w2, #0x00ff
    movk    w2, #0xff00, lsl #16
    mov     x3, #0xa000
    movk    x3, #0x0035, lsl #16
fill_loop:
    str     w2, [x1], #4
    subs    x3, x3, #1
    b.ne    fill_loop
    dsb     sy

    // Reset cursor at 0xfffffe00d5f00000:
    mov     x1, #0x0000
    movk    x1, #0xd5f0, lsl #16
    movk    x1, #0xfe00, lsl #32
    movk    x1, #0xffff, lsl #48
    mov     w2, #1
    mov     w3, #1
    stp     w2, w3, [x1]

    adr     x0, panic_header
    bl      bs_puts

    adr     x0, str_esr
    bl      bs_puts
    mov     x0, x19
    bl      bs_hex64

    adr     x0, str_elr
    bl      bs_puts
    mov     x0, x20
    bl      bs_hex64

    adr     x0, str_far
    bl      bs_puts
    mov     x0, x21
    bl      bs_hex64

    adr     x0, str_spsr
    bl      bs_puts
    mov     x0, x22
    bl      bs_hex64

bs_spin:
    wfe
    b       bs_spin

bs_puts:
    mov     x23, x0
1:  ldrb    w0, [x23], #1
    cbz     w0, 2f
    bl      bs_putc
    b       1b
2:  ret

bs_hex64:
    stp     x29, x30, [sp, #-32]!
    str     x19, [sp, #16]
    mov     x19, x0
    mov     w24, #60
1:  lsr     x0, x19, x24
    and     w0, w0, #0xf
    cmp     w0, #10
    blo     2f
    add     w0, w0, #('A' - 10)
    b       3f
2:  add     w0, w0, #'0'
3:  bl      bs_putc
    subs    w24, w24, #4
    bge     1b
    mov     w0, #0x0a
    bl      bs_putc
    ldr     x19, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret

bs_putc:
    mov     x16, #0x44f4
    movk    x16, #0x0747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

panic_title:
    .asciz "\nPANIC: "

panic_header:
    .asciz "\nPANIC SYNC\n\n"

str_esr:
    .asciz "ESR   "

str_elr:
    .asciz "ELR   "

str_far:
    .asciz "FAR   "

str_spsr:
    .asciz "SPSR  "
