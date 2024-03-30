; Реализация сервисной процедуры svc_puts через BIOS int 10h
; ──────────────────────────────────────────────────────────────
BITS 16
global  svc_puts

svc_puts:                   ; DS:SI -> zero-terminated ASCII
.next:
        lodsb
        or      al, al
        jz      .done
        mov     ah, 0x0E    ; Teletype output
        mov     bh, 0       ; страница
        mov     bl, 0x07    ; атрибут «серый на чёрном»
        int     0x10
        jmp     .next
.done:
        ret
