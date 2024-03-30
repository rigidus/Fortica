; Minimal VM stub – только вывод «Hello World»
; SPDX-License-Identifier: GPL-3.0-or-later

        BITS 64
        default rel

; ─── внешние символы, которые предоставляет слой услуг host (C) ───────────────
        extern  svc_puts         ; void svc_puts(const char *z);

; ─── экспортируемая точка входа виртуальной машины ───────────────────────────
        global  vm_entry         ; void vm_entry(void);

section .rodata
hello_msg:     db  "Hello World", 10, 0

section .text
; ---------------------------------------------------------------------------
; vm_entry – минимальный «ядро» VM: просто вызов svc_puts и RET
; ---------------------------------------------------------------------------
vm_entry:
        push    rbp
        mov     rbp, rsp

        lea     rdi,  [rel hello_msg]   ; 1-й аргумент → RDI
        call    svc_puts

        xor     eax, eax               ; return 0
        pop     rbp
        ret
