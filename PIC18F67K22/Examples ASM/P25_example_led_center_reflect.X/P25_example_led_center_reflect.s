;===============================================================================
; File:        P25_example_led_center_reflect.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Movimiento de LEDs desde los extremos (RE0 y RE7) hacia el
;              centro (RE3 y RE4), y de regreso a los extremos.
;              Se utilizan rotaciones combinadas (RLCF / RRCF) para generar
;              un efecto simétrico de desplazamiento.
;===============================================================================

    #include <xc.inc>                ; Librería principal de ensamblador PIC-AS

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF              ; Deshabilita el conjunto extendido de instrucciones

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys     0x40         ; Rutina para inicializar el MCU
    #define UartRead    0x42         ; Rutina para lectura UART (no usada aquí)
    #define UartWrite   0x44         ; Rutina para escritura UART (no usada aquí)
    #define LED         LATD,0,A     ; LED indicador conectado al pin RD0

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0000)
;===============================================================================
    ORG 0x0000
VALOR_BAJO:   DS 1                  ; Controla los bits bajos (RE0?RE3)
VALOR_ALTO:   DS 1                  ; Controla los bits altos (RE4?RE7)
DelayCounter: DS 3                  ; Contador de retardo (3 bytes)

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
    CLRF    TRISE, A                ; Puerto E configurado como salida
    CLRF    LATE, A                 ; Inicialmente apaga todos los LEDs

    MOVLW   0x01                    ; LED encendido en RE0
    MOVWF   VALOR_BAJO, A
    MOVLW   0x80                    ; LED encendido en RE7
    MOVWF   VALOR_ALTO, A

;===============================================================================
; BUCLE PRINCIPAL - Movimiento hacia el centro
;===============================================================================
BUCLE:
    MOVF    VALOR_BAJO, W, A
    IORWF   VALOR_ALTO, W, A        ; Combina ambos valores (LEDs activos)
    MOVWF   LATE, A
    CALL    DELAY                   ; Retardo visible

    ; --- Corrimiento hacia el centro ---
    BCF     STATUS, 0, A
    MOVF    VALOR_BAJO, W, A
    RLCF    WREG, W, A              ; Rota hacia la izquierda los bits bajos
    ANDLW   0x0F                    ; Asegura que solo se usen los 4 bits inferiores
    MOVWF   VALOR_BAJO, A

    BCF     STATUS, 0, A
    MOVF    VALOR_ALTO, W, A
    RRCF    WREG, W, A              ; Rota hacia la derecha los bits altos
    ANDLW   0xF0                    ; Asegura que solo se usen los 4 bits superiores
    MOVWF   VALOR_ALTO, A

    ; --- Verifica si los LEDs llegaron al centro (RE3 y RE4) ---
    MOVF    VALOR_BAJO, W, A
    XORLW   0x08
    BNZ     BUCLE_MEDIO
    MOVF    VALOR_ALTO, W, A
    XORLW   0x10
    BNZ     BUCLE_MEDIO

    ; Cuando llega al centro ? invertir dirección
    CALL    MOVER_ATRAS
    GOTO    MAIN

BUCLE_MEDIO:
    GOTO    BUCLE

;===============================================================================
; SUBRUTINA: Mover los LEDs en dirección inversa (de centro a extremos)
;===============================================================================
MOVER_ATRAS:
RETORNO:
    MOVF    VALOR_BAJO, W, A
    IORWF   VALOR_ALTO, W, A
    MOVWF   LATE, A
    CALL    DELAY

    ; --- Corrimiento inverso ---
    BCF     STATUS, 0, A
    MOVF    VALOR_BAJO, W, A
    RRCF    WREG, W, A              ; Rota hacia la derecha bits bajos
    ANDLW   0x0F
    MOVWF   VALOR_BAJO, A

    BCF     STATUS, 0, A
    MOVF    VALOR_ALTO, W, A
    RLCF    WREG, W, A              ; Rota hacia la izquierda bits altos
    ANDLW   0xF0
    MOVWF   VALOR_ALTO, A

    ; --- Verifica si regresaron a los extremos ---
    MOVF    VALOR_BAJO, W, A
    XORLW   0x01
    BNZ     REGRESO
    MOVF    VALOR_ALTO, W, A
    XORLW   0x80
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