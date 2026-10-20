.text
.global blue_screen_handler
.global blue_screen_panic_msg

blue_screen_panic_msg:
    mov     x24, x30      // caller of _panic
    mov     x19, x0       // fmt or msg
    ldr     x20, [sp, #0] // arg1: prefix string on stack
    ldr     x23, [sp, #24]// arg4: saved_state pointer on stack

    // 1. Fill entire framebuffer with BLUE (0xff0000ff)
    mov     x1, #0x0000
    movk    x1, #0xd510, lsl #16
    mov     w2, #0x00ff
    movk    w2, #0xff00, lsl #16
    mov     x3, #0xa000
    movk    x3, #0x35, lsl #16
clr_p_fb:
    str     w2, [x1], #4
    subs    x3, x3, #1
    b.ne    clr_p_fb
    dsb     sy

    // 2. Reset cursor
    mov     x1, #0x0000
    movk    x1, #0xd5f0, lsl #16
    mov     w2, #1
    mov     w3, #1
    stp     w2, w3, [x1]

    adr     x0, str_panic_hdr
    bl      print_str

    cbz     x19, p_hang

    // Check if format string starts with "%s" (panic_display_saved_state)
    ldrb    w0, [x19]
    cmp     w0, #0x25     // '%'
    b.ne    p_plain_str
    ldrb    w0, [x19, #1]
    cmp     w0, #0x73     // 's'
    b.ne    p_plain_str

    // Decode panic_display_saved_state arguments:
    cbz     x20, 1f
    mov     x0, x20       // print prefix reason string (e.g. "Kernel data abort")
    bl      print_str
    mov     w0, #10
    bl      call_putc
1:
    cbz     x23, 2f
    // Load exact fault registers from saved_state structure
    ldr     x21, [x23, #264] // PC
    ldr     x22, [x23, #248] // LR
    ldr     w25, [x23, #288] // ESR
    ldr     x26, [x23, #280] // FAR

    adr     x0, str_pc
    bl      print_str
    mov     x0, x21       // faulting PC
    bl      print_hex
    mov     w0, #10
    bl      call_putc

    adr     x0, str_lr
    bl      print_str
    mov     x0, x22       // faulting LR
    bl      print_hex
    mov     w0, #10
    bl      call_putc

    adr     x0, str_esr
    bl      print_str
    mov     w0, w25       // ESR
    bl      print_hex
    mov     w0, #10
    bl      call_putc

    adr     x0, str_far
    bl      print_str
    mov     x0, x26       // FAR
    bl      print_hex
    mov     w0, #10
    bl      call_putc
2:
    adr     x0, str_caller
    bl      print_str
    mov     x0, x24       // caller of _panic
    bl      print_hex
    mov     w0, #10
    bl      call_putc
    b       p_hang

p_plain_str:
    mov     x23, x19
p_str_loop:
    ldrb    w0, [x23], #1
    cbz     w0, 3f
    bl      call_putc
    b       p_str_loop
3:
    mov     w0, #10
    bl      call_putc
    adr     x0, str_caller
    bl      print_str
    mov     x0, x24
    bl      print_hex
    mov     w0, #10
    bl      call_putc

p_hang:
    wfe
    b       p_hang

blue_screen_handler:
    mov     x28, x30      // PRESERVE LR (caller of NULL!)
    mrs     x19, esr_el1
    mrs     x20, elr_el1
    mrs     x21, far_el1
    mrs     x22, spsr_el1

    // 1. Fill entire framebuffer with BLUE (0xff0000ff)
    mov     x1, #0x0000
    movk    x1, #0xd510, lsl #16
    mov     w2, #0x00ff
    movk    w2, #0xff00, lsl #16
    mov     x3, #0xa000
    movk    x3, #0x35, lsl #16
clr_fb:
    str     w2, [x1], #4
    subs    x3, x3, #1
    b.ne    clr_fb
    dsb     sy

    // 2. Reset cursor
    mov     x1, #0x0000
    movk    x1, #0xd5f0, lsl #16
    mov     w2, #1
    mov     w3, #1
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
str_pc:
    .asciz  "PC   "
str_caller:
    .asciz  "CALL "
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
