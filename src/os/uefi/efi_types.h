/* SPDX-License-Identifier: GPL-3.0-or-later */
#ifndef MINI_EFI_TYPES_H
#define MINI_EFI_TYPES_H

#include <stdint.h>

#define EFIAPI __attribute__((ms_abi))

typedef void     *EFI_HANDLE;
typedef uint64_t  EFI_STATUS;
typedef uint16_t  CHAR16;

/* ---- необходимые структуры ---- */
typedef struct {
    EFI_STATUS (EFIAPI *OutputString)(void *This, const CHAR16 *String);
} SIMPLE_TEXT_OUTPUT_INTERFACE;

typedef struct {
    char                           _pad[52];      /* заголовки, неиспользуемые */
    SIMPLE_TEXT_OUTPUT_INTERFACE  *ConOut;
} EFI_SYSTEM_TABLE;

#endif /* MINI_EFI_TYPES_H */
