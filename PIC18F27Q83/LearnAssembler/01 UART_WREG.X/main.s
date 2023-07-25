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
    CALL    UartRead
    ADDLW   1
    Call    UartWrite
    GOTO    LOOP