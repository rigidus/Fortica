%include "macros/platform.inc"

global vm_entry

section .text
vm_entry:
    ; rdi/edi — адрес нуль-терминированной строки
    push    rbp
    SVC     puts
    call    svc_puts
    pop     rbp
    ret
