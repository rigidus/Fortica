ORG 0x7C00
BITS 16
start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov si, msg
.print:
    lodsb
    cmp al, 0
    je  load_kernel
    mov ah, 0x0E
    int 0x10
    jmp .print
load_kernel:
    mov bx, 0x7E00
    mov dh, 1          ; 1 сектор
    mov dl, [BOOT_DRIVE]
    mov ah, 0x02
    xor cx, cx
    add cx, 2          ; LBA 1
    int 0x13
    jmp 0x0000:0x7E00  ; в 32-битный код

msg db "VM",0
BOOT_DRIVE db 0
TIMES 510-($-$$) db 0
DW 0xAA55
