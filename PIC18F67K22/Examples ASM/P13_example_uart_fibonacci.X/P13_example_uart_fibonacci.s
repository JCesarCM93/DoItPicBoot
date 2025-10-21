;===============================================================================
; File:        P13_example_uart_fibonacci.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Genera una secuencia de sumas (tipo Fibonacci) controlada por UART.
;              - El usuario ingresa un número N.
;              - Se muestran los primeros N valores de la secuencia.
;              - Si ocurre desbordamiento (Carry = 1), se enciende LED2 brevemente.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                 ; Deshabilita el conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS
;===============================================================================
    #define InitSys    0x40             ; Rutina de inicialización del MCU
    #define UartRead   0x42             ; Rutina de lectura UART
    #define UartWrite  0x44             ; Rutina de escritura UART
    #define LED2       LATD,0,A         ; LED indicador en puerto D bit 0

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0X00
    PSECT  RESETVEC,SPACE=2
AA:            DS 1                     ; Valor A de la secuencia
BB:            DS 1                     ; Valor B de la secuencia
NN:            DS 1                     ; Límite de iteraciones (ingresado por UART)
SUMA:          DS 1                     ; Resultado temporal de la suma
DelayCounter:  DS 3                     ; Contador para rutina de retardo

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x800
MAIN:
    CALL    InitSys                     ; Inicializa el sistema
    CLRF    AA, A
    CLRF    BB, A
    CLRF    NN, A
    CLRF    SUMA, A

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    CALL    UartRead                    ; Lee el número N (cantidad de términos)
    MOVWF   NN, A

    MOVLW   0
    CALL    UartWrite                   ; Muestra el primer valor (0)
    MOVWF   AA, A                       ; AA = 0

    MOVLW   1
    CALL    UartWrite                   ; Muestra el segundo valor (1)
    MOVWF   BB, A                       ; BB = 1

;-------------------------------------------------------------------------------
; INICIO DE LA SECUENCIA
;-------------------------------------------------------------------------------
SU:
    MOVF    AA, W, A
    ADDWF   BB, W, A                    ; SUMA = AA + BB

    ;--- VERIFICAR DESBORDE (Carry = 1) ---
    BTFSS   STATUS, 0, A
    GOTO    NO_DESBORDE

DESBORDE:
    BSF     LED2                        ; Enciende LED2 (indica desborde)
    CALL    DELAY                       ; Retardo visible
    BCF     LED2                        ; Apaga LED
    BCF     STATUS, 0, A                ; Limpia Carry
    GOTO    LOOP                        ; Reinicia el ciclo principal

;-------------------------------------------------------------------------------
; CONTINÚA LA SECUENCIA SI NO HAY DESBORDE
;-------------------------------------------------------------------------------
NO_DESBORDE:
    MOVWF   SUMA, A                     ; Guarda el resultado de la suma
    MOVF    NN, W, A
    CPFSLT  SUMA, A                     ; ¿SUMA < NN?
    GOTO    FIN                         ; Si SUMA >= NN ? salir

P1:
    MOVF    SUMA, W, A
    CALL    UartWrite                   ; Envía el valor de SUMA por UART
    MOVFF   BB, AA, A                   ; AA = BB
    MOVFF   SUMA, BB, A                 ; BB = SUMA
    GOTO    SU                          ; Repite la secuencia

;-------------------------------------------------------------------------------
; FINALIZA LA SECUENCIA
;-------------------------------------------------------------------------------
FIN:
    GOTO    LOOP                        ; Espera nueva entrada

;===============================================================================
; RUTINA DE RETARDO (Delay)
;===============================================================================
DELAY:
    MOVLW   0x60
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