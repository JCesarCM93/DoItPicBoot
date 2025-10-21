;===============================================================================
; File:        P22_example_uart_manual_rotate.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Rotaci�n manual con UART (RLCF / RRCF)
;              - El usuario controla el sentido de rotaci�n por UART.
;              - Tecla 'L' ? rotaci�n izquierda con acarreo.
;              - Tecla 'R' ? rotaci�n derecha con acarreo.
;              - El valor rotado se muestra en LEDs (Puerto E) y se env�a por UART.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACI�N DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                 ; Deshabilita conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40             ; Rutina de inicializaci�n del sistema
    #define UartRead   0x42             ; Rutina de lectura UART
    #define UartWrite  0x44             ; Rutina de escritura UART
    #define LED        LATD,0,A         ; LED indicador conectado a RD0

;===============================================================================
; VARIABLES (ubicadas en direcci�n 0x0)
;===============================================================================
    ORG 0X0
    PSECT  RESETVEC,SPACE=2    
VALOR:          DS 1                    ; Byte de rotaci�n
CARACTER:       DS 1                    ; Car�cter recibido por UART
DelayCounter:   DS 3                    ; Contador para retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x0800  
MAIN:
    CALL    InitSys                     ; Inicializa UART y sistema
    BCF     LED                         ; LED apagado
    MOVLW   0b00000011                  ; Valor inicial de ejemplo
    MOVWF   VALOR, A
    CLRF    TRISE, A                    ; Puerto E como salida
    CLRF    LATE, A                     ; Apaga LEDs

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    CALL    UartRead                    ; Espera un car�cter por UART
    MOVWF   CARACTER, A
    MOVLW   'L'                         ; Tecla 'L' = rotaci�n izquierda
    CPFSEQ  CARACTER, A
    GOTO    CHECAR_DERECHA

;-------------------------------------------------------------------------------
; ROTACI�N IZQUIERDA
;-------------------------------------------------------------------------------
ROTAR_IZQ:
    BCF     STATUS, 0, A                ; Limpia Carry
    RLCF    VALOR, F, A                 ; Rota a la izquierda con acarreo
    MOVF    VALOR, W, A
    MOVWF   LATE, A                     ; Muestra en LEDs
    CALL    UartWrite                   ; Env�a valor por UART
    CALL    DELAY                       ; Retardo visible
    GOTO    LOOP

;-------------------------------------------------------------------------------
; ROTACI�N DERECHA
;-------------------------------------------------------------------------------
CHECAR_DERECHA:
    MOVLW   'R'                         ; Tecla 'R' = rotaci�n derecha
    CPFSEQ  CARACTER, A
    GOTO    LOOP                        ; Si no es ni L ni R, vuelve a esperar

ROTAR_DER:
    BCF     STATUS, 0, A
    RRCF    VALOR, F, A                 ; Rota a la derecha con acarreo
    MOVF    VALOR, W, A
    MOVWF   LATE, A                     ; Muestra en LEDs
    CALL    UartWrite                   ; Env�a valor por UART
    CALL    DELAY
    GOTO    LOOP

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