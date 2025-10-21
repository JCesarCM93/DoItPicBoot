;===============================================================================
; File:        P15_example_uart_bitrotation.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Rotación de bits visualizada en LEDs. 
;              - Espera el carácter 'R' recibido por UART.
;              - Al recibirlo, rota un byte (VALOR) a la izquierda continuamente.
;              - El contenido del registro VALOR se muestra en el puerto E.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                 ; Deshabilita conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40             ; Rutina de inicialización del MCU
    #define UartRead   0x42             ; Rutina de lectura UART
    #define UartWrite  0x44             ; Rutina de escritura UART
    #define LED2       LATD,0,A         ; LED indicador conectado a RD0

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0X00
    PSECT  RESETVEC,SPACE=2   
VALOR:        DS 1                      ; Valor que se rota (se muestra en LEDs)
CARACTER:     DS 1                      ; Carácter recibido por UART
CONTADOR1:    DS 1                      ; Contador auxiliar
CONTADOR2:    DS 1                      ; Contador auxiliar
DelayCounter: DS 3                      ; Contador de retardo

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x800 

;-------------------------------------------------------------------------------
; CONFIGURACIÓN DE PUERTOS
;-------------------------------------------------------------------------------
    CLRF    TRISE, A                    ; Puerto E como salida
    CLRF    LATE, A                     ; Inicializa LEDs en apagado

;===============================================================================
; PROGRAMA PRINCIPAL
;===============================================================================
MAIN:
    CALL    InitSys                     ; Inicializa sistema UART y periféricos

    MOVLW   0x80                        ; Solo el bit 7 en 1 (inicio de rotación)
    MOVWF   VALOR, A

;-------------------------------------------------------------------------------
; BUCLE DE ESPERA DE COMANDO 'R'
;-------------------------------------------------------------------------------
LOOP:
    CALL    UartRead                    ; Espera un carácter por UART
    MOVWF   CARACTER, A
    MOVLW   'R'                         ; Carácter de inicio de rotación
    CPFSEQ  CARACTER, A                 ; ¿Es 'R'?
    GOTO    LOOP                        ; Si no, seguir esperando

;===============================================================================
; SECUENCIA DE ROTACIÓN
;===============================================================================
ROTAR: 
    RLCF    VALOR, F, A                 ; Rota VALOR a la izquierda (bit 7?Carry, Carry?bit 0)
    MOVF    VALOR, W, A
    MOVWF   LATE, A                     ; Muestra el valor actual en LEDs (Puerto E)
    CALL    UartWrite                   ; Envía el valor por UART
    CALL    DELAY                       ; Pausa visible
    GOTO    ROTAR                       ; Repite indefinidamente

;===============================================================================
; RUTINA DE RETARDO (Delay)
;===============================================================================
DELAY:
    MOVLW   0x10
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