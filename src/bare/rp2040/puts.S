/* src/bare/rp2040/puts.S  –  UART-0 “Hello World” */
/* SPDX-License-Identifier: GPL-3.0-or-later */
.syntax unified
.cpu cortex-m0plus
.thumb

.global  svc_puts

.equ UART0_BASE,  0x40034000
.equ UART0_DR,    UART0_BASE + 0x00
.equ UART0_FR,    UART0_BASE + 0x18
.equ TXFF_BIT,    5            /* FIFO full */

svc_puts:
    push {r1,r2,r3,lr}

loop_char:                      /* r0 = ptr */
    ldrb r1, [r0]               /* ch = *s   */
    cmp  r1, #0
    beq  done

/* wait while TX FIFO full */
wait_tx:
    ldr   r2, =UART0_FR
    ldrb  r3, [r2]              /* r3 = FR   */
    lsrs  r3, r3, #TXFF_BIT     /* TXFF -> C */
    bcs   wait_tx               /* if 1 → full, stay */

    ldr   r2, =UART0_DR
    strb  r1, [r2]              /* send char */
    adds  r0, #1
    b     loop_char

done:
    pop  {r1,r2,r3,pc}
