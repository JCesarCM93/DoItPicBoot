;===============================================================================
; File:        P26_example_led_half_reflect.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Movimiento de un LED desde RE7 hasta RE4 (centro) y retorno al
;              extremo. Usa rotaciones con máscaras para limitar el área de 
;              desplazamiento y crea un efecto de "rebote" en un grupo de LEDs.
;===============================================================================

    #include <xc.inc>                ; Librería principal de ensamblador PIC-AS

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF              ; Deshabilita conjunto extendido de instrucciones

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys       0x40       ; Rutina de inicialización del MCU
    #define UartRead      0x42       ; Rutina de lectura UART (no usada)
    #define UartWrite     0x44       ; Rutina de escritura UART (no usada)

    ; --- Bits de referencia para el movimiento ---
    #define BIT_ALTO_B4   0x10       ; Bit RE4 (centro del recorrido)
    #define BIT_ALTO_B7   0x80       ; Bit RE7 (extremo derecho)

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0000)
;===============================================================================
    ORG 0x0000
VAL_ALTO:       DS 1                ; Valor actual de posición de LED
DelayCounter:   DS 3                ; Contador de retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET Y PROGRAMA PRINCIPAL
;===============================================================================
    PSECT resetVec, space=2
    ORG 0x0800

;===============================================================================
; PROGRAMA PRINCIPAL
;===============================================================================
MAIN:
    CALL    InitSys
    CLRF    TRISE, A                ; Puerto E como salida
    CLRF    LATE, A                 ; Apaga todos los LEDs

    MOVLW   0x80                    ; Inicia con LED encendido en RE7
    MOVWF   VAL_ALTO, A

;===============================================================================
; BUCLE PRINCIPAL: Movimiento hacia el centro
;===============================================================================
LOOP:
    MOVF    VAL_ALTO, W, A
    MOVWF   LATE, A                 ; Actualiza LEDs
    CALL    DELAY                   ; Espera visible

    ; --- Corrimiento hacia el centro ---
    BCF     STATUS, 0, A
    MOVF    VAL_ALTO, W, A
    RRCF    WREG, W, A              ; Rotar a la derecha
    ANDLW   0xF0                    ; Mantiene dentro del rango RE4?RE7
    MOVWF   VAL_ALTO, A

    ; --- Verifica si llegó al centro (RE4) ---
    MOVF    VAL_ALTO, W, A
    XORLW   BIT_ALTO_B4
    BNZ     SEGUIR_ROTANDO

    ; --- Si llegó al centro, invierte dirección ---
    CALL    MOVER_ATRAS
    GOTO    MAIN

SEGUIR_ROTANDO:
    GOTO    LOOP

;===============================================================================
; SUBRUTINA: Movimiento de retorno (de RE4 a RE7)
;===============================================================================
MOVER_ATRAS:
RETORNO:
    MOVF    VAL_ALTO, W, A
    MOVWF   LATE, A
    CALL    DELAY

    ; --- Corrimiento inverso ---
    BCF     STATUS, 0, A
    MOVF    VAL_ALTO, W, A
    RLCF    WREG, W, A              ; Rotar hacia la izquierda
    ANDLW   0xF0
    MOVWF   VAL_ALTO, A

    ; --- Verifica si regresó al extremo (RE7) ---
    MOVF    VAL_ALTO, W, A
    XORLW   BIT_ALTO_B7
    BNZ     REGRESO
    RETURN

REGRESO:
    GOTO    RETORNO

;===============================================================================
; SUBRUTINA DE RETARDO
;===============================================================================
DELAY:
    MOVLW   0x10
    MOVWF   DelayCounter+1, A
    MOVLW   0x01
    MOVWF   DelayCounter, A
    MOVLW   0x01
RET2:
    DECFSZ  WREG, F, A
    GOTO    RET2
    DECFSZ  DelayCounter, F, A
    GOTO    RET2
    DECFSZ  DelayCounter+1, F, A
    GOTO    RET2
    RETURN