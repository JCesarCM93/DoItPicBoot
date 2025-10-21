;===============================================================================
; File:        P11_example_uart_subtraction.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Resta de dos valores recibidos por UART. 
;              El programa lee dos caracteres (A y B), calcula A - B 
;              utilizando el complemento a dos y envía el resultado por UART.
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
    PSECT  RESETVEC,SPACE=2
VARIABLEA:  DS 1                        ; Primer valor (minuendo)
VARIABLEB:  DS 1                        ; Segundo valor (sustraendo)

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x800
MAIN:  
    CALL    InitSys                     ; Inicializa el sistema
    CLRF    VARIABLEA, A
    CLRF    VARIABLEB, A

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
; Objetivo: Calcular VARIABLEA - VARIABLEB
;-------------------------------------------------------------------------------
LOOP:
    CALL    UartRead                    ; Lee primer dato desde UART
    MOVWF   VARIABLEA, A                ; Guarda en VARIABLEA
    CALL    UartRead                    ; Lee segundo dato desde UART
    MOVWF   VARIABLEB, A                ; Guarda en VARIABLEB
    GOTO    RESTA

;===============================================================================
; RESTA UTILIZANDO COMPLEMENTO A DOS
;===============================================================================
RESTA:      
    COMF    VARIABLEB, W, A             ; Complemento A1 de VARIABLEB
    ADDLW   1                           ; +1 ? complemento A2
    ADDWF   VARIABLEA, W, A             ; VARIABLEA + complemento A2 de VARIABLEB
    CALL    UartWrite                   ; Envía resultado por UART
    GOTO    LOOP                        ; Repite indefinidamente
