;===============================================================================
; File:        P07_example_uart_counter_led.s
; Author:      GFT
; Date:        2025-09-01
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Programa que recibe comandos por UART:
;              - '+' ? incrementa un contador y lo envía por UART.
;                      Si hay desbordamiento, enciende LED1 brevemente.
;              - '-' ? decrementa un contador y lo envía por UART.
;                      Si llega a 0, enciende LED2 brevemente.
;===============================================================================

    #include <xc.inc>                ; Librería principal de ensamblador PIC-AS

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF              ; Extended Instruction Set Disable 

;===============================================================================
; DEFINICIONES
;===============================================================================
    #define InitSys    0x40          ; Rutina para inicializar el MCU
    #define UartRead   0x42          ; Rutina lectura UART
    #define UartWrite  0x44          ; Rutina escritura UART
    #define LED1       LATD,1,A      ; LED en puerto D, bit 1
    #define LED2       LATD,0,A      ; LED en puerto D, bit 0

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG     0x0000
CONTADOR:       DS 1                 ; Variable contador
SIMBOLO:        DS 1                 ; Carácter recibido por UART
DelayCounter:   DS 3                 ; Contador para rutina de retardo

;===============================================================================
; RESET VECTOR & PROGRAMA PRINCIPAL
;===============================================================================
    PSECT resetVec,space=2
    ORG     0x0800

MAIN: 
    CALL    InitSys                  ; Inicializa MCU
    CLRF    CONTADOR, A              ; Contador = 0

;===============================================================================
; LOOP PRINCIPAL
;===============================================================================
LOOP:
    CALL    UartRead                 ; Leer dato recibido
    MOVWF   SIMBOLO, A               ; Guardarlo en SIMBOLO

;----------- VERIFICAR '+' ----------------
COMPARA_CON_SIGNO_MAS:  
    MOVLW   '+'                      ; ASCII '+' = 0x2B
    CPFSEQ  SIMBOLO, A
    GOTO    COMPARA_CON_SIGNO_MENOS  ; Si no es '+', ir a verificar '-'

INCREMENTO:  
    INCF    CONTADOR, F, A           ; Incrementar contador
    MOVF    CONTADOR, W, A
    CALL    UartWrite                ; Enviar valor por UART

    ;--- Verificar desbordamiento (STATUS<0> = Carry) ---
    BTFSS   STATUS,0,A
    GOTO    LOOP

DESBORDE_INCREMENTO:
    BSF     LED1                     ; Encender LED1
    CALL    DELAY
    BCF     LED1                     ; Apagar LED1
    BCF     STATUS,0,A               ; Limpiar bit de Carry
    GOTO    LOOP

;----------- VERIFICAR '-' ----------------
COMPARA_CON_SIGNO_MENOS:
    MOVLW   '-'                      ; ASCII '-' = 0x2D
    CPFSEQ  SIMBOLO, A
    GOTO    LOOP                     ; Si no es '-', ignorar y volver al loop

DECREMENTO:
    DECF    CONTADOR, F, A           ; Decrementar contador
    MOVF    CONTADOR, W, A
    GOTO    UartWrite                ; Enviar valor por UART

;--- Verificar si llegó a 0 (STATUS<2> = Z) ---
VERIFICAR_DECREMENTO:
    BTFSS   STATUS,2,A
    GOTO    LOOP

CONTADOR_LLEGO_A_CERO:
    BSF     LED2                     ; Encender LED2
    CALL    DELAY
    BCF     LED2                     ; Apagar LED2
    BCF     STATUS,2,A               ; Limpiar flag Z
    GOTO    LOOP

;===============================================================================
; RUTINA DE RETARDO (Delay)
;===============================================================================
DELAY:
    MOVLW   0x60
    MOVWF   DelayCounter+1,A
    MOVLW   0x01
    MOVWF   DelayCounter,A
    MOVLW   0x01

RET2:
    DECFSZ  WREG,F,A
    GOTO    RET2
    DECFSZ  DelayCounter,F,A
    GOTO    RET2
    DECFSZ  DelayCounter+1,F,A
    GOTO    RET2
    RETURN

;===============================================================================
; FIN DEL PROGRAMA
;===============================================================================
    END
