;===============================================================================
; File:        P12_example_uart_multiplication.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Multiplicaci�n de dos valores recibidos por UART.
;              El programa lee dos n�meros (NUM1 y NUM2), los multiplica
;              y env�a el resultado de 16 bits (PRODH:PRODL) por UART.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACI�N DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                 ; Deshabilita el conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS
;===============================================================================
    #define InitSys    0x40             ; Rutina de inicializaci�n del MCU
    #define UartRead   0x42             ; Rutina de lectura UART
    #define UartWrite  0x44             ; Rutina de escritura UART

;===============================================================================
; VARIABLES (ubicadas en direcci�n 0x0)
;===============================================================================
    ORG 0X00
    PSECT  RESETVEC,SPACE=2     
NUM1:   DS 1                            ; Primer n�mero recibido
NUM2:   DS 1                            ; Segundo n�mero recibido

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x800 
MAIN:
    CALL    InitSys                     ; Inicializa el sistema

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    ;--- LECTURA DE N�MEROS ---
    CALL    UartRead                    ; Lee primer n�mero
    MOVWF   NUM1, A
    CALL    UartRead                    ; Lee segundo n�mero
    MOVWF   NUM2, A

    ;--- MULTIPLICACI�N (8x8 bits) ---
    MOVF    NUM1, W, A
    MULWF   NUM2, A                     ; NUM1 * NUM2 ? resultado en PRODH:PRODL

    ;----------------------------------------------------------------------------
    ; NOTA IMPORTANTE:
    ; La instrucci�n MULWF realiza una multiplicaci�n de 8 bits x 8 bits.
    ; El resultado de 16 bits se almacena en:
    ;   PRODL = parte baja (LSB)
    ;   PRODH = parte alta (MSB)
    ;
    ; Ejemplo: 125 * 5 = 625 decimal = 0x0271
    ;           PRODH = 0x02 (parte alta)
    ;           PRODL = 0x71 (parte baja)
    ;
    ; Si env�as ambos bytes separados por UART, recibir�s dos caracteres
    ; correspondientes a esos valores (no el n�mero ASCII "625").
    ;----------------------------------------------------------------------------

    ;--- ENV�O DEL RESULTADO (PRODH:PRODL) ---
    MOVF    PRODH, W, A                 ; Env�a parte alta del resultado
    CALL    UartWrite
    MOVF    PRODL, W, A                 ; Env�a parte baja del resultado
    CALL    UartWrite

    GOTO    LOOP                        ; Repite indefinidamente