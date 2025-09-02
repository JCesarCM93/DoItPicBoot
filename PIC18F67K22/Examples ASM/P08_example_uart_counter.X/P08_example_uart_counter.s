;===============================================================================
; File:        P08_example_uart_counter.s
; Author:      GFT
; Date:        2025-09-02
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Contador controlado por UART. Al recibir '+' se env�a el valor
;              actual del contador y luego se incrementa. Si CONTADOR > 10,
;              se reinicia a 0.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACI�N DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                ; Deshabilita conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS / CONSTANTES
;===============================================================================
    #define InitSys    0x40            ; Direcci�n rutina de inicializaci�n
    #define UartRead   0x42            ; Direcci�n rutina de lectura UART
    #define UartWrite  0x44            ; Direcci�n rutina de escritura UART

;===============================================================================
; VARIABLES (ubicadas en direcci�n 0x0)
;===============================================================================
    ORG 0X0
CONTADOR:   DS 1                        ; Variable que guarda el conteo (8 bits)
SIMBOLO:    DS 1                        ; Variable para almacenar el car�cter recibido

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    PSECT  RESETVEC,SPACE=2
    ORG 0x800
MAIN:
    CALL    InitSys                     ; Inicializa puertos/UART/configs necesarias
    CLRF    CONTADOR, A                 ; Inicializa CONTADOR = 0

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    CALL    UartRead                    ; Lee el car�cter desde UART
    MOVWF   SIMBOLO, A                  ; Guarda el car�cter en SIMBOLO

;-------------------------------------------------------------------------------
; COMPARACI�N: �ES EL CAR�CTER '+'?
;-------------------------------------------------------------------------------
COMPARA_CON_SIGNO_MAS:
    MOVLW   '+'                         ; ASCII '+' = 0x2B
    CPFSEQ  SIMBOLO, A                  ; Si SIMBOLO == '+', seguir; si no, saltar
    GOTO    LOOP                        ; No es '+', volver al bucle principal

;-------------------------------------------------------------------------------
; SI ES '+': ENVIAR EL VALOR ACTUAL Y LUEGO INCREMENTAR
; NOTA: Se env�a el valor ANTES de incrementarlo ? mantiene tu l�gica original
;-------------------------------------------------------------------------------
INCREMENTO:
    MOVF    CONTADOR, W, A              ; Carga CONTADOR en WREG
    CALL    UartWrite                   ; Env�a el valor actual del contador por UART

    INCF    CONTADOR, F, A              ; Incrementa CONTADOR (resultado en la misma variable)

    MOVLW   10                          ; L�mite = 10 (decimal)
    CPFSGT  CONTADOR, A                 ; �CONTADOR > 10 ?
    GOTO    LOOP                        ; Si NO es mayor (<=10) volver al loop
    GOTO    DETENER                     ; Si es mayor, saltar a DETENER

;-------------------------------------------------------------------------------
; REINICIO DEL CONTADOR SI SUPERA 10
;-------------------------------------------------------------------------------
DETENER:
    CLRF    CONTADOR, A                 ; Reinicia CONTADOR = 0
    GOTO    LOOP                        ; Volver al bucle principal

;===============================================================================
; FIN DEL PROGRAMA
;===============================================================================
    END
