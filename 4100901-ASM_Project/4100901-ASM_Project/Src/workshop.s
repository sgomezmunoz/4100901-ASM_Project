// --- Ejemplo de parpadeo de LED LD2 en STM32F476RGTx 
.section .text
    .syntax unified
    .thumb

    .global main
    .global init_led
    .global init_button
    .global init_systick
    .global SysTick_Handler

    .equ RCC_BASE,       0x40021000
    .equ RCC_AHB2ENR,    RCC_BASE + 0x4C
    .equ GPIOA_BASE,     0x48000000
    .equ GPIOA_MODER,    GPIOA_BASE + 0x00
    .equ GPIOA_ODR,      GPIOA_BASE + 0x14
    .equ LD2_PIN,        5

    .equ GPIOC_BASE,     0x48000800
    .equ GPIOC_MODER,    GPIOC_BASE + 0x00
    .equ GPIOC_IDR,      GPIOC_BASE + 0x10
    .equ BUTTON_PIN,     13

    .equ SYST_CSR,       0xE000E010
    .equ SYST_RVR,       0xE000E014
    .equ SYST_CVR,       0xE000E018
    .equ HSI_FREQ,       4000000

    .data
led_timer:
    .word 0

    .text
main:
    bl init_led
    bl init_button
    bl init_systick
loop:
    wfi
    b loop

init_led:
    movw r0, #:lower16:RCC_AHB2ENR
    movt r0, #:upper16:RCC_AHB2ENR
    ldr  r1, [r0]
    orr  r1, r1, #(1 << 0)
    str  r1, [r0]

    movw r0, #:lower16:GPIOA_MODER
    movt r0, #:upper16:GPIOA_MODER
    ldr  r1, [r0]
    bic  r1, r1, #(0b11 << (LD2_PIN * 2))
    orr  r1, r1, #(0b01 << (LD2_PIN * 2))
    str  r1, [r0]
    bx lr

init_button:
    movw r0, #:lower16:RCC_AHB2ENR
    movt r0, #:upper16:RCC_AHB2ENR
    ldr  r1, [r0]
    orr  r1, r1, #(1 << 2)
    str  r1, [r0]

    movw r0, #:lower16:GPIOC_MODER
    movt r0, #:upper16:GPIOC_MODER
    ldr  r1, [r0]
    bic  r1, r1, #(0b11 << (BUTTON_PIN * 2))
    str  r1, [r0]
    bx lr

init_systick:
    movw r0, #:lower16:SYST_RVR
    movt r0, #:upper16:SYST_RVR
    movw r1, #:lower16:HSI_FREQ
    movt r1, #:upper16:HSI_FREQ
    subs r1, r1, #1
    str  r1, [r0]

    movw r0, #:lower16:SYST_CSR
    movt r0, #:upper16:SYST_CSR
    movs r1, #(1 << 0)|(1 << 1)|(1 << 2)
    str  r1, [r0]
    bx lr

    .thumb_func
SysTick_Handler:
    movw r0, #:lower16:GPIOC_IDR
    movt r0, #:upper16:GPIOC_IDR
    ldr  r1, [r0]
    lsr  r1, r1, #BUTTON_PIN
    ands r1, r1, #1
    cmp  r1, #0
    bne check_timer

    ldr  r2, =led_timer
    movs r3, #3
    str  r3, [r2]

check_timer:
    ldr  r2, =led_timer
    ldr  r3, [r2]
    cmp  r3, #0
    beq apagar_led

    subs r3, r3, #1
    str  r3, [r2]

    movw r0, #:lower16:GPIOA_ODR
    movt r0, #:upper16:GPIOA_ODR
    ldr  r1, [r0]
    orr  r1, r1, #(1 << LD2_PIN)
    str  r1, [r0]
    bx lr

apagar_led:
    movw r0, #:lower16:GPIOA_ODR
    movt r0, #:upper16:GPIOA_ODR
    ldr  r1, [r0]
    bic  r1, r1, #(1 << LD2_PIN)
    str  r1, [r0]
    bx lr
