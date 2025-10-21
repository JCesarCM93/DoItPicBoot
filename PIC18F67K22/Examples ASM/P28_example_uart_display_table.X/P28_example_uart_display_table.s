;===============================================================================
; File:        P29_example_uart_display_hex_table.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Tabla de códigos para display de 7 segmentos controlada por UART.
;              - Al recibir '+' desde UART, envía el siguiente código de la tabla.
;              - Los códigos representan caracteres HEX (0?F) para display ánodo común.
;              - Los datos también se reflejan en el puerto E (LATE).
;===============================================================================

    #include <xc.inc>                ; Librería principal de ensamblador PIC-AS

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF              ; Deshabilita conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40          ; Rutina para inicializar el MCU
    #define UartRead   0x42          ; Rutina para lectura UART
    #define UartWrite  0x44          ; Rutina para escritura UART
    #define LED1       LATD,1,A      ; LED indicador de actividad

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0x0000
DelayCounter:   DS 3                 ; Contador de retardo (3 bytes)
CONTADOR:       DS 1                 ; Contador principal
SIMBOLO:        DS 1                 ; Variable para almacenar carácter recibido

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    PSECT resetVec, space=2
    ORG 0x0800
MAIN:
    CALL    InitSys                  ; Inicializa UART y sistema
    CLRF    TRISE, A                 ; Puerto E como salida
    CLRF    LATE, A                  ; Apaga LEDs
    CLRF    CONTADOR, A              ; Limpia contador

    MOVLW   16                       ; 16 posiciones de tabla (0?F)
    MOVWF   CONTADOR, A

    CALL    DELAY                    ; Espera inicial
    BTG     LED1                     ; Cambia el estado del LED1

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    BANKSEL PCL                      ; Selecciona banco correcto para PCL
    MOVLW   HIGH TablaMensaje        ; Parte alta de dirección de tabla
    MOVWF   PCLATH, B                ; Carga en PCLATH

;--- Espera un carácter '+' para avanzar ---
TECLA:
    CALL    UartRead                 ; Lee dato desde UART
    MOVWF   SIMBOLO, A
    MOVLW   '+'                      ; Verifica si el carácter es '+'
    CPFSEQ  SIMBOLO, A
    GOTO    TECLA                    ; Si no es '+', sigue esperando

;--- Accede al valor de la tabla ---
    DECF    CONTADOR, W, A           ; W = índice actual de la tabla
    RLNCF   WREG, W, A               ; Multiplica índice *2 (RETLW ocupa 2 bytes)
    CALL    TablaMensaje             ; Recupera valor desde tabla (W = código)
    MOVWF   LATE, A                  ; Refleja el valor en puerto E (display)
    CALL    UartWrite                ; Envía el valor por UART

;--- Control del contador ---
    DECFSZ  CONTADOR, F, A           ; ¿Llega a cero?
    GOTO    LOOP                     ; No ? sigue mostrando
    GOTO    MAIN                     ; Sí ? reinicia el ciclo

;===============================================================================
; RUTINA DE RETARDO (Delay)
;===============================================================================
DELAY:
    MOVLW   0x60
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

;===============================================================================
; TABLA DE CÓDIGOS PARA DISPLAY DE 7 SEGMENTOS (ÁNODO COMÚN)
;===============================================================================
    ORG 0x0A00
TablaMensaje:
    ADDWF   PCL, F, A                ; Ajusta la dirección de salto según índice
    RETLW   0x40                     ; 0
    RETLW   0xF9                     ; 1
    RETLW   0xA4                     ; 2
    RETLW   0xB0                     ; 3
    RETLW   0x99                     ; 4
    RETLW   0x92                     ; 5
    RETLW   0x82                     ; 6
    RETLW   0xF8                     ; 7
    RETLW   0x80                     ; 8
    RETLW   0x90                     ; 9
    RETLW   0x88                     ; A
    RETLW   0x83                     ; b
    RETLW   0xC6                     ; C
    RETLW   0xA1                     ; d
    RETLW   0x86                     ; E
    RETLW   0x8E                     ; F