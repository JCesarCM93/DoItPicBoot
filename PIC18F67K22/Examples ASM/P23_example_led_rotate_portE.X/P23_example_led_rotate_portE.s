;===============================================================================
; File:        P23_example_led_rotate_portE.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Rotación continua de bits en Puerto E (sin UART).
;              - Se enciende un bit en el puerto E que rota hacia la izquierda.
;              - Al alcanzar el bit más alto (RE7), regresa al inicio.
;              - Ideal para pruebas visuales con LEDs conectados a PORT E.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                 ; Deshabilita el conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES
;===============================================================================
    #define InitSys	0x40              ; Rutina de inicialización del sistema (no usada aquí)
    
;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0x0
    PSECT  RESETVEC, SPACE=2      
VALOR:          DS 1                    ; Valor temporal (no usado en esta práctica)
CARACTER:       DS 1                    ; Carácter temporal (no usado)
DelayCounter:   DS 3                    ; Contador de retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x0800
MAIN:
    ;---------------------------------------------------------------------------
    ; CONFIGURACIÓN INICIAL
    ;---------------------------------------------------------------------------
    CLRF    LATE, A                     ; Apaga todos los LEDs
    CLRF    TRISE, A                    ; Puerto E configurado como salida
    
    ; Valor inicial: bit 0 encendido (RE0)
    MOVLW   0x01
    MOVWF   LATE, A

;===============================================================================
; BUCLE PRINCIPAL - ROTACIÓN CONTINUA
;===============================================================================
BUCLE_ROTACION:
    ;--- Verifica bit más alto y actualiza Carry ---
    BTFSC   LATE, 7, A                  ; Si el bit 7 está en 1...
    BSF     STATUS, 0, A                ; ... Carry = 1
    BTFSS   LATE, 7, A                  ; Si el bit 7 está en 0...
    BCF     STATUS, 0, A                ; ... Carry = 0

    ;--- Rotación izquierda con Carry ---
    RLCF    LATE, W, A                  ; Rota el valor actual de LATE hacia la izquierda
    MOVWF   LATE, A                     ; Escribe el nuevo valor en LEDs (Puerto E)

    CALL    DELAY                       ; Retardo visual
    GOTO    BUCLE_ROTACION              ; Repetir rotación indefinidamente

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