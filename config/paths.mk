# SPDX-License-Identifier: GPL-3.0-only
# Зарезервировано для пользовательских путей (SDL2, llvm-objcopy и т.д.)

# optional user-specific overrides
#NASM      = /usr/bin/nasm
#CC        = /usr/bin/gcc
#LD        = /usr/bin/ld
#OBJCOPY   = /usr/bin/objcopy
#QEMU_I386 = /usr/bin/qemu-system-i386

# ─────────── автоматический поиск QEMU ────────────
QEMU ?= $(shell command -v qemu-system-x86_64 2>/dev/null || \
                command -v qemu-system-i386   2>/dev/null || \
                echo qemu-system-x86_64)

# ─────────── автоматический поиск прошивки OVMF ───
OVMF_CODE ?= $(shell for p in \
    /usr/share/OVMF/OVMF_CODE.fd \
    /usr/share/ovmf/OVMF_CODE.fd \
    /usr/share/edk2/ovmf/OVMF_CODE.fd \
    /usr/share/qemu/OVMF_CODE.fd \
    /usr/share/qemu/OVMF.fd ; do \
        [ -f $$p ] && echo $$p && break ; \
    done )

# если пользователь не указал, берём рядом с найденным OVMF_CODE
OVMF_VARS ?= $(patsubst %CODE.fd,%VARS.fd,$(OVMF_CODE))


# ────────── выбираем утилиту для ISO ────────────────────────────────────────
# 1) xorriso   2) «настоящее» mkisofs (cdrtools)   3) genisoimage (cdrkit)
MKISOFS ?= $(shell \
        command -v xorriso      2>/dev/null || \
        command -v mkisofs      2>/dev/null || \
        command -v genisoimage  2>/dev/null )

# genisoimage часто маскируется именем mkisofs → проверяем вывод --version
ISO_TOOL := $(shell \
        $(MKISOFS) --version 2>&1 | awk '{print tolower($$1); exit}')

# базовые Joliet / RockRidge
ISOFLAGS_BASE := -J -R

ifeq ($(ISO_TOOL),xorriso)                 # xorriso + GPT-hybrid
ISOFLAGS := -as mkisofs $(ISOFLAGS_BASE) -iso-level 3 \
            -eltorito-alt-boot -e EFI/BOOT/BOOTX64.EFI \
            -no-emul-boot -isohybrid-gpt-basdat

else ifeq ($(ISO_TOOL),mkisofs)            # cdrtools mkisofs
ISOFLAGS := $(ISOFLAGS_BASE) -f \
            -eltorito-alt-boot -e EFI/BOOT/BOOTX64.EFI \
            -no-emul-boot

else                                        # genisoimage (cdrkit) – NO isohybrid
ISOFLAGS := $(ISOFLAGS_BASE) -f \
            -eltorito-alt-boot -e EFI/BOOT/BOOTX64.EFI \
            -no-emul-boot
endif


# ─────────── поиск objcopy (GNU или LLVM) ────────────────
OBJCOPY ?= $(shell \
        command -v objcopy       2>/dev/null || \
        command -v llvm-objcopy  2>/dev/null )

export OBJCOPY          # чтобы переменная была видна в рекурсивных вызовах

$(info OBJCOPY path: $(OBJCOPY))



# при необходимости покажем, что нашли
$(info QEMU path: $(QEMU))
$(info OVMF_CODE path: $(OVMF_CODE))
$(info OVMF_VARS path: $(OVMF_VARS))
$(info MKISOFS path: $(MKISOFS))
$(info ISO tool flags: $(ISOFLAGS))
$(info OBJCOPY path: $(OBJCOPY))
