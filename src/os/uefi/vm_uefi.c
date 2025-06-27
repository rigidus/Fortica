/* SPDX-License-Identifier: GPL-3.0-or-later */
#include "efi_types.h"

/* точка входа NASM-ядра */
void vm_entry(void);

/* ---- глобальный указатель на SystemTable ---- */
static EFI_SYSTEM_TABLE *gST;

/* ---- сервис, который вызывает NASM-VM ---- */
void svc_puts(const char *s)
{
    while (*s) {
        CHAR16 buf[2] = { (CHAR16)(uint8_t)*s++, 0 };
        gST->ConOut->OutputString(gST->ConOut, buf);
    }
}

/* ---- EFI entrypoint ---- */
EFI_STATUS EFIAPI efi_main(EFI_HANDLE image, EFI_SYSTEM_TABLE *system)
{
    (void)image;
    gST = system;

    vm_entry();             /* передаём управление виртуальной машине */
    return 0;
}
