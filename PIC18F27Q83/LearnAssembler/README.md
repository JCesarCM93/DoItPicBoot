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

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/bbb5d2a8-ab07-4393-ae10-8372cb70729b)

10. Choose File Name and click “Finish” to create the file.

![image](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/cb7faa6e-712d-4e07-949f-02d7db61a036)
