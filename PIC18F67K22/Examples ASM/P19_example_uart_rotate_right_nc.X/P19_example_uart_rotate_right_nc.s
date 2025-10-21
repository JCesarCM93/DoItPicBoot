;===============================================================================
; File:        P19_example_uart_rotate_right_nc.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Rotaci�n de bits a la derecha sin acarreo (RRNCF) controlada por UART.
;              - Espera el car�cter 'R' recibido por UART.
;              - Realiza rotaci�n a la derecha sin usar el bit Carry.
;              - Muestra el valor en LEDs (Puerto E) y lo env�a por UART.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACI�N DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                 ; Deshabilita conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40             ; Rutina de inicializaci�n del MCU
    #define UartRead   0x42             ; Rutina de lectura UART
    #define UartWrite  0x44             ; Rutina de escritura UART

;===============================================================================
; VARIABLES (ubicadas en direcci�n 0x0)
;===============================================================================
    ORG 0X0
    PSECT  RESETVEC,SPACE=2        
VALOR:          DS 1                    ; Valor que ser� rotado
CARACTER:       DS 1                    ; Car�cter recibido por UART
DelayCounter:   DS 3                    ; Contador de retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x0800
MAIN:
    CALL    InitSys                     ; Inicializa UART y sistema
    CLRF    VALOR, A

    MOVLW   0b10000000                  ; Inicia con el bit m�s alto encendido  
    MOVWF   VALOR, A

    CLRF    TRISE, A                    ; Puerto E configurado como salida
    CLRF    LATE, A                     ; Apaga todos los LEDs inicialmente

;===============================================================================
; ESPERA DE COMANDO UART
;===============================================================================
ESPERA_TECLA:
    CALL    UartRead                    ; Espera a que el usuario presione una tecla
    MOVWF   CARACTER, A
    MOVLW   'R'                         ; Car�cter de inicio de rotaci�n
    CPFSEQ  CARACTER, A
    GOTO    ESPERA_TECLA                ; Si no es 'R', seguir esperando

;===============================================================================
; ROTACI�N A LA DERECHA SIN ACARREO (RRNCF)
;===============================================================================
ROTAR:
    RRNCF   VALOR, F, A                 ; Rota a la derecha sin considerar Carry

    MOVF    VALOR, W, A
    MOVWF   LATE, A                     ; Muestra valor en LEDs (Puerto E)
    CALL    UartWrite                   ; Env�a valor actual por UART

    CALL    DELAY                       ; Retardo visual
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