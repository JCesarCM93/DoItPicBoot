;===============================================================================
; File:        P01_example_uart_echo.s
; Author:      GFT
; Date:        2025-09-01
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Programa de ejemplo que inicializa el sistema, recibe un dato por
;              UART, lo incrementa en 1 y lo envía de vuelta.
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
    #define InitSys    0x40          ; Dirección de rutina para inicializar MCU
    #define UartRead   0x42          ; Dirección de rutina para leer dato por UART
    #define UartWrite  0x44          ; Dirección de rutina para enviar dato por UART

;===============================================================================
; VECTOR DE RESET Y PROGRAMA PRINCIPAL
;===============================================================================
    PSECT resetVec,space=2
    ORG     0x0800                   ; Dirección de inicio del programa en memoria
    CALL    InitSys                  ; Inicializa el sistema (puertos, UART, etc.)

ciclo:
    CALL    UartRead                 ; Lee un dato por UART ? resultado en WREG
    INCF    WREG, W, A               ; Incrementa el valor en 1 y guarda en WREG
    CALL    UartWrite                ; Envía el nuevo valor por UART

    GOTO    ciclo                    ; Repite indefinidamente

;===============================================================================
; FIN DEL PROGRAMA
;===============================================================================
    END

