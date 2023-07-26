The content of document.
- Create New project
- Example 01 UART_WREG
- Example 02 AND_OR_LogicGates

To program a microcontroller the following steps are necessary

- to Download MplabX https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide
- to Download XC8 https://www.microchip.com/en-us/tools-resources/develop/mplab-xc-compilers
- manual to install XC8 https://microchipdeveloper.com/mplabx:installation
- manual to install XC8 https://microchipdeveloper.com/xc8:installation

# CREATE A NEW PROJECT
1. in Start Menu, Find “MPLAB X IDE” and run it.
2. Select File>“New Project”.
3. On screen of wizard, select the “Microchip Embedded” category and select “Standalone Project”. Click “Next”.

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/8877f8a4-4c9a-4cd6-8f18-87b1774ed017)

5. In Device, type the name of the microcontroller “PIC18F27Q83”. Click “Next”.

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/de8c337c-90a9-45dc-b341-443c4618a1de)

6. For the compiler, select pic-as.

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/17bde470-7821-4d07-bc61-89644134ed27)

7. Choose Project Name and the folder you want it to be in. Click “Finish” to create the project.

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/1ab0153f-9485-48df-9ced-ec30401f2d54)

8. Now we need to create the .s source file. Locate the “Projects” pane. If the “Projects” pane is not visible,
you can open it by opening the “Window” menu and selecting “Projects”.
Left-click the “+” sign next to “Source Files” to expand it and verify that your project has no source files yet.
Then right-click on “Source Files”, select “New”, and then select “Other...”.

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/911aaf8c-3511-4331-80d7-e588aa4ab31e)

9. On the first screen of the New File wizard, select the “Assembler” category and then select “AssemblyFile.s”. Click “Next”.

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/555e25f0-cc9e-4aea-ad2b-f3980b8506de)

11. Choose File Name and click “Finish” to create the file.

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/cb7faa6e-712d-4e07-949f-02d7db61a036)

# Example 01 UART_WREG

This example shows how to send data to the board and it return a value.

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/d8553d28-c8fa-4620-9cad-ff07dfc895fc)

Paste this code into .s file on MplabX then press F11 to compille the code

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
      
![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/b4efb801-5809-4f2c-8abf-6184ce7e8921)

Plug one end of the USB cable into Board and plug the other end into a USB port on your PC. open appLoader aplication and follow the next steps.

1. Use the COM Port Number drop down list to select the serial port of board.
2. Select Open. Once the serial interface has been enabled.
3. To open a compiled program (hex file) to be programmed into the target device, select Open File. Browse for the hex file and click Open.
4. Click Program the device will be erased and programmed with the hex code previously imported.
5. Change Serial Terminal to BIN mode.
6. Type "00000001" in the first Comand Box
7. Change the first Comand Box to BIN mode.
8. Click send

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/173f5f82-79ed-46fe-af28-e1be546078a4)

# Example 02 AND_OR_LogicGates

This example shows how implement AND OR ligic gates as shown in the following image

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/120e7f2c-b9f9-4fed-a06b-6e11d6db6d81)

Paste this code into .s file on MplabX then press F11 to compille the code

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

Program the board and send values for test the code.

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/20e2bedb-a548-4c6e-a6aa-9176dc1afd0b)
