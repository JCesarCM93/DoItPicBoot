;===============================================================================
; File:        P05_example_uart_increment_led.s
; Author:      GFT
; Date:        2025-09-02
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Incrementa un contador cada vez que se recibe el carácter '+' por UART.
;              Si ocurre desbordamiento (Carry = 1), enciende un LED por un instante.
;===============================================================================

    #include <xc.inc>                  ; Librería del ensamblador PIC-AS

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                ; Deshabilita el conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40            ; Rutina de inicialización del sistema
    #define UartRead   0x42            ; Rutina de lectura UART
    #define UartWrite  0x44            ; Rutina de escritura UART
    #define LED1       LATD,1          ; LED conectado al puerto D, bit 1

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0X0
    PSECT  RESETVEC,SPACE=2
CONTADOR:      DS 1                    ; Variable contador
SIMBOLO:       DS 1                    ; Variable para almacenar el carácter recibido
DelayCounter:  DS 3                    ; Contador de retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x800     
MAIN: 
    CALL    InitSys                    ; Inicializa el MCU
    CLRF    CONTADOR, A                ; Inicializa CONTADOR en 0

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    CALL    UartRead                   ; Lee dato desde UART
    MOVWF   SIMBOLO, A                 ; Guarda el dato recibido en SIMBOLO

;-------------------------------------------------------------------------------
; COMPARA SI EL CARÁCTER RECIBIDO ES '+'
;-------------------------------------------------------------------------------
COMPARA_CON_SIGNO_MAS:  
    MOVLW   '+'                        ; ASCII '+' = 0x2B
    CPFSEQ  SIMBOLO, A                 ; Si SIMBOLO == '+', continúa
    GOTO    LOOP                       ; Si no es '+', regresa al inicio del bucle

;-------------------------------------------------------------------------------
; INCREMENTA EL CONTADOR Y ENVÍA EL NUEVO VALOR POR UART
;-------------------------------------------------------------------------------
INCRE_MAS:  
    INCF    CONTADOR, F, A             ; Incrementa CONTADOR
    MOVF    CONTADOR, W, A             ; Carga el valor actualizado en WREG
    CALL    UartWrite                  ; Envía el valor actual por UART

;-------------------------------------------------------------------------------
; VERIFICA SI HUBO DESBORDE (CARRY = 1 EN STATUS<0>)
;-------------------------------------------------------------------------------
    BTFSS   STATUS, 0, A               ; ¿Carry = 1?
    GOTO    LOOP                       ; Si no hay desborde, volver al bucle principal

DESEBORDE:  
    BSF     LED1                       ; Enciende LED1 (indica desborde)
    CALL    DELAY                      ; Retardo para que el encendido sea visible
    BCF     LED1                       ; Apaga LED1
    BCF     STATUS, 0, A               ; Limpia el bit de Carry
    GOTO    LOOP                       ; Vuelve al bucle principal

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