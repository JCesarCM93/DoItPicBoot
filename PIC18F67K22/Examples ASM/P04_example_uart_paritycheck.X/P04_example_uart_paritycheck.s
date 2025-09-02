;===============================================================================
; File:        P04_example_uart_paritycheck.s
; Author:      GFT
; Date:        2025-09-01
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Programa que recibe un dato por UART, verifica el bit 0 y envía
;              'P' si el número es par o 'I' si es impar. Se envuelven con
;              espacios para facilitar la lectura en consola.
;===============================================================================

    #include <xc.inc>                ; Librería principal de ensamblador PIC-AS

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF              ; Extended Instruction Set Enable bit:
                                     ; OFF = Conjunto de instrucciones extendido
                                     ; deshabilitado (modo clásico)

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40          ; Rutina para inicializar el MCU
    #define UartRead   0x42          ; Rutina para lectura de datos UART
    #define UartWrite  0x44          ; Rutina para escritura de datos UART

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG     0x0000
NUMERO: DS 1                         ; Variable para almacenar el dato recibido

;===============================================================================
; VECTOR DE RESET Y PROGRAMA PRINCIPAL
;===============================================================================
    PSECT resetVec,space=2
    ORG     0x0800                   ; Dirección de inicio del programa en memoria

MAIN:
    CALL    InitSys                  ; Inicializa el sistema (puertos, UART, etc.)

LOOP:
    CALL    UartRead                 ; Lee un dato por UART ? resultado en WREG
    MOVWF   NUMERO, A                ; Guarda el valor recibido en NUMERO

    ;----------- VERIFICAR SI EL NÚMERO ES PAR O IMPAR -----------
    BTFSS   NUMERO, 0, A             ; Si bit0 = 1 ? impar, si bit0 = 0 ? par
    GOTO    ES_PAR                   ; Brinca si es par

ES_IMPAR:
    MOVLW   ' '                      ; Espacio
    CALL    UartWrite
    MOVLW   'I'                      ; Enviar "I" para indicar número impar
    CALL    UartWrite
    MOVLW   ' '                      ; Espacio
    CALL    UartWrite
    GOTO    LOOP

ES_PAR:
    MOVLW   ' '                      ; Espacio
    CALL    UartWrite
    MOVLW   'P'                      ; Enviar "P" para indicar número par
    CALL    UartWrite
    MOVLW   ' '                      ; Espacio
    CALL    UartWrite
    GOTO    LOOP

;===============================================================================
; FIN DEL PROGRAMA
;===============================================================================
    END
