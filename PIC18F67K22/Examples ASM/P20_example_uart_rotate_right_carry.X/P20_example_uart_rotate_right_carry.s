;===============================================================================
; File:        P20_example_uart_rotate_right_carry.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Rotación de bits a la derecha con acarreo (RRCF) controlada por UART.
;              - Espera el carácter 'R' recibido por UART.
;              - Rota el byte VALOR hacia la derecha (bit 0 ? Carry, Carry ? bit 7).
;              - Enciende el LED RD0 si Carry = 1, lo apaga si Carry = 0.
;              - Muestra el valor resultante en LEDs (Puerto E) y lo envía por UART.
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
    #define LED        LATD,0,A         ; LED indicador conectado al pin RD0

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0X0
    PSECT  RESETVEC,SPACE=2        
VALOR:          DS 1                    ; Byte a rotar
CARACTER:       DS 1                    ; Carácter recibido por UART
DelayCounter:   DS 3                    ; Contador de retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x0800
MAIN:
    CALL    InitSys                     ; Inicializa UART y sistema
    CLRF    VALOR, A

    MOVLW   0b10000000                  ; Bit más alto encendido (bit 7 = 1)
    MOVWF   VALOR, A

    CLRF    TRISE, A                    ; Puerto E como salida
    CLRF    LATE, A                     ; Apaga todos los LEDs
    BCF     STATUS, 0, A                ; Limpia el bit de Carry

;===============================================================================
; ESPERA DE COMANDO UART
;===============================================================================
ESPERA_TECLA:
    CALL    UartRead                    ; Espera a que el usuario presione una tecla
    MOVWF   CARACTER, A
    MOVLW   'R'                         ; Comando válido
    CPFSEQ  CARACTER, A
    GOTO    ESPERA_TECLA                ; Si no es 'R', seguir esperando

;===============================================================================
; ROTACIÓN DERECHA CON ACARREO (RRCF)
;===============================================================================
ROTAR:
    BCF     STATUS, 0, A                ; Limpia Carry
    BTFSC   VALOR, 0, A                 ; Si bit 0 = 1
    BSF     STATUS, 0, A                ; Setea Carry = 1

    RRCF    VALOR, F, A                 ; Rota VALOR ? bit0?Carry, Carry?bit7

    ;--- LED INDICADOR DE CARRY ---
    BTFSC   STATUS, 0, A                ; Si Carry = 1
    BSF     LED                         ; Enciende LED
    BTFSS   STATUS, 0, A                ; Si Carry = 0
    BCF     LED                         ; Apaga LED

    ;--- VISUALIZACIÓN Y ENVÍO ---
    MOVF    VALOR, W, A
    MOVWF   LATE, A                     ; Muestra en LEDs (Puerto E)
    CALL    UartWrite                   ; Envía valor actual por UART

    CALL    DELAY                       ; Retardo visible
    GOTO    ESPERA_TECLA                ; Vuelve a esperar nuevo comando

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
