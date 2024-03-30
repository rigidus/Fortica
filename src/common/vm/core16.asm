; Минимальное «ядро» VM для real-mode (16-бит)
; ──────────────────────────────────────────────────────────────
BITS 16
global  vm_entry           ; точка входа, вызывается из бут-сектора

vm_entry:
        push    si
        mov     si, hello_msg
        call    svc_puts    ; BIOS-реализация печати
        pop     si
        ret

hello_msg  db "Hello World", 0
