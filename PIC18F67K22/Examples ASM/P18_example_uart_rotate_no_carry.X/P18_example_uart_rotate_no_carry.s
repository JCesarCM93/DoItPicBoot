;===============================================================================
; File:        P18_example_uart_rotate_no_carry.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Rotación de bits sin acarreo (RLNCF) controlada por UART.
;              - Espera el carácter 'R' por UART.
;              - Realiza una rotación izquierda sin considerar el bit Carry.
;              - Muestra el valor rotado en LEDs (Puerto E) y lo envía por UART.
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

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0X0
    PSECT  RESETVEC,SPACE=2        
VALOR:          DS 1                    ; Valor a rotar
CARACTER:       DS 1                    ; Carácter recibido por UART
DelayCounter:   DS 3                    ; Contador de retardo (3 bytes)

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x800
MAIN:
    CALL    InitSys                     ; Inicializa sistema y UART
    
    CLRF    TRISE, A                    ; Puerto E como salida
    CLRF    LATE, A                     ; Apaga todos los LEDs inicialmente
    CLRF    VALOR, A                    ; Limpia variable de trabajo

    MOVLW   0b00000011                  ; Valor inicial: bits 0 y 1 en 1
    CALL    UartWrite                   ; Envía valor inicial por UART
    MOVWF   VALOR, A                    ; Guarda valor en memoria

;===============================================================================
; ESPERA DE COMANDO 'R'
;===============================================================================
ESPERA_TECLA:
    CALL    UartRead                    ; Espera a que el usuario presione una tecla
    MOVWF   CARACTER, A 
    MOVLW   'R'                         ; Carácter de inicio de rotación
    CPFSEQ  CARACTER, A
    GOTO    ESPERA_TECLA                ; Si no es 'R', seguir esperando

;===============================================================================
; ROTACIÓN SIN ACARREO (RLNCF)
;===============================================================================
ROTAR:
    RLNCF   VALOR, F, A                 ; Rota VALOR a la izquierda sin afectar Carry

    MOVF    VALOR, W, A
    MOVWF   LATE, A                     ; Muestra el valor en LEDs (Puerto E)
    CALL    UartWrite                   ; Envía valor actual por UART

    CALL    DELAY                       ; Pausa visible
    GOTO    ESPERA_TECLA                ; Regresa a esperar comando

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