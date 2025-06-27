# GNU Makefile – цель "host-linux" собирает статически линкованный CLI-бинарь
# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2025

# ───── параметры, вынесенные в config/… ────────────────────────────────────────
PROJECT_ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
include config/toolchain.mk   # CC, NASM, …
include config/arch.mk        # ARCH, NASM_FMT, CFLAGS_ARCH_…
include config/paths.mk       # (пусто, только для расширений)

# ───── каталог сборки и цели ──────────────────────────────────────────────────
BUILD_DIR := $(PROJECT_ROOT)/build/host-linux
VM_OBJS   := $(BUILD_DIR)/core.o
HOST_OBJS := $(BUILD_DIR)/vm_host.o
TARGET    := $(BUILD_DIR)/vm_cli

.PHONY: all host-linux clean
all: host-linux



# ──  цель host-linux-sdl  ─────────────────────────────

# SDL-бинарь делаем динамическим: статически линковать SDL2 тяжело
# (зависимости freetype, pthread и т.п.).
# Для NASM ничего не меняется — сборка тех же объектников, но в другой каталог.
# Если у вас установлен только sdl2-config, замените в Makefile:
# SDL_CFLAGS := $(shell sdl2-config --cflags)
# SDL_LDLIBS := $(shell sdl2-config --libs)

# Каталоги/файлы
BUILD_DIR_SDL := $(PROJECT_ROOT)/build/host-linux-sdl
VM_OBJS_SDL   := $(BUILD_DIR_SDL)/core.o
HOST_OBJS_SDL := $(BUILD_DIR_SDL)/vm_host_sdl.o
TARGET_SDL    := $(BUILD_DIR_SDL)/vm_sdl

# Флаги для SDL (pkg-config предпочтительней, но sdl2-config тоже подойдёт)
SDL_CFLAGS  := $(shell pkg-config --cflags sdl2)
SDL_LDLIBS  := $(shell pkg-config --libs   sdl2)

.PHONY: host-linux-sdl
host-linux-sdl: $(TARGET_SDL)
	@echo "👉  SDL-бинарь готов: $@ → $(TARGET_SDL)"

$(BUILD_DIR_SDL):
	@mkdir -p $@

# ── NASM та же самая конфигурация — переиспользуем $(NASMFLAGS)
$(BUILD_DIR_SDL)/core.o: src/common/vm/core.asm | $(BUILD_DIR_SDL)
	$(NASM) $(NASMFLAGS) -o $@ $<

# ── C-обёртка с добавлением SDL-флагов
$(BUILD_DIR_SDL)/vm_host_sdl.o: src/host/posix/vm_host_sdl.c | $(BUILD_DIR_SDL)
	$(CC) $(CFLAGS) $(SDL_CFLAGS) -c $< -o $@

# ── линковка: **не** используем -static — обычный динамический бинарь
$(TARGET_SDL): $(VM_OBJS_SDL) $(HOST_OBJS_SDL)
	$(CC) $^ $(SDL_LDLIBS) -o $@



# ──  цель host-linux  ─────────────────────────────

host-linux: $(TARGET)
	@echo "👉  Бинарь готов: $@ → $(TARGET)"


# ──  цель os-bios-x86  ────────────────────────────

OS_BIOS_BUILD := $(PROJECT_ROOT)/build/os-bios-x86
OS_BOOT_BIN   := $(OS_BIOS_BUILD)/boot.bin
OS_IMG        := $(OS_BIOS_BUILD)/vm.img

.PHONY: os-bios-x86 os-bios-x86-run
os-bios-x86: $(OS_IMG)
	@echo "👉  BIOS-образ готов: $(OS_IMG)"

# сборка и запуск сразу в qemu (удобно для теста)
os-bios-x86-run: os-bios-x86
	$(QEMU) -drive format=raw,file=$(OS_IMG) -nographic

$(OS_BIOS_BUILD):
	@mkdir -p $@

$(OS_BOOT_BIN): src/os/boot/bios/boot.asm | $(OS_BIOS_BUILD)
	$(NASM) $(NASMFLAGS) -f bin -DBIOS -DX86_16 -o $@ $<

# итоговый img = просто бут-сектор (один сектор 512 Б)
$(OS_IMG): $(OS_BOOT_BIN)
	cp $< $@


#  ──  цель os-uefi-x86_64  ─────────────────────────────

UEFI_BUILD   := $(PROJECT_ROOT)/build/os-uefi-x86_64
UEFI_ELF     := $(UEFI_BUILD)/vm_x64.elf
UEFI_EFI     := $(UEFI_BUILD)/vm_x64.efi

