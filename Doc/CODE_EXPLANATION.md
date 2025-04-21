# CODE_EXPLANATION.md

## 1. Propósito de este documento

Este archivo describe en detalle cada instrucción del ejemplo en ensamblador (`main.s`). El objetivo es que entiendas cómo se traduce el flujo de tu programa a nivel de registros, memoria y control de flujo en el ARM Cortex‑M4.

---

## 2. Encabezados y directivas

```assembly
.section .text            @ Código ejecutable
.syntax unified           @ Sintaxis unificada ARM/Thumb
.thumb                    @ Genera instrucciones Thumb (16/32 bits)
.global main              @ Hacer visible la etiqueta main

.equ MEM_LOC, 0x20000010  @ Dirección fija en SRAM para datos
.equ ID, 0x813017         @ Valor a decrementar
.equ DATE, 0x1017         @ Fecha de nacimiento
```

- **.section .text**: Ubica el ensamblador en la región de código ejecutable.
- **.syntax unified**: Sintaxis única para instrucciones ARM y Thumb.
- **.thumb**: Indica instrucciones Thumb.
- **.global main**: Expone `main` al enlazador para el startup.
- **.equ**: Define constantes simbólicas para memoria y valores.

---

## 3. Función `main`

```assembly
main:
    movw    r0, #:lower16:MEM_LOC    @ Parte baja de la dirección
    movt    r0, #:upper16:MEM_LOC    @ Parte alta (ahora R0 = MEM_LOC)
    ldr     r1, =ID                  @ Cargar ID en R1
    str     r1, [r0]                 @ Almacena valor en MEM_LOC
    bl      decrement                @ Llamar a la subrutina decrement
loop:
    b       loop                     @ Bucle infinito de final
```

| Instrucción      | Registros/Memoria                   | Comentario                                           |
|------------------|-------------------------------------|------------------------------------------------------|
| movw r0,...      | R0[15:0] = lower16(MEM_LOC)         | Carga los 16 bits bajos de la dirección MEM_LOC.     |
| movt r0,...      | R0[31:16] = upper16(MEM_LOC)        | Completa la dirección de 32 bits en R0.              |
| ldr r1, =ID      | R1 = 0x813017                       | Carga el valor ID mediante pseudo-instrucción.       |
| str r1, [r0]     | Mem[MEM_LOC] = 0x813017             | Guarda el valor ID en la SRAM.                       |
| bl decrement     | LR = PC+4; PC = &decrement          | Salta a `decrement`, guardando la dirección de retorno. |
| loop: b loop     | PC = loop                           | Bucle infinito tras retornar de `decrement`.         |

---

## 4. Subrutina `decrement`

```assembly
decrement:
    ldr     r1, [r0]           @ Cargar valor de MEM_LOC en R1
    ldr     r2, =DATE          @ Cargar fecha en R2
    subs    r1, r1, r2         @ r1 = r1 - r2
    str     r1, [r0]           @ Guarda r1 en MEM_LOC
    cmp     r1, #0             @ ¿r1 ≤ 0?
    ble     exit_decrement     @ Si sí, salir
    add     r7, r7, #1         @ Iteración válida: R7++
    b       decrement          @ Repetir
exit_decrement:
    bx      lr                 @ Retorno a `main`
```

| Instrucción       | Registros/Memoria                 | Comentario                                           |
|-------------------|-----------------------------------|------------------------------------------------------|
| ldr r1, [r0]      | R1 = Mem[MEM_LOC]                 | Carga el valor actual de memoria en R1.              |
| ldr r2, =DATE     | R2 = 0x1017                       | Carga la constante DATE en R2.                       |
| subs r1, r1, r2   | R1 = R1 - R2; flags Z y N         | Resta DATE al valor en memoria y actualiza flags.    |
| str r1, [r0]      | Mem[MEM_LOC] = R1                 | Escribe el resultado de vuelta en memoria.           |
| cmp r1, #0        | Ajusta flags Z y N                | Compara con cero para evaluar condición de salida.   |
| ble exit_decrement| PC = exit_decrement               | Salta a `exit_decrement` si ≤ 0.                     |
| add r7, r7, #1    | R7 = R7 + 1                       | Incrementa contador de iteraciones en R7.            |
| b decrement       | PC = decrement                    | Repite la rutina hasta la condición de salida.       |
| bx lr             | PC = LR                           | Retorna a la llamada en `main`.                      |

---

## 5. Visualización de flujo

1. **main** inicializa memoria y llama a `decrement`.
2. **decrement** ejecuta un bucle de resta hasta llegar a cero o negativo.
3. Cada iteración válida incrementa **R7**.
4. Al finalizar, retorna a **main**, que entra en un bucle infinito.

Con esta explicación, deberías comprender cómo funciona el código a nivel de ISA y registros en la placa NUCLEO‑L476RG.

