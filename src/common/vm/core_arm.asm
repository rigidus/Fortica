; Мини-ядро VM для Cortex-M0+ (Thumb-1)
; SPDX-License-Identifier: GPL-3.0-or-later
%define THUMB
        BITS 16
        THUMB

        global  vm_entry
        extern  svc_puts

section .rodata
hello:  db "Hello World", 10, 0

section .text
vm_entry:
        push    {lr}
        ldr     r0, =hello     ; 1-й аргумент (r0)
        bl      svc_puts
        pop     {pc}
