/* SPDX-License-Identifier: GPL-3.0-only */
#include <stdio.h>

/* Внешняя функция из NASM-модуля */
void vm_entry(void);

/* ─── сервисы, которые видит ассемблерная VM ─────────────────────────────── */
void svc_puts(const char *s)
{
    fputs(s, stdout);          /* можно заменить на printf/SDL и т.д. */
}

/* ─── точка входа host-приложения ────────────────────────────────────────── */
int main(int argc, char **argv)
{
    (void)argc; (void)argv;
    vm_entry();                /* передаём контроль виртуальной машине */
    return 0;
}
