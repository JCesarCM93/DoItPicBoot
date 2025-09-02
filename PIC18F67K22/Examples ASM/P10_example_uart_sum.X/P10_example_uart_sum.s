;===============================================================================
; File:        P10_example_uart_sum.s
; Author:      GFT
; Date:        2025-09-02
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Suma de dos valores recibidos por UART. 
;              El programa lee dos caracteres (A y B), los suma y envía el resultado por UART.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                 ; Deshabilita conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS
;===============================================================================
    #define InitSys    0x40             ; Rutina de inicialización del MCU
    #define UartRead   0x42             ; Rutina de lectura UART
    #define UartWrite  0x44             ; Rutina de escritura UART

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0X0
VARIABLEA:  DS 1                        ; Primer valor recibido
VARIABLEB:  DS 1                        ; Segundo valor recibido

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    PSECT  RESETVEC,SPACE=2
    ORG 0x800  
MAIN: 
    CALL    InitSys                     ; Inicializa el sistema
    CLRF    VARIABLEA, A
    CLRF    VARIABLEB, A

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    CALL    UartRead                    ; Lee primer dato desde UART
    MOVWF   VARIABLEA, A                ; Guarda en VARIABLEA
    CALL    UartRead                    ; Lee segundo dato desde UART
    MOVWF   VARIABLEB, A                ; Guarda en VARIABLEB
    GOTO     SUMA

;===============================================================================
; SUMA DE LOS VALORES
;===============================================================================
SUMA:
    MOVF    VARIABLEB, W, A             ; Carga VARIABLEB en W
    ADDWF   VARIABLEA, W, A             ; Suma W + VARIABLEA, resultado en W
    CALL    UartWrite                   ; Envía resultado por UART
    GOTO    LOOP                        ; Repite el bucle

;===============================================================================
; FIN DEL PROGRAMA
;===============================================================================
    END
