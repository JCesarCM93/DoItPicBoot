PROCESSOR 18f27Q83
#include <xc.inc>
    
#define InitSys	    0x6C0    
#define InitPinOut  0x700
#define InitOscFrq  0x740
#define InitOscDiv  0x760
#define InitUart    0x780
#define UartRead    0x7C0
#define UartWrite   0x7E0
        
PSECT resetVec,space=2
org 0x800
    CALL    InitSys
LOOP:	
    CALL    UartRead     // read data from serial and save in WREG
    ADDLW   1            // add 1 unit of WREG
    Call    UartWrite    // send value
    GOTO    LOOP         // go to loop
