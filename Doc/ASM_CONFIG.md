# ASM_CONFIG.md

## 1. Objetivo

Profundizar en la configuración y edición del archivo ensamblador `main.s`, entender las directivas clave y organizar el código ASM para la práctica de Procesadores.

## 2. Estructura del archivo ASM

- **Sección de texto**: define el código ejecutable.
- **Directivas de sintaxis**: indicar al compilador el modo Thumb y la sintaxis unificada.
- **Símbolos globales**: exponer etiquetas para enlazar desde C.
- **Constantes**: usar `.equ` para definir direcciones o parámetros.

Ejemplo básico de encabezado en `Src/main.s`:
```assembly
    .section .text            @ Código ejecutable
    .syntax unified           @ Sintaxis unificada ARM/Thumb
    .thumb                    @ Genera instrucciones Thumb (16/32 bits)
    .global main              @ Hacer visible la etiqueta main

    .equ MEM_LOC, 0x20000010  @ Dirección fija en SRAM para datos
    .equ ID, 0x813017         @ Valor a decrementar
    .equ DATE, 0x1017         @ Fecha de nacimiento
```  

## 3. Definición de la función `main`

Implementa en ASM la rutina principal que inicializa datos y llama a una subrutina:

```assembly
main:
    @ Inicializar registros
    movw    r0, #:lower16:MEM_LOC    @ Parte baja de la dirección
    movt    r0, #:upper16:MEM_LOC    @ Parte alta (ahora R0 = MEM_LOC)
    ldr     r1, =ID                  @ Cargar ID en r1
    str     r1, [r0]                 @ Almacena valor en MEM_LOC

    @ Llamar a la subrutina decrement
    bl      decrement

    @ Bucle infinito de final
loop:
    b       loop
```  

## 4. Implementación de la rutina `decrement`

Esta subrutina decrementa el valor en memoria hasta que sea ≤ 0 y cuenta iteraciones:

```assembly
decrement:
    @ r0 apunta a MEM_LOC, obtener valor
    ldr     r1, [r0]           @ Cargar valor de MEM_LOC en r1
    ldr     r2, =DATE          @ Cargar fecha en r2
    subs    r1, r1, r2         @ r1 = r1 - r2
    str     r1, [r0]           @ guarda r1 en MEM_LOC
    cmp     r1, #0             @ ¿ r1 ≤ 0?
    ble     exit_decrement     @ Si sí, salir

    @ Iteración válida
    add     r7, r7, #1         @ Contador en r7
    b       decrement          @ Repetir

exit_decrement:
    @ Retorno a main
    bx      lr
```  

> **Nota:** `bx lr` retorna al link register hacia la función que llamó.

## 5. Implementación de `main.s`

Asegúrate de no copiar codigo repetido e incluir los encabezados y funciones necesarias.

El archivo de `main.s` deberia lucir de la siguiente manera:

```assembly
    .section .text            @ Código ejecutable
    .syntax unified           @ Sintaxis unificada ARM/Thumb
    .thumb                    @ Genera instrucciones Thumb (16/32 bits)
    .global main              @ Hacer visible la etiqueta main

    .equ MEM_LOC, 0x20000010  @ Dirección fija en SRAM para datos
    .equ ID, 0x813017         @ Valor a decrementar
    .equ DATE, 0x1017         @ Fecha de nacimiento

main:
    @ Inicializar registros
    movw    r0, #:lower16:MEM_LOC    @ Parte baja de la dirección
    movt    r0, #:upper16:MEM_LOC    @ Parte alta (ahora R0 = MEM_LOC)
    ldr     r1, =ID                  @ Cargar ID en r1
    str     r1, [r0]                 @ Almacena valor en MEM_LOC

    @ Llamar a la subrutina decrement
    bl      decrement

    @ Bucle infinito de final
loop:
    b       loop


decrement:
    @ r0 apunta a MEM_LOC, obtener valor
    ldr     r1, [r0]           @ Cargar valor de MEM_LOC en r1
    ldr     r2, =DATE          @ Cargar fecha en r2
    subs    r1, r1, r2         @ r1 = r1 - r2
    str     r1, [r0]           @ guarda r1 en MEM_LOC
    cmp     r1, #0             @ ¿ r1 ≤ 0?
    ble     exit_decrement     @ Si sí, salir

    @ Iteración válida
    add     r7, r7, #1         @ Contador en r7
    b       decrement          @ Repetir

exit_decrement:
    @ Retorno a main
    bx      lr

```


## 6. Depuración en VS Code

1. Coloca breakpoints en `main` o `decrement` para inspeccionar registros.
2. Inicia la depuración y observa cómo avanza la ejecución línea a línea y como cambia el valor de:
    - Los registros del procesador.
    - La memoria del programa.
    - El contador del programa.

---

Continúa con [CODE_EXPLANATION.md](CODE_EXPLANATION.md) para documentar cada instrucción y su efecto en registros/memoria.

