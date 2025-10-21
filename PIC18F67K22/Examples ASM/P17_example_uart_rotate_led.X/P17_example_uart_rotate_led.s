;===============================================================================
; File:        P17_example_uart_rotate_led.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Rotación de bits controlada por UART.
;              - Espera el carácter 'I' para iniciar la rotación izquierda.
;              - Muestra el valor rotado en LEDs (Puerto E) y lo envía por UART.
;              - El LED en RD0 se enciende cuando el bit de Carry está en 1.
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
VALOR:          DS 1                    ; Byte que será rotado
CARACTER:       DS 1                    ; Carácter recibido por UART
DelayCounter:   DS 3                    ; Contador para retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x800
MAIN:
    CALL    InitSys                     ; Inicializa sistema
    CLRF    VALOR, A
    MOVLW   0b00000011                  ; Valor inicial (bits 0 y 1 en '1')
    MOVWF   VALOR, A
    CLRF    TRISE, A                    ; Puerto E como salida
    CLRF    LATE, A                     ; Inicializa LEDs en apagado

;===============================================================================
; ESPERA DE COMANDO UART
;===============================================================================
ESPERA_TECLA:
    CALL    UartRead                    ; Espera que el usuario presione una tecla
    MOVWF   CARACTER, A
    MOVLW   'I'                         ; Comando de inicio (I)
    CPFSEQ  CARACTER, A
    GOTO    ESPERA_TECLA                ; Si no es 'I', vuelve a esperar

    BCF     STATUS, 0, A                ; Limpia Carry

;===============================================================================
; ROTACIÓN IZQUIERDA CON INDICADOR LED
;===============================================================================
ROTAR_IZ:
    BCF     STATUS, 0, A                ; Limpia Carry
    BTFSC   VALOR, 7, A                 ; Si bit 7 = 1, Carry = 1
    BSF     STATUS, 0, A

    ;--- ROTACIÓN A LA IZQUIERDA ---
    RLCF    VALOR, F, A                 ; Bit7?Carry, Carry?Bit0

    ;--- LED INDICADOR SEGÚN CARRY ---
    BTFSC   STATUS, 0, A                ; Si Carry = 1
    BSF     LED                         ; Enciende LED
    BTFSS   STATUS, 0, A                ; Si Carry = 0
    BCF     LED                         ; Apaga LED

    ;--- ENVÍO Y VISUALIZACIÓN ---
    MOVF    VALOR, W, A
    CALL    UartWrite                   ; Envía valor por UART
    MOVWF   LATE, A                     ; Muestra valor en LEDs

    CALL    DELAY                       ; Retardo visible
    GOTO    ESPERA_TECLA                ; Regresa a esperar nuevo comando

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