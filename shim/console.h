#pragma once
#include <stdint.h>

#define FB_BASE		0xfc800000UL	/* dodge cont_splash_region (OP13 iomem/DTS) */
/* OP13 panel is QHD+ 1440x3168. CONFIRMED on-device 2026-10-20: a first boot with
 * 1264x2772 filled exactly 77% of the panel (14.0 MB of an 18.2 MB framebuffer)
 * and sheared each text row, which is the signature of writing 5056 B/row into a
 * 5760 B/row framebuffer. 3168 * 5760 == the full splash region. */
#define FB_W		1440
#define FB_H		3168
#define FB_STRIDE	(FB_W * 4)	/* a8r8g8b8, matches mainline simplefb */

#define RED	0xffff0000U
#define BLUE	0xff0000a0U
#define WHITE	0xffffffffU
#define YELLOW	0xffffff00U
#define GREEN	0xff00ff00U

extern volatile uint32_t *con_fb;

void con_clear(uint32_t bg);
void con_skip(void);
void con_str(const char *label, const char *s);
void con_hex(const char *label, uint64_t v);
/* label, then "a=xxxxxxxx b=xxxxxxxx" style pairs of 32-bit values */
void con_hex2(const char *label, const char *a, uint32_t va, const char *b, uint32_t vb);
