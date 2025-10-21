;===============================================================================
; File:        P14_example_uart_sum_overflow.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Suma de dos n�meros recibidos por UART. 
;              Si ocurre desbordamiento (Carry = 1), se enciende LED2 y se env�a 0xFF.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACI�N DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                 ; Deshabilita el conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40             ; Rutina de inicializaci�n del MCU
    #define UartRead   0x42             ; Rutina para leer por UART
    #define UartWrite  0x44             ; Rutina para escribir por UART
    #define LED2       LATD,0,A         ; LED indicador en puerto D, bit 0

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
    CALL    InitSys                     ; Inicializa sistema y perif�ricos

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    ;---------------------------------------------------------------------------
    ; LECTURA DE LOS DOS N�MEROS
    ;---------------------------------------------------------------------------
    CALL    UartRead                    ; Lee primer n�mero
    MOVWF   NUM1, A                     ; Guarda en NUM1

    CALL    UartRead                    ; Lee segundo n�mero
    MOVWF   NUM2, A                     ; Guarda en NUM2

    ;---------------------------------------------------------------------------
    ; SUMA Y DETECCI�N DE DESBORDE (CARRY)
    ;---------------------------------------------------------------------------
    MOVF    NUM1, W, A
    ADDWF   NUM2, W, A                  ; W = NUM1 + NUM2

    BTFSC   STATUS, 0, A                ; �Hubo desbordamiento? (Carry = 1)
    GOTO    DESBORDAMIENTO              ; Si s�, manejar el error

    ;---------------------------------------------------------------------------
    ; SIN DESBORDE ? ENVIAR RESULTADO NORMAL
    ;---------------------------------------------------------------------------
    BCF     LED2                        ; Asegura LED apagado
    CALL    UartWrite                   ; Env�a resultado por UART
    GOTO    LOOP

;===============================================================================
; DESBORDAMIENTO
;===============================================================================
DESBORDAMIENTO:
    BSF     LED2                        ; Enciende LED indicador
    MOVLW   0xFF                        ; Valor para indicar error o desborde
    CALL    UartWrite                   ; Env�a 0xFF por UART
    GOTO    LOOP                        ; Repite ciclo