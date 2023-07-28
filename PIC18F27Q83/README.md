![top (2)](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/d9b882d8-4355-435e-8c09-4c24c9135bb2)
![bot (2)](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/8b69ed8b-2f1b-4f8e-8759-9685c2c40291)


Bootloader contains assembler macros perform a similar function to the preprocessor's #define directive, in that 
they define a single identifier and their location counter to represent sequence of instructions and are very similar to functions .

Some assembler macros have arguments, and there are characters that have special meaning inside macro definitions.
```
#define InitSys	    0x6C0
#define InitPinOut  0x700
#define InitOscFrq  0x740
#define InitOscDiv  0x760
#define InitUart    0x780
#define UartRead    0x7C0
#define UartWrite   0x7E0
```

The sections below shows macros description, instructions that make up and an exaple.
## InitPinOut
It's used to initialize the minimal hardware; LED1, LED2, BUTTON, TX and RX pins.

    BANKSEL ANSELA
    SETF    ANSELA
    BCF     ANSELA,7,B //BUTTON
    SETF    ANSELB
    SETF    ANSELC
    BCF     ANSELC,4,B //UART RX PIN
    
    MOVLW   0b10011111 //LED1 LED2
    MOVWF   TRISA,A
    SETF    TRISB
    MOVLW   0b11011111 //UART TX PIN
    MOVWF   TRISC,A
    
    MOVLW   0b10011111 //LED1 LED2
    MOVWF   PORTA,A
    SETF    PORTB
    SETF    PORTC

e.g.
```
CALL InitPinOut
```
## InitOscFrq
It's used to initialize the oscillator frequency. Put the value in WREG then call macro. The configured value shows in the following table. The macro sets oscillator division to 1 before the return.

| Value | Frequency |
| --- | --- |
| 8 | 64MHz |
| 7 | 48MHz |
| 6 | 32MHz |
| 5 | 16MHz |
| 4 | 12MHz |
| 3 | 8MHz |
| 2 | 4MHz |
| 1 | 2MHz |
| 0 | 1MHz |

    BANKSEL OSCCON1
    MOVWF   OSCFRQ,B
    CLRF    OSCTUNE,B
    MOVLW   0b00000000
    CALL    InitOscDiv
e.g.
```
MOVLW  8            //configure Osc @64MHz
CALL   InitOscFrq   //and set OscDiv:1
```

## InitOscDiv
It's used to configure the oscillator division. Put the value in WREG then call macro. The configured value shows in the following table.

| Value | Division value |
| --- | --- |
| 0 | 1 |
| 1 | 2 |
| 2 | 4 |
| 3 | 8 |
| 4 | 16 |
| 5 | 32 |
| 6 | 64 |
| 7 | 128 |
| 8 | 256 |
| 9 | 512 |


    BANKSEL OSCCON1
    ANDLW   0b00001111
    IORLW   0b01100000
    MOVWF   OSCCON1,B
    CLRF    OSCCON3,B
    CLRF    OSCEN,B

e.g.
```
MOVLW  2            //configure Osc @32MHz
CALL   InitOscFrq   //and set OscDiv:1
MOVLW  6            //Divide Fosc/64
CALL   InitOscDiv   //500KHz internal logic
```
## InitUart
it's used to initializing the UART module, TX RX pins and BaudRate. Put the value in WREG then call macro. The following formula helps to calculation of desired baud rate.

```math
BaudRate=Fosc/(4*(value+1))
```

    BANKSEL U1CON0
    MOVWF   U1BRGL,B
    CLRF    U1BRGH,B
    CLRF    U1FIFO,B
    CLRF    U1UIR,B
    CLRF    U1ERRIR,B
    CLRF    U1ERRIE,B    
    //UART1 pin configuration
    MOVLW   0b11011111
    MOVWF   TRISC,A
    BANKSEL ANSELC
    BCF	    ANSELC,4,B
    BANKSEL RB5PPS
    MOVLW   0x20
    MOVWF   RC5PPS,B;RC5->UART1:TX1
    MOVLW   0x14
    MOVWF   U1RXPPS,B;RC4->UART1:RX1
    //UART1 configuration
    BANKSEL U1CON0
    MOVLW   0xB0
    MOVWF   U1CON0,B
    MOVLW   0x80
    MOVWF   U1CON1,B
    CLRF    U1CON2,B

e.g.
```
MOVLW  159        //If Fosc @64MHz
CALL   InitUart   //UART is configured @100Kbps
```
## UartRead
Reads the input character, doesn't return until a character appears.

    UartRead:
    BTFSS   U1RXIF
    BRA     UartRead
    BANKSEL U1RXB
    MOVF    U1RXB,W

e.g.
```
CALL   UartRead // read RX value and saved in WREG
```
## UartWrite

Waits if there is a transmission pending, then writes the character.

    UartWrite:
    BTFSS   U1TXIF
    BRA     UartWrite
    BANKSEL U1TXB
    MOVWF   U1TXB


e.g.
```
MOVLW  '3'
CALL   UartWrite // send WREG value to TX
```
## InitSys
Calls default macros to initialize the system for the most examples.

    CALL    InitPinOut
    MOVLW   0b00001000
    CALL    InitOscFrq
    MOVLW   159 //100 000 bps
    CALL    InitUart	

e.g.
```
CALL   InitSys // send WREG value to TX
```
