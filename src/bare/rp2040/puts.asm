; svc_puts для RP2040 — простой вывод в UART0, 115200 8-N-1
; SPDX-License-Identifier: GPL-3.0-or-later
        BITS 16
        THUMB
        global  svc_puts

%define UART0_BASE  0x40034000
%define UART0_FR    (UART0_BASE + 0x18)
%define UART0_DR    (UART0_BASE + 0x00)
%define TXFF_BIT    5           ; Flag Register: TX FIFO full

section .text
svc_puts:
.loop:
        ldrb  r2, [r0]          ; r0 = *s
        cbz   r2, .done
.wait:
        ldr   r3, =UART0_FR
        ldrb  r3, [r3]
        tst   r3, #(1<<TXFF_BIT)
        bne   .wait
        ldr   r3, =UART0_DR
        strb  r2, [r3]
        add   r0, 1
        b     .loop
.done:
        bx    lr
