;===============================================================================
; File:        P27_example_uart_table_message.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Ejemplo de uso de tablas en memoria de programa y envío por UART.
;              - Envía una secuencia de caracteres almacenada en una tabla.
;              - Control de iteración mediante un contador decreciente.
;              - Incluye parpadeo de LED como indicador de actividad.
;===============================================================================

    #include <xc.inc>                 ; Librería principal del ensamblador PIC-AS

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF               ; Deshabilita el conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40           ; Rutina para inicializar el sistema
    #define UartRead   0x42           ; Rutina de lectura UART
    #define UartWrite  0x44           ; Rutina de escritura UART
    #define LED1       LATD,1,A       ; LED indicador de actividad (RD1)

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0x0
    PSECT  resetVec, space=2
DelayCounter:   DS 3                  ; Contador de retardo (3 bytes)
CONTADOR:       DS 1                  ; Contador para la iteración de la tabla

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    ORG 0x0800
MAIN:
    CALL    InitSys                   ; Inicializa el sistema (UART, puertos, etc.)

;--- Inicializa el contador ---
    MOVLW   11                        ; 11 caracteres en la tabla
    MOVWF   CONTADOR, A

    CALL    DELAY                     ; Espera inicial
    BTG     LED1                      ; Cambia el estado del LED1 (parpadeo)

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    ;--- Configura el acceso a la tabla ---
    BANKSEL PCL                       ; Selecciona banco de PCL
    MOVLW   HIGH TablaMensaje         ; Carga parte alta de la dirección de la tabla
    MOVWF   PCLATH, B                 ; Carga en PCLATH para salto correcto entre páginas

    ;--- Decrementa contador y prepara índice ---
    DECF    CONTADOR, W, A            ; W = índice de la tabla (de 10 a 0)
    RLNCF   WREG, W, A                ; Multiplica índice por 2 (cada RETLW = 2 bytes)

    CALL    TablaMensaje              ; Recupera el carácter correspondiente
    CALL    UartWrite                 ; Envía carácter por UART

    DECFSZ  CONTADOR, F, A            ; ¿El contador llegó a 0?
    GOTO    LOOP                      ; No ? continúa enviando caracteres
    GOTO    MAIN                      ; Sí ? reinicia el programa (bucle infinito)

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
; TABLA DE CARACTERES A ENVIAR POR UART (en orden invertido)
;===============================================================================
    ORG     0x0A00
TablaMensaje:
    ADDWF   PCL, F, A                 ; Ajusta el salto según el índice recibido en WREG
    RETLW   '_'                       ; 0
    RETLW   'O'                       ; 1
    RETLW   'D'                       ; 2
    RETLW   'N'                       ; 3
    RETLW   'U'                       ; 4
    RETLW   'M'                       ; 5
    RETLW   ' '                       ; 6
    RETLW   'A'                       ; 7
    RETLW   'L'                       ; 8
    RETLW   'O'                       ; 9
    RETLW   'H'                       ; 10