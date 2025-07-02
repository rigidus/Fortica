/* SPDX-License-Identifier: GPL-3.0-or-later */
.syntax unified
.cpu cortex-m0plus
.thumb

/* ───── векторная таблица ───────────────────────────────────────────── */
.section .vectors, "a", %progbits
    .word   _estack         /* 0  Initial SP */
    .word   Reset_Handler   /* 1  Reset      */

    .space  (46*4)          /* остальные прерывания заглушены */

/* ───── коды ─────────────────────────────────────────────────────────── */
.text
.thumb_func
.global Reset_Handler      /* ← экспорт для линкера */
Reset_Handler:
    ldr   r0, =_sbss        /* r0 = dst */
    ldr   r1, =_ebss        /* r1 = limit */
    movs  r2, #0            /* r2 = 0      */
bss_loop:
    cmp   r0, r1
    bge   bss_done
    str   r2, [r0]          /* *r0 = 0            */
    adds  r0, #4            /* r0 += 4            */
    b     bss_loop
bss_done:

/* символ стека */
.section .stack, "aw", %progbits
    .space 2048
_estack:
