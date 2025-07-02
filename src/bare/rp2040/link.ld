/* SPDX-License-Identifier: GPL-3.0-or-later */

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x10000000, LENGTH = 2M
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 256K
}

ENTRY(Reset_Handler)

SECTIONS
{
    /* ---- код + константы во Flash ------------------------------------ */
    .text : ALIGN(4)
    {
        KEEP(*(.vectors))        /* таблица прерываний                */
        *(.text*) *(.rodata*)
    } > FLASH

    /* ---- непроиниц. данные в RAM ------------------------------------- */
    .bss (NOLOAD) : ALIGN(4)
    {
        _sbss = .;               /* ← начало BSS (для boot.S) */
        *(.bss*) *(COMMON)
        _ebss = .;               /* ← конец   BSS            */
    } > RAM

    /* ---- стек (просто резервируем) ----------------------------------- */
    .stack (NOLOAD) : ALIGN(8)
    {
        . = . + 2048;            /* 2 КБ */
    } > RAM
}
