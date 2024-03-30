;; %include "macros/arch_x86_32.inc"
;; global svc_puts
;; svc_puts:
;;     push    ebp
;;     mov     ebp, esp
;;     mov     esi, [ebp+8]   ; ptr
;; .loop:
;;     lodsb
;;     test    al, al
;;     jz      .done
;;     mov     ah, 0x0E
;;     mov     bh, 0
;;     mov     bl, 7
;;     int     0x10
;;     jmp     .loop
;; .done:
;;     pop     ebp
;;     ret


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
