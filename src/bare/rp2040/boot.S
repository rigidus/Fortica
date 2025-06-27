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
Reset_Handler:
    ldr   r0, =_sbss
    ldr   r1, =_ebss
    movs  r2, #0
0:  cmp   r0, r1
    itt   lt
    strlt r2, [r0], #4
    bl    vm_entry
1:  b     1b                 /* loop forever */

/* символ стека */
.section .stack, "aw", %progbits
    .space 2048
_estack:
