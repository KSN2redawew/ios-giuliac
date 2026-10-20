.text
.global blue_screen_handler
.global blue_screen_panic_msg

blue_screen_panic_msg:
    mov     x19, x0

    // Reset cursor to col 1, row 28
    mov     x1, #0x0000
    movk    x1, #0xd5f0, lsl #16
    mov     w2, #1
    mov     w3, #28
    stp     w2, w3, [x1]

    adr     x0, str_panic_hdr
    bl      print_str

    cbz     x19, p_hang
    mov     x23, x19
p_str_loop:
    ldrb    w0, [x23], #1
    cbz     w0, p_hang
    bl      call_putc
    b       p_str_loop

p_hang:
    wfe
    b       p_hang

blue_screen_handler:
    mov     x28, x30      // PRESERVE LR (caller of NULL!)
    mrs     x19, esr_el1
    mrs     x20, elr_el1
    mrs     x21, far_el1
    mrs     x22, spsr_el1
    mov     x27, sp       // PRESERVE SP

    // Fill only bottom half (rows 1200..2700) with dark blue
    mov     x1, #0x0000
    movk    x1, #0xd510, lsl #16
    mov     x4, #0x0000
    movk    x4, #0x5c, lsl #16 // row 1200 offset = 1200 * 5056 = 0x5cb800 -> ~0x5c0000
    add     x1, x1, x4
    mov     w2, #0x00ff
    movk    w2, #0x0000, lsl #16 // Dark blue
    mov     x3, #0x0000
    movk    x3, #0x20, lsl #16
clr_fb:
    str     w2, [x1], #4
    subs    x3, x3, #1
    b.ne    clr_fb
    dsb     sy

    // Set cursor to column 1, row 25
    mov     x1, #0x0000
    movk    x1, #0xd5f0, lsl #16
    mov     w2, #1
    mov     w3, #25
    stp     w2, w3, [x1]

    adr     x0, str_panic_sync
    bl      print_str

    adr     x0, str_esr
    bl      print_str
    mov     x0, x19
    bl      print_hex
    mov     w0, #10
    bl      call_putc

    adr     x0, str_elr
    bl      print_str
    mov     x0, x20
    bl      print_hex
    mov     w0, #10
    bl      call_putc

    adr     x0, str_lr
    bl      print_str
    mov     x0, x28
    bl      print_hex
    mov     w0, #10
    bl      call_putc

    adr     x0, str_far
    bl      print_str
    mov     x0, x21
    bl      print_hex
    mov     w0, #10
    bl      call_putc

    adr     x0, str_spsr
    bl      print_str
    mov     x0, x22
    bl      print_hex
    mov     w0, #10
    bl      call_putc

hang:
    wfe
    b       hang

print_str:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    mov     x23, x0
ps_loop:
    ldrb    w0, [x23], #1
    cbz     w0, ps_done
    bl      call_putc
    b       ps_loop
ps_done:
    ldp     x29, x30, [sp], #16
    ret

print_hex:
    stp     x29, x30, [sp, #-32]!
    stp     x24, x25, [sp, #16]
    mov     x29, sp
    mov     x24, x0
    mov     w25, #60
ph_loop:
    lsr     x0, x24, x25
    and     w0, w0, #0xf
    cmp     w0, #10
    b.lt    ph_num
    add     w0, w0, #(0x41 - 10)
    b       ph_out
ph_num:
    add     w0, w0, #0x30
ph_out:
    bl      call_putc
    subs    w25, w25, #4
    b.ge    ph_loop
    ldp     x24, x25, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret

call_putc:
    mov     x16, #0x44f4
    movk    x16, #0x0747, lsl #16
    movk    x16, #0xfe00, lsl #32
    movk    x16, #0xffff, lsl #48
    br      x16

str_panic_hdr:
    .asciz  "PANIC\n\n"
str_panic_sync:
    .asciz  "PANIC SYNC\n\n"
str_esr:
    .asciz  "ESR  "
str_elr:
    .asciz  "ELR  "
str_lr:
    .asciz  "LR   "
str_far:
    .asciz  "FAR  "
str_spsr:
    .asciz  "SPSR "
