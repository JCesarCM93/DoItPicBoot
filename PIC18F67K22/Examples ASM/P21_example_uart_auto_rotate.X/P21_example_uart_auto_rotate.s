;===============================================================================
; File:        P21_example_uart_auto_rotate.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Rotaci�n autom�tica izquierda/derecha sin acarreo (RLNCF / RRNCF).
;              - Espera el car�cter 'R' por UART para iniciar rotaci�n.
;              - Cuando el bit menos significativo (LATE.0) est� en 1, cambia a rotar izquierda.
;              - Cuando el bit m�s significativo (LATE.7) est� en 1, cambia a rotar derecha.
;              - Muestra el patr�n rotado en LEDs (Puerto E) y lo env�a por UART.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACI�N DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                 ; Deshabilita el conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40             ; Rutina de inicializaci�n del sistema
    #define UartRead   0x42             ; Rutina de lectura UART
    #define UartWrite  0x44             ; Rutina de escritura UART

;===============================================================================
; VARIABLES (ubicadas en direcci�n 0x0)
;===============================================================================
    ORG 0X0
    PSECT  RESETVEC,SPACE=2         
VALOR:          DS 1                    ; Byte que ser� rotado
CARACTER:       DS 1                    ; Car�cter recibido por UART
DelayCounter:   DS 3                    ; Contador de retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x0800
MAIN:
    CALL    InitSys                     ; Inicializa UART y sistema
    CLRF    VALOR, A
    CLRF    TRISE, A                    ; Puerto E como salida
    CLRF    LATE, A                     ; Apaga todos los LEDs

    MOVLW   0b10000000                  ; Inicia con el bit m�s alto encendido
    MOVWF   VALOR, A

;===============================================================================
; ESPERA DE COMANDO UART
;===============================================================================
ESPERA_TECLA:
    CALL    UartRead                    ; Espera a que se presione una tecla
    MOVWF   CARACTER, A
    MOVLW   'R'                         ; Comando de inicio
    CPFSEQ  CARACTER, A
    GOTO    ESPERA_TECLA                ; Si no es 'R', seguir esperando

;===============================================================================
; ROTACI�N AUTOM�TICA
;-------------------------------------------------------------------------------
; - Si LATE.0 (bit menos significativo) = 1 ? cambia sentido a izquierda
; - Si LATE.7 (bit m�s significativo) = 1 ? cambia sentido a derecha
;===============================================================================
ROTA_DERECHO:
    BTFSC   LATE, 0, A                  ; �Lleg� al extremo derecho?
    GOTO    ROTA_IZQ                    ; S� ? cambia direcci�n
    RRNCF   VALOR, F, A                 ; Rotar sin acarreo a la derecha
    MOVF    VALOR, W, A
    MOVWF   LATE, A                     ; Mostrar valor en LEDs
    CALL    UartWrite                   ; Enviar valor por UART
    CALL    DELAY                       ; Retardo visible
    GOTO    ROTA_DERECHO                ; Repite la rotaci�n

ROTA_IZQ:
    BTFSC   LATE, 7, A                  ; �Lleg� al extremo izquierdo?
    GOTO    ROTA_DERECHO                ; S� ? cambia direcci�n
    RLNCF   VALOR, F, A                 ; Rotar sin acarreo a la izquierda
    MOVF    VALOR, W, A
    MOVWF   LATE, A                     ; Mostrar valor en LEDs
    CALL    UartWrite                   ; Enviar valor por UART
    CALL    DELAY                       ; Retardo visible
    GOTO    ROTA_IZQ                    ; Repite la rotaci�n

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
