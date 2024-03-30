; Одноступенчатый бут-сектор (512 Б) + VM + BIOS-сервисы
; ──────────────────────────────────────────────────────────────
BITS 16
ORG  0x7C00

start:
        cli
        xor     ax, ax
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        mov     sp, 0x7C00
        sti

        call    vm_entry    ; управление получает виртуальная машина

hang:   jmp     hang

; --- подключаем ядро VM и сервисный слой ---------------------
%include "src/common/vm/core16.asm"
%include "src/os/services/bios/puts.asm"

; --- подпись MBR ---------------------------------------------
times 510-($-$$) db 0
dw 0xAA55
