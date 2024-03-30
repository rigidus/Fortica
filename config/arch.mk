# SPDX-License-Identifier: GPL-3.0-only
# По-умолчанию собираем под x86-64 хост. 32-бит можно включить, задав ARCH=i386.
ARCH ?= x86_64

# Формат объектника NASM
ifeq ($(ARCH),x86_64)
    NASM_FMT = elf64
    CFLAGS_ARCH_x86_64 = -m64
else ifeq ($(ARCH),x86_16)
    NASM_FMT = bin          # для object-rules она не используется
    CFLAGS_ARCH_x86_16 =
else ifeq ($(ARCH),i386)
    NASM_FMT = elf32
    CFLAGS_ARCH_i386   = -m32

else
    $(error Unsupported ARCH=$(ARCH) for host-linux)
endif
