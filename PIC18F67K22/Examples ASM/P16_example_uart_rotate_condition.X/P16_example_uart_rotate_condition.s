;===============================================================================
; File:        P16_example_uart_rotate_condition.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Rotación condicional de bits controlada por UART.
;              - Espera el carácter 'I' recibido por UART.
;              - Al recibirlo, realiza una rotación a la izquierda (RLCF) sobre VALOR.
;              - El valor rotado se muestra en el puerto E y se envía por UART.
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
    #define LED        LATD,0,A         ; LED conectado al pin RD0

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0X00
    PSECT  RESETVEC,SPACE=2
VALOR:          DS 1                    ; Valor a rotar
CARACTER:       DS 1                    ; Carácter recibido por UART
DelayCounter:   DS 3                    ; Contador de retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x800

;===============================================================================
; PROGRAMA PRINCIPAL
;===============================================================================
MAIN:
    CALL    InitSys                     ; Inicializa UART y sistema base
    CLRF    VALOR, A
    MOVLW   0b00000011                  ; Valor inicial con bits 0 y 1 en '1'
    MOVWF   VALOR, A
    CLRF    TRISE, A                    ; Puerto E configurado como salida
    CLRF    LATE, A                     ; Apaga LEDs

;-------------------------------------------------------------------------------
; ESPERA DE COMANDO POR UART
;-------------------------------------------------------------------------------
ESPERA_TECLA:
    CALL    UartRead                    ; Espera un carácter
    MOVWF   CARACTER, A
    MOVLW   'I'                         ; Carácter de inicio de rotación
    CPFSEQ  CARACTER, A
    GOTO    ESPERA_TECLA                ; Si no es 'I', seguir esperando

;-------------------------------------------------------------------------------
; RUTINA DE ROTACIÓN CONDICIONAL
;-------------------------------------------------------------------------------
ROTAR:
    BTFSC   VALOR, 7, A                 ; Si bit 7 = 1
    BSF     STATUS, 0, A                ; Setea Carry = 1
    BTFSS   VALOR, 7, A                 ; Si bit 7 = 0
    BCF     STATUS, 0, A                ; Limpia Carry = 0

    RLCF    VALOR, F, A                 ; Rota a la izquierda (bit7?Carry, Carry?bit0)

    MOVF    VALOR, W, A
    MOVWF   LATE, A                     ; Muestra en LEDs (Puerto E)
    CALL    UartWrite                   ; Envía valor por UART
    CALL    DELAY                       ; Retardo visible
    GOTO    ESPERA_TECLA                ; Espera nueva instrucción

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