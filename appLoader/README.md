# appLoader

![appLoader](https://github.com/JCesarCM93/DoItPicBoot/assets/40074332/fbb16c3f-7b9c-41e9-ad50-bee30df70285)

Version: 0.1.

Release date: 2023-july-23.

The appLoader utility is a GUI that allows you write the memories of pic microcontrollers over USB using their bootloaders. The input (file) parsing algorithm is compatible with all PIC18 INTEL Hex files produced by the MPLAB XC8 compiler.

The serial interface does not support hardware handshake.

This utility currently supports the following Boards:

- PIC18F27Q83 R0.1 DevBoard

Install CH340E driver. CH340E is a TTL (serial) to USB converter and vice versa.

Install appLoader.

---------------------------------------------------------
# PROGRAM HEX FILE
- Plug one end of the USB cable into Board and plug the other end into a USB port on your PC
- Use the COM Port Number drop down list to select the serial port of board.
- To open a compiled program (hex file) to be programmed into the target device, select Open File. Browse for the hex file and click Open. Click Program the device will be erased and programmed with the hex code previously imported.
## Auto program
This feature allows the appLoader to automatically read a hex file and write it to a connected board when the hex file is updated.

To use this feature, check Auto program. After selecting a file, it will be written to the device. The appLoader will now monitor the selected hex file for updates. When the file has been updated, the application will automatically re-read the hex file and write to the Board.

To stop using this feature, uncheck Auto program.

If an error is encountered during hex file importing or device programming, the application will not program.

## Fast Erase
When checked, the appLoader will attempt to erase the device as fast as possible, erasing only the space for programing. When unchecked, the appLoader erase all ROM.

---------------------------------------------------------
# SERIAL TERMINAL
The appLoader application include the Serial Terminal tool. This allows appLoader to be used a serial UART Terminal for communicating with a PIC microcontroller. Potential uses include.

- Displaying debug text output from the microcontroller
- Developing and debugging a microcontroller UART interface
- Interfacing with and sending commands to the microcontroller during development
- The tool supports full duplex asynchronous serial communications from 50bps to 2Mbps baud, including custom non-standard baud rates.

## Setting the Baud Rate and Connecting
- Plug one end of the USB cable into Board and plug the other end into a USB port on your PC
- change to desired custom baud rate for the serial port.
- Use the COM Port Number drop down list to select the serial port of board.
- Select Open. Once the serial interface has been enabled, it may be disabled by clicking Disconnect. The baud rate may only be changed while the interface is disconnected.

The UART Tool has three modes: ASCII, HEX and BIN.
The current mode selected is displayed by the buttons on the upper left hand of the terminal. The button corresponding to the active mode will be displayed checked.

- ASCII mode: Serial bytes received from the Board are displayed as ASCII characters in the terminal. All bytes are displayed consecutively. To display a new line, the target UART must transmit the character values 0x0D (carriage return) or 0x0A (line feed) in sequence.
- HEX Mode: Displays the hex values of bytes received from the target’s UART in the terminal.
- BIN Mode: Displays the BIN values of bytes received from the target’s UART in the terminal.

## Bytes may be transmitted in three modes
- ASCII: Send the characters of the BOX
- ASCII+CR:Send the characters of the BOX. Will automatically transmit the carriage return (0x0D) character at the end of a string when Send is clicked.
- ASCII+LF: Send the characters of the BOX. Will automatically transmit the line feed (0x0A) character at the end of a string when Send is clicked.
- ASCII+CR+LF: Send the characters of the BOX. Will automatically transmit the carriage return (0x0D) and line feed (0x0A) characters at the end of a string when Send is clicked.
- HEX: Send the hex values of the BOX. write a sequence of one or more hex values in one of the boxes (ex. 02 04 56)
- BIN: Send the bin values of the BOX. write a sequence of one or more bin values in one of the boxes (e.g., 011 01010100)
## Clear Screen
Click the Clear button to clear all text or data from the terminal display window.
