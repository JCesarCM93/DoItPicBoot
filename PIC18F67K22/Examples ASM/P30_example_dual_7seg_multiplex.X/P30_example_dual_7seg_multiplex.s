;===============================================================================
; File:        P30_example_dual_7seg_multiplex.s
; Author:      GFT
; Date:        2025-10-21
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Control de dos displays de 7 segmentos multiplexados (ánodo común).
;              - Cuenta de 00 a 99 con refresco dinámico.
;              - Multiplexación mediante cambio rápido entre displays.
;              - Los datos de segmentos se envían por LATE.
;===============================================================================

    #include <xc.inc>                ; Librería principal de ensamblador PIC-AS

;===============================================================================
; CONFIGURACIÓN DEL MCU
;===============================================================================
    CONFIG  XINST = OFF              ; Deshabilita el conjunto extendido de instrucciones

;===============================================================================
; DEFINICIONES DE RUTINAS Y CONSTANTES
;===============================================================================
    #define InitSys    0x40          ; Rutina de inicialización del sistema
    #define UartRead   0x42          ; Lectura UART (no usada aquí)
    #define UartWrite  0x44          ; Escritura UART (no usada aquí)
    #define LED1       LATD,1,A      ; LED indicador de estado

;--- Control de displays ---
    #define DISP_DEC   LATF,2,A      ; Control de display de decenas
    #define DISP_UNI   LATF,1,A      ; Control de display de unidades

;===============================================================================
; VARIABLES (ubicadas en dirección 0x0)
;===============================================================================
    ORG 0x0000
UNIDADES:       DS 1                 ; Dígito de unidades
DECENAS:        DS 1                 ; Dígito de decenas
DelayCounter2:  DS 1
DelayCounter1:  DS 1
DelayCounter:   DS 1
MULTIPLEXACION: DS 1                 ; Contador del ciclo de multiplexado
FLAG:           DS 1                 ; Bandera de selección de display

;===============================================================================
; VECTOR DE RESET & PROGRAMA PRINCIPAL
;===============================================================================
    PSECT resetVec, space=2
    ORG 0x0800
MAIN:
    CALL    InitSys                  ; Inicializa MCU y periféricos

    ;--- Configuración de puertos ---
    CLRF    TRISE, A                 ; Puerto E como salida (segmentos)
    SETF    LATE, A                  ; Apaga todos los segmentos
    CLRF    TRISF, A                 ; Puerto F como salida (control displays)
    CLRF    LATF, A                  ; Ambos displays apagados

    ;--- Variables iniciales ---
    CLRF    UNIDADES, A
    CLRF    DECENAS, A
    CLRF    FLAG, A

;===============================================================================
; BUCLE PRINCIPAL
;===============================================================================
LOOP:
    ;--- Multiplexación: refresco de displays durante 500 ms aprox ---
    MOVLW   125                      ; 125 ciclos × ~4 ms ? 500 ms
    MOVWF   MULTIPLEXACION, A

CICLO_ESPERA:
    CALL    Actualizar_Displays
    CALL    DELAY
    DECFSZ  MULTIPLEXACION, F, A
    GOTO    CICLO_ESPERA

    ;--- Incremento de unidades ---
    INCF    UNIDADES, F, A
    MOVLW   9
    CPFSGT  UNIDADES, A              ; ¿UNIDADES > 9?
    GOTO    LOOP                     ; No ? sigue contando
    CLRF    UNIDADES, A              ; Sí ? reinicia unidades

    ;--- Incremento de decenas ---
    INCF    DECENAS, F, A
    BTG     LED1                     ; Parpadea LED al cambiar decenas
    MOVLW   9
    CPFSGT  DECENAS, A               ; ¿DECENAS > 9?
    GOTO    LOOP                     ; No ? sigue contando
    CLRF    DECENAS, A               ; Sí ? reinicia y vuelve a 00
    GOTO    LOOP

;===============================================================================
; SUBRUTINA: ACTUALIZAR DISPLAYS (MULTIPLEXADO)
;===============================================================================
Actualizar_Displays:

    BTFSS   FLAG, 0, A
    GOTO    Mostrar_Unidades

Mostrar_Decenas:
    BANKSEL PCL
    MOVLW   HIGH TablaMensaje
    MOVWF   PCLATH, B

    BCF     DISP_DEC                 ; Activa decenas
    BSF     DISP_UNI                 ; Apaga unidades

    MOVF    DECENAS, W, A
    RLNCF   WREG, W, A
    CALL    TablaMensaje
    MOVWF   LATE, A

    BCF     FLAG, 0, A               ; Cambia bandera
    RETURN

Mostrar_Unidades:
    BANKSEL PCL
    MOVLW   HIGH TablaMensaje
    MOVWF   PCLATH, B

    BCF     DISP_UNI                 ; Activa unidades
    BSF     DISP_DEC                 ; Apaga decenas

    MOVF    UNIDADES, W, A
    RLNCF   WREG, W, A
    CALL    TablaMensaje
    MOVWF   LATE, A

    BSF     FLAG, 0, A               ; Cambia bandera
    RETURN

;===============================================================================
; SUBRUTINA: DELAY (~4 ms por ciclo)
;===============================================================================
DELAY:
    MOVLW   48
    MOVWF   DelayCounter2, A

RET0:
    MOVLW   22
    MOVWF   DelayCounter1, A

RET1:
    MOVLW   10
    MOVWF   DelayCounter, A

RET2:
    DECFSZ  DelayCounter, F, A
    GOTO    RET2
    DECFSZ  DelayCounter1, F, A
    GOTO    RET1
    DECFSZ  DelayCounter2, F, A
    GOTO    RET0
    RETURN

;===============================================================================
; TABLA DE CÓDIGOS PARA DISPLAY DE 7 SEGMENTOS (ÁNODO COMÚN)
;===============================================================================
    ORG 0x0A00
TablaMensaje:
    ADDWF   PCL, F, A
    RETLW   0x40    ; 0
    RETLW   0xF9    ; 1
    RETLW   0xA4    ; 2
    RETLW   0xB0    ; 3
    RETLW   0x99    ; 4
    RETLW   0x92    ; 5
    RETLW   0x82    ; 6
    RETLW   0xF8    ; 7
    RETLW   0x80    ; 8
    RETLW   0x90    ; 9