VM_OBJS_UEFI   := $(UEFI_BUILD)/core.o
HOST_OBJS_UEFI := $(UEFI_BUILD)/vm_uefi.o

# CFLAGS/LDFLAGS для freestanding-UEFI
CFLAGS_UEFI  := -ffreestanding -fshort-wchar -mno-red-zone -Wall -Wextra \
                -fms-extensions -DEFI_APP -Isrc   # +fms-ext

LDFLAGS_UEFI := -nostdlib -T src/os/uefi/elf_x64.ld -e efi_main

.PHONY: os-uefi-x86_64
os-uefi-x86_64: $(UEFI_EFI)
	@echo "👉  UEFI-приложение готово: $(UEFI_EFI)"

$(UEFI_BUILD):
	@mkdir -p $@

# --- NASM ядро ---
$(UEFI_BUILD)/core.o: src/common/vm/core.asm | $(UEFI_BUILD)
	$(NASM) $(NASMFLAGS) -f elf64 -DOS -DUEFI -o $@ $<

# --- C обёртка ---
$(UEFI_BUILD)/vm_uefi.o: src/os/uefi/vm_uefi.c | $(UEFI_BUILD)
	$(CC) $(CFLAGS_UEFI) -c $< -o $@

# --- линковка ELF ---
$(UEFI_ELF): $(VM_OBJS_UEFI) $(HOST_OBJS_UEFI)
	$(LD) $(LDFLAGS_UEFI) $^ -o $@

# --- конвертация в PE/COFF (EFI) ---
$(UEFI_EFI): $(UEFI_ELF)
	@[ -n "$(OBJCOPY)" ] || { echo "❌  objcopy/llvm-objcopy not found"; exit 1; }
	$(OBJCOPY) -O efi-app-x86_64 $< $@


.PHONY: os-uefi-x86_64-run

os-uefi-x86_64-run: os-uefi-x86_64
	@[ -n "$(OVMF_CODE)" ] || { echo "❌ OVMF firmware not found"; exit 1; }
	@[ -n "$(MKISOFS)" ]   || { echo "❌ mkisofs/xorriso/genisoimage not found"; exit 1; }
	@echo "== готовим ISO"
	@echo "-- Создаем папку для BOOT"
	@mkdir -p $(UEFI_BUILD)/iso/EFI/BOOT
	@echo "-- Копируем UEFI_EFI"
	cp  $(UEFI_EFI)  $(UEFI_BUILD)/iso/EFI/BOOT/BOOTX64.EFI
	@echo "-- startup.nsh"
	echo "EFI\\BOOT\\BOOTX64.EFI" > $(UEFI_BUILD)/iso/startup.nsh
	@echo "-- geniso"
	"$(MKISOFS)" $(ISOFLAGS) \
	    -o $(UEFI_BUILD)/vm_x64.iso \
	    $(UEFI_BUILD)/iso/
	@echo "== запуск"
	@cp "$(OVMF_VARS)" $(UEFI_BUILD)/OVMF_VARS_RW.fd 2>/dev/null || \
	  { echo "⚠  cannot copy OVMF_VARS – using blank vars"; \
	    cp "$(OVMF_CODE)" $(UEFI_BUILD)/OVMF_VARS_RW.fd; }
	@chmod u+rw $(UEFI_BUILD)/OVMF_VARS_RW.fd
	$(QEMU) \
	  -drive if=pflash,format=raw,unit=0,readonly=on,file=$(OVMF_CODE) \
	  -drive if=pflash,format=raw,unit=1,file=$(UEFI_BUILD)/OVMF_VARS_RW.fd \
      -boot order=c \
	  -serial mon:stdio -display none

# ───── правила компиляции ─────────────────────────────────────────────────────
$(BUILD_DIR):
	@mkdir -p $@

NASMFLAGS := -f $(NASM_FMT) -Isrc -DHOST -DARCH_$(ARCH)

$(BUILD_DIR)/core.o: src/common/vm/core.asm | $(BUILD_DIR)
	$(NASM) $(NASMFLAGS) -o $@ $<

CFLAGS += -O2 -pipe -std=c11 -Wall -Wextra $(CFLAGS_ARCH_$(ARCH))

$(BUILD_DIR)/vm_host.o: src/host/posix/vm_host.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(VM_OBJS) $(HOST_OBJS)
	$(CC) -static $^ -o $@

clean:
	rm -rf build
