/* SPDX-License-Identifier: GPL-3.0-or-later */
.syntax unified
.cpu cortex-m0plus
.thumb

.global  vm_entry
.extern  svc_puts

.section .rodata
hello:
    .asciz "Hello World\n"

.text
.thumb_func
vm_entry:
    push {lr}
    ldr  r0, =hello      /* arg = &"Hello…" */
    bl   svc_puts
    pop  {pc}
