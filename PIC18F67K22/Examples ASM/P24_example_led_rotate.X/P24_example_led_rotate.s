;===============================================================================
; File:        P24_example_led_rotate.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Ejemplo de rotación circular de bits sobre el puerto E.
;              Se simula un desplazamiento de un patrón binario encendiendo
;              LEDs conectados al puerto E, usando instrucciones RLCF y Carry.
;===============================================================================

    #include <xc.inc>                ; Librería principal de ensamblador PIC-AS

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF              ; Deshabilita el conjunto extendido de instrucciones

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys     0x40         ; Rutina de inicialización del sistema
    #define UartRead    0x42         ; Rutina de lectura UART (no utilizada)
    #define UartWrite   0x44         ; Rutina de escritura UART (no utilizada)
    #define LED1        LATD,0,A     ; LED indicador conectado a RD0

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0000)
;===============================================================================
    ORG 0x0000
VALOR:        DS 1                   ; Variable auxiliar (no usada en esta práctica)
CARACTER:     DS 1
CONTADOR1:    DS 1
CONTADOR2:    DS 1
DelayCounter: DS 3                   ; Contador de retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET Y PROGRAMA PRINCIPAL
;===============================================================================
    PSECT resetVec, space=2
    ORG 0x0800

;===============================================================================
; PROGRAMA PRINCIPAL
;===============================================================================
MAIN:
    CALL    InitSys                  ; Inicializa MCU y periféricos

    CLRF    LATE, A                  ; Apaga todos los pines del puerto E
    CLRF    TRISE, A                 ; Configura puerto E como salida
    MOVLW   0x01                     ; Valor inicial: bit 0 encendido
    MOVWF   LATE, A

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
BUCLE_ROTACION:
    ; --- Verifica el bit más significativo (bit 3) y lo guarda en Carry ---
    BTFSC   LATE, 3, A               ; Si el bit 3 está en 1 ? Carry = 1
    BSF     STATUS, 0, A
    BTFSS   LATE, 3, A               ; Si el bit 3 está en 0 ? Carry = 0
    BCF     STATUS, 0, A

    ; --- Rotación hacia la izquierda ---
    RLCF    LATE, W, A               ; Rota el valor del puerto E con Carry
    ANDLW   0x0F                     ; Asegura que solo los 4 bits bajos se usen
    MOVWF   LATE, A                  ; Actualiza los LEDs del puerto E

    CALL    DELAY                    ; Espera visible
    GOTO    BUCLE_ROTACION           ; Repite indefinidamente

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