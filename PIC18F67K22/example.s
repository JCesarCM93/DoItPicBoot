;===============================================================================
; File:        main.s
; Author:      JC93
; Date:        2025-06-14
; MCU:         PIC18F67K22
; Toolchain:   MPLAB X v6.25 + PIC-AS (v3.0)
; Description: Alternates pin outputs in order, UART writes button state.
;===============================================================================
    #include <xc.inc>
    #define InitSys	0x40
    #define UartRead	0x42 
    #define UartWrite	0x44
    #define LED1	LATD,1,A
    #define LED2	LATD,0,A
    #define BUTTON	PORTB,0,A

;===============================================================================
; VARIABLES
;===============================================================================
            //PSECT udata_acs
	    ORG 0X0
DelayCounter:	DS 3 ;3 byte for DelayCounter

;===============================================================================
; MAIN PROGRAM
;===============================================================================
     PSECT resetVec,space=2
    ORG	    0x800   
main:
    CALL    InitSys   
loop:
    CALL    DELAY
    BTG	    LED1
    CALL    DELAY
    BTG	    LED2
    MOVLW   'R'
    BTFSS   BUTTON
    MOVLW   'P'
    CALL    UartWrite
    GOTO    loop

DELAY:
    MOVLW   0x10
    MOVWF   DelayCounter+1,A
    MOVLW   0x1
    MOVWF   DelayCounter,A
    MOVLW   0x1
RET2:	
    DECFSZ  WREG,F,A  
    BRA	    RET2	
    DECFSZ  DelayCounter,f,A
    BRA	    RET2
    DECFSZ  DelayCounter+1,f,A
    BRA	    RET2
    RETURN
     
