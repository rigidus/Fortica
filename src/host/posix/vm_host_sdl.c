/* SPDX-License-Identifier: GPL-3.0-only */
/* Хост-обёртка для SDL-варианта VM */

#include <SDL2/SDL.h>
#include <stdio.h>

void vm_entry(void);               /* точка входа из NASM */

/* ── сервис, видимый для ядра VM ────────────────────────────────────────── */
void svc_puts(const char *s)
{
    /* Выводим строку в простейший MessageBox.
       (Для реального терминала позже можно будет заменить на рисование текстуры) */
    SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_INFORMATION,
                             "VM says:", s, NULL);
}

/* ── точка входа SDL-хоста ──────────────────────────────────────────────── */
int main(int argc, char **argv)
{
    (void)argc; (void)argv;

    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        fprintf(stderr, "SDL init failed: %s\n", SDL_GetError());
        return 1;
    }

    vm_entry();        /* передаём управление виртуальной машине */

    SDL_Quit();
    return 0;
}
