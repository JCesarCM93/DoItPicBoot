;===============================================================================
; File:        P02_example_uart_echo_store.s
; Author:      GFT
; Date:        2025-09-01
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Programa de ejemplo que inicializa el sistema, recibe un dato por
;              UART, lo guarda en memoria y lo reenvía junto con un espacio.
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
NUM1:   DS 1                         ; Variable para almacenar un byte recibido

;===============================================================================
; VECTOR DE RESET Y PROGRAMA PRINCIPAL
;===============================================================================
    PSECT resetVec,space=2
    ORG     0x0800                   ; Dirección de inicio del programa en memoria
MAIN:
    CALL    InitSys                  ; Inicializa el sistema (puertos, UART, etc.)

LOOP:
    ;----------- LECTURA DE DATO POR UART ----------------
    CALL    UartRead                 ; Lee un dato por UART ? resultado en WREG
    MOVWF   NUM1, A                  ; Guarda el dato recibido en NUM1


    MOVLW   ' '                      ; Carga un espacio en WREG
    CALL    UartWrite                ; Envía el espacio por UART
    
    MOVF    NUM1, W, A               ; Recupera el valor almacenado
    CALL    UartWrite                ; Envía el dato por UART

    GOTO    LOOP                     ; Repite indefinidamente

;===============================================================================
; FIN DEL PROGRAMA
;===============================================================================
    END
