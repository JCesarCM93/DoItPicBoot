;===============================================================================
; File:        P06_example_uart_counter.s
; Author:      GFT
; Date:        2025-09-01
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Programa que recibe comandos por UART:
;              - '+' ? incrementa un contador y envía el valor actualizado
;              - 'R' ? reinicia el contador en 0 y lo envía
;              El valor del contador se envía por UART después de cada operación.
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
    #define LED1       LATD,1        ; LED conectado en puerto D, bit 1

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG     0x0000
CONTADOR: DS 1                       ; Variable contador (8 bits)
SIMBOLO:  DS 1                       ; Variable para guardar el carácter recibido

;===============================================================================
; VECTOR DE RESET Y PROGRAMA PRINCIPAL
;===============================================================================
    PSECT resetVec,space=2
    ORG     0x0800                   ; Dirección de inicio del programa en memoria

MAIN:
    CALL    InitSys                  ; Inicialización del sistema
    CLRF    CONTADOR, A              ; Contador comienza en 0

LOOP:
    CALL    UartRead                 ; Leer un dato de UART
    MOVWF   SIMBOLO, A               ; Guardar el carácter recibido

;----------- COMPARA CON '+' ----------------
COMPARA_CON_SIGNO_MAS:
    MOVLW   '+'                      ; ASCII '+' = 0x2B
    CPFSEQ  SIMBOLO, A               ; ¿SIMBOLO == '+' ?
    GOTO    COMPARA_CON_R            ; Si no, ir a verificar 'R'

INCRE_MAS:
    INCF    CONTADOR, F, A           ; Incrementa el contador
    MOVF    CONTADOR, W, A           ; Cargar el valor del contador
    CALL    UartWrite                ; Enviar por UART

    ;--- Verificar desbordamiento (CARRY = 1 en STATUS<0>) ---
    BTFSS   STATUS, 0, A             ; ¿Carry = 1?
    GOTO    LOOP
DESBORDE:
    BCF     STATUS, 0, A             ; Limpiar el bit de Carry
    GOTO    LOOP

;----------- COMPARA CON 'R' ----------------
COMPARA_CON_R:
    MOVLW   'R'                      ; ASCII 'R' = 0x52
    CPFSEQ  SIMBOLO, A               ; ¿SIMBOLO == 'R' ?
    GOTO    LOOP                     ; Si no, ignorar y volver al loop

REINICIO_CONTADOR:
    CLRF    CONTADOR, A              ; Reiniciar el contador
    MOVF    CONTADOR, W, A
    CALL    UartWrite                ; Enviar valor reiniciado (0)
    GOTO    LOOP

;===============================================================================
; FIN DEL PROGRAMA
;===============================================================================
    END
