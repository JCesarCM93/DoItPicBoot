
# DevBoard PIC18F27Q83 - Macros y funciones ensamblador para bootloader

Este directorio contiene las macros en lenguaje ensamblador utilizadas para la inicialización y control del microcontrolador **PIC18F27Q83**, empleadas en el bootloader compatible con la utilidad **DoItPicBoot - AppLoader**.

Las macros implementan funciones de inicialización del sistema, manejo del UART, configuración del oscilador y control de pines, facilitando la programación y comunicación serial.

---

## Contenido

| Macro       | Descripción                                              |
|-------------|----------------------------------------------------------|
| InitSys     | Inicialización general del sistema (pins, oscilador, UART) |
| UartRead    | Lee un carácter desde UART (bloqueante)                   |
| UartWrite   | Envía un carácter por UART                                 |
| InitBoot    | Inicialización general del bootloader                     |
| InitSysIO   | Configura los pines básicos: LEDs, botones, TX y RX      |
| InitOscFrq  | Configura la frecuencia del oscilador                     |
| InitUart    | Inicializa el módulo UART con baudios especificos |

---

## Definición de macros

Las macros funcionan similar a directivas `#define` en C, asignando direcciones de memoria para bloques de instrucciones reutilizables y parametrizables.

```asm
#define InitSys     0x40
#define UartRead    0x42
#define UartWrite   0x44
```

---

## Descripción y ejemplos de macros

### InitSys

Inicializa el sistema usando macros por defecto para pines, oscilador y UART.

```asm
    BSF     TRISB, 0 ,A          ; RB0 input
    BCF     TRISD, 0 ,A          ; RD0 output
    BCF     LATD, 0 ,A           ; Clear RD0 - LED2
    BCF     TRISD, 1 ,A          ; RD1 output
    BCF     LATD, 1 ,A           ; Clear RD1 - LED2
    BCF     TRISC, 6 ,A          ; RC6 as output (TX)
    BSF     LATC, 6 ,A           ; Set TX high initially
    BSF     TRISC, 7 ,A          ; RC7 as input (RX)
    
    MOVLW   0b01110000           ; Set 64MHz
    MOVWF   OSCCON ,A            ; Set frequency
    MOVLW   0x00
    MOVWF   OSCCON2 ,A           ; Default secondary osc config
    MOVLW   0x40
    MOVWF   OSCTUNE ,A           ; Default tuning
    MOVLB   0x00
    CLRF    REFOCON ,A           ; Disable reference clock output
...
```

Uso:

```asm
CALL InitSys
```
---

### UartRead

Lee un carácter desde UART, bloqueando hasta que un dato esté disponible.

```asm
UartRead:
BTFSS   U1RXIF
BRA     UartRead
BANKSEL U1RXB
MOVF    U1RXB,W
```

Uso:

```asm
CALL UartRead   ; Dato leído queda en WREG
```

---

### UartWrite

Espera que el buffer de transmisión esté libre y envía el carácter en WREG.

```asm
UartWrite:
BTFSS   U1TXIF
BRA     UartWrite
BANKSEL U1TXB
MOVWF   U1TXB
```

Uso:

```asm
MOVLW  '3'
CALL   UartWrite   ; Envía el carácter '3'
```

---
