/* SPDX-License-Identifier: GPL-3.0-or-later */
ENTRY(efi_main)
SECTIONS
{
  . = 0;
  .text : { *(.text*) }
  .data : { *(.data*) }
  .rodata : { *(.rodata*) }
  .bss :  { *(.bss*) *(COMMON) }
}
