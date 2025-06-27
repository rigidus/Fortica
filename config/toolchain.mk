# SPDX-License-Identifier: GPL-3.0-only
# Имена инструментов можно переопределить переменными окружения.
CC   ?= gcc
NASM ?= nasm
AR   ?= ar
# ── используем «чистый» линкер, а не gcc-драйвер ──────────────────────────
# это гарантирует, что флаги -T/-e уйдут именно ld и не подтянутся системные
# CRT-старты
+LD      ?= ld
+OBJCOPY ?= objcopy


# ── arm-none-eabi кросс-компилятор (можно переопределить) ──────────────
ARM_PREFIX ?= arm-none-eabi-
CC_ARM     ?= $(ARM_PREFIX)gcc
LD_ARM     ?= $(ARM_PREFIX)ld
OBJCOPY_ARM?= $(ARM_PREFIX)objcopy
