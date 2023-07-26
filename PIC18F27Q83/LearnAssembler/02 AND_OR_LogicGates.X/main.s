PROCESSOR 18f27Q83
#include <xc.inc>
    
#define InitSys	    0x6C0    
#define InitPinOut  0x700
#define InitOscFrq  0x740
#define InitOscDiv  0x760
#define InitUart    0x780
#define UartRead    0x7C0
#define UartWrite   0x7E0
        
org 0x0
Inputs:
 DS 1 ;1 byte for IN
Outputs:
 DS 1 ;1 byte for Out
 
PSECT resetVec,space=2
org 0x800
    CALL    InitSys
LOOP:	
    CALL    UartRead     // read data from serial and save in WREG
    
    MOVWF   Inputs,A	 // save data in Inputs
    CLRF    Outputs,A	 // Clear outputs
    
//and logic
    BTFSS   Inputs,0,A	 // bit 0 test, skip if 1
    GOTO    OR_Logic	 // if bit is 0 AND logic is false
    BTFSS   Inputs,1,A   // bit 1 test, skip if 1
    GOTO    OR_Logic	 // if bit is 0 AND logic is false
    BSF	    Outputs,0,A  // bit 0 and 1 are true, and logis is true
//or logic
OR_Logic:
    BTFSC   Inputs,2,A   // bit 2 test, skip if 0
    BSF	    Outputs,1,A  // if bit is 1 OR logic is true
    BTFSC   Inputs,3,A   // bit 3 test, skip if 0
    BSF	    Outputs,1,A  // if bit is 1 OR logic is true
    
    MOVF    Outputs,0,0  // load Outputs in WREG
    Call    UartWrite    // send value
    GOTO    LOOP         // go to loop


