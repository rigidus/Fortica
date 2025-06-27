/* SPDX-License-Identifier: GPL-3.0-or-later */
MEMORY
{
  FLASH (rx) : ORIGIN = 0x10000000, LENGTH = 2M
  RAM   (rwx): ORIGIN = 0x20000000, LENGTH = 256K
}

ENTRY(Reset_Handler)

SECTIONS
{
  .text : ALIGN(4) {
        KEEP(*(.vectors))
        *(.text*) *(.rodata*)
  } > FLASH

  .bss (NOLOAD) : ALIGN(4) { *(.bss*) *(COMMON) } > RAM
  .stack (NOLOAD) : ALIGN(8) { *(.stack*) } > RAM
}
