;===============================================================================
; File:        P09_example_uart_compare.s
; Author:      GFT
; Date:        2025-09-02
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Comparaci�n de dos valores recibidos por UART. 
;              El programa lee dos caracteres (A y B) y determina si:
;              - A = B ? Env�a "A=B"
;              - A > B ? Env�a "A>B"
;              - A < B ? Env�a "A<B"
;              Se agregan espacios para mejor visualizaci�n.
;===============================================================================

    #include <xc.inc>

;===============================================================================
; CONFIGURACI�N DEL MCU
;===============================================================================
    CONFIG  XINST = OFF                 ; Deshabilita conjunto de instrucciones extendido

;===============================================================================
; DEFINICIONES DE RUTINAS
;===============================================================================
    #define InitSys    0x40             ; Rutina de inicializaci�n del MCU
    #define UartRead   0x42             ; Rutina de lectura UART
    #define UartWrite  0x44             ; Rutina de escritura UART

;===============================================================================
; VARIABLES (ubicadas en direcci�n 0x0)
;===============================================================================
    ORG 0X0
VARIABLEA:  DS 1                        ; Primer valor le�do
VARIABLEB:  DS 1                        ; Segundo valor le�do

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    PSECT  RESETVEC,SPACE=2
    ORG 0x800    
MAIN: 
    CALL    InitSys                     ; Inicializa el sistema
    CLRF    VARIABLEA, A
    CLRF    VARIABLEB, A

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    CALL    UartRead                    ; Lee primer dato desde UART
    MOVWF   VARIABLEA, A                ; Guarda en VARIABLEA
    CALL    UartRead                    ; Lee segundo dato desde UART
    MOVWF   VARIABLEB, A                ; Guarda en VARIABLEB

;-------------------------------------------------------------------------------
; COMPARACI�N: �A = B?
;-------------------------------------------------------------------------------
COMPARA_S_IGUALES:  
    MOVF    VARIABLEB, W, A             
    CPFSEQ  VARIABLEA, A                ; Si A == B salta a S_IGUALES
    GOTO    COMPARA_V_MAYOR             ; Si no, sigue comparaciones

S_IGUALES:
    MOVLW   ' '                         ; Espacios para visualizaci�n
    CALL    UartWrite
    MOVLW   ' '   
    CALL    UartWrite
    MOVLW   'A'                         ; Imprime "A=B"
    CALL    UartWrite
    MOVLW   '=' 
    CALL    UartWrite
    MOVLW   'B' 
    CALL    UartWrite
    MOVLW   ' '   
    CALL    UartWrite
    MOVLW   ' '   
    CALL    UartWrite
    GOTO    LOOP  

;-------------------------------------------------------------------------------
; COMPARACI�N: �A > B?
;-------------------------------------------------------------------------------
COMPARA_V_MAYOR:
    MOVF    VARIABLEB, W, A
    CPFSGT  VARIABLEA, A                ; Si A > B salta a ES_MAYOR
    GOTO    COMPARA_V_MENOR             ; Si no, revisar si A < B

ES_MAYOR: 
    MOVLW   ' '                         ; Espacios para visualizaci�n
    CALL    UartWrite
    MOVLW   ' '   
    CALL    UartWrite
    MOVLW   'A'                         ; Imprime "A>B"
    CALL    UartWrite
    MOVLW   '>' 
    CALL    UartWrite
    MOVLW   'B' 
    CALL    UartWrite
    MOVLW   ' '   
    CALL    UartWrite
    MOVLW   ' '   
    CALL    UartWrite
    GOTO    LOOP  

;-------------------------------------------------------------------------------
; COMPARACI�N: �A < B?
;-------------------------------------------------------------------------------
COMPARA_V_MENOR:
    MOVF    VARIABLEB, W, A
    CPFSLT  VARIABLEA, A                ; Si A < B salta a ES_MENOR
    GOTO    LOOP                        ; Si ninguna condici�n, vuelve al loop

ES_MENOR: 
    MOVLW   ' '                         ; Espacios para visualizaci�n
    CALL    UartWrite
    MOVLW   ' '   
    CALL    UartWrite
    MOVLW   'A'                         ; Imprime "A<B"
    CALL    UartWrite
    MOVLW   '<' 
    CALL    UartWrite
    MOVLW   'B' 
    CALL    UartWrite
    MOVLW   ' '                         ; Espacios de salida
    CALL    UartWrite
    MOVLW   ' '   
    CALL    UartWrite
    GOTO    LOOP  

;===============================================================================
; FIN DEL PROGRAMA
;===============================================================================
    END
