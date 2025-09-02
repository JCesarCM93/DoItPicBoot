;===============================================================================
; File:        P03_example_uart_signcheck.s
; Author:      GFT
; Date:        2025-09-01
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Programa que recibe un dato por UART, verifica el bit N del
;              registro STATUS y env�a 'P' si el n�mero es positivo o 'N'
;              si es negativo.
;===============================================================================

    #include <xc.inc>                ; Librer�a principal de ensamblador PIC-AS

;===============================================================================
; CONFIGURACI�N DEL MCU
;===============================================================================
    CONFIG  XINST = OFF              ; Extended Instruction Set Enable bit:
                                     ; OFF = Conjunto de instrucciones extendido
                                     ; deshabilitado (modo cl�sico)

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40          ; Rutina para inicializar el MCU
    #define UartRead   0x42          ; Rutina para lectura de datos UART
    #define UartWrite  0x44          ; Rutina para escritura de datos UART

;===============================================================================
; VARIABLES (ubicadas en direcci�n 0x0)
;===============================================================================
    ORG     0x0000
NUMERO: DS 1                         ; Variable para guardar el dato recibido
NUM1:   DS 1                         ; Variable adicional (reservada para uso)

;===============================================================================
; VECTOR DE RESET Y PROGRAMA PRINCIPAL
;===============================================================================
    PSECT resetVec,space=2
    ORG     0x0800                   ; Direcci�n de inicio del programa en memoria
MAIN:
    CALL    InitSys                  ; Inicializa el sistema (puertos, UART, etc.)

LOOP:
    ;----------- LECTURA DE DATO POR UART ----------------
    CALL    UartRead                 ; Lee un dato y lo deja en WREG
    MOVWF   NUMERO, A                ; Guarda el valor recibido en NUMERO

    MOVF    NUMERO, W, A             ; Copia el valor a WREG para actualizar STATUS

    ;----------- VERIFICAR EL BIT N (STATUS<4>) -----------
    BTFSC   STATUS, 4, A             ; Si N=1 ? n�mero negativo
    GOTO    NEGATIVO                 ; Si N=0 ? n�mero positivo

POSITIVO:
    MOVLW   'P'                      ; C�digo ASCII para "positivo"
    CALL    UartWrite
    GOTO    LOOP

NEGATIVO:
    MOVLW   'N'                      ; C�digo ASCII para "negativo"
    CALL    UartWrite
    GOTO    LOOP

;===============================================================================
; FIN DEL PROGRAMA
;===============================================================================
    END

    
    