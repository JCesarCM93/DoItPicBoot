# 📦 AppLoader V0_4 – Utilidad AppLoader
**Autor:** JC93  
**Fecha de lanzamiento:** 03 de octubre de 2026  

---

## 🧭 Descripción general

**AppLoader** es una utilidad gráfica (GUI) para programar microcontroladores PIC a través de USB utilizando un bootloader personalizado. Es compatible con archivos `.hex` generados por el compilador **MPLAB XC8** en formato **Intel HEX**.

La comunicación se realiza mediante UART sin control de flujo por hardware, es decir, **no utiliza señales de sincronización como DTR o RTS**, lo que permite trabajar con convertidores USB-Serial simples como CH340E.

Adicionalmente, la aplicación cuenta con una herramienta de **terminal serial integrada**, útil para monitoreo, depuración y desarrollo de interfaces UART.

---

## 🛠️ Hardware compatible

- **DevBoard PIC18F67K22 R0.1**  
  Se requiere la instalación del controlador **CH340E**, que convierte la señal USB a nivel TTL (UART).

---

## 🔧 Instalación

1. **Instala el controlador CH340E**  
   Necesario para establecer comunicación USB-Serial con la tarjeta.

2. **Instala AppLoader**  
   Descarga el **ejecutable directamente desde el repositorio**.  
   > *No es necesario compilar desde el código fuente.*

---

## ⚙️ Conexión y programación de un archivo HEX

1. **Conecta la tarjeta**  
   Conecta el cable USB entre la tarjeta y la computadora. La tarjeta entrará automáticamente en modo **terminal serial**.

2. **Selecciona el puerto COM**  
   En la interfaz de la aplicación **AppLoader**, elige el puerto correspondiente a la tarjeta conectada.

3. **Carga y programa el archivo HEX**  
   Haz clic en **Open File**, selecciona tu archivo `.hex` y ábrelo.  
   El dispositivo será programado automáticamente.  
   Una vez finalizada la programación, la tarjeta volverá al modo **terminal serial** de forma automática.  
   Este ciclo se repetirá cada vez que el archivo `.hex` sea actualizado y reprogramado.

---

## ⚡ Auto programación

La función de auto programación permite que AppLoader detecte cambios en un archivo `.hex` y reprograme automáticamente la tarjeta.

- Esta opción se encuentra **activada por defecto**.
- Una vez seleccionado el archivo `.hex`, AppLoader lo monitorea continuamente.
- Cada vez que se detecta un cambio en el archivo, se vuelve a cargar y programa el dispositivo.
- Para desactivar esta función, desmarca la casilla **Auto program**.

> ⚠️ Si ocurre un error durante la carga del archivo o la programación, el proceso será cancelado.

---

## 🧽 Borrado rápido (Fast Erase)

- Esta opción está **activada por defecto**.
- **Con Fast Erase activado**: se realiza un **borrado completo** de la memoria **ROM y EEPROM**, lo que puede demorar un poco más.
- **Con Fast Erase desactivado**: se borra únicamente la sección de memoria necesaria para escribir el nuevo código, funcionando como un **formateo rápido**, similar a Windows.

---

## 🖥️ Terminal serial integrada

La aplicación AppLoader incluye una herramienta de terminal serial UART útil para:

- Mostrar mensajes de depuración enviados por el microcontrolador.
- Probar comunicación UART.
- Enviar comandos al dispositivo durante el desarrollo.

---

### 🔌 Conexión

1. Conecta la tarjeta al PC mediante el cable USB.
2. Selecciona el puerto COM en AppLoader.
3. Establece la velocidad de baudios deseada (solo puede cambiarse si el puerto está desconectado).
4. Haz clic en **Open** para iniciar la comunicación, o en **Disconnect** para finalizarla.

---

## 🎛️ Modos disponibles

La terminal permite visualizar y transmitir datos en diferentes formatos.  

### Modos de recepción:

- **ASCII**: Muestra los bytes recibidos como caracteres ASCII. Para un salto de línea, el microcontrolador debe enviar `0x0D` (carriage return) o `0x0A` (line feed).
- **HEX**: Muestra los bytes recibidos en formato hexadecimal.
- **BIN**: Muestra los bytes recibidos en formato binario.
- **DEC**: Muestra los bytes recibidos en formato decimal (valores entre 0 y 255).

### Modos de transmisión:

- **ASCII**: Envía directamente los caracteres escritos.
- **ASCII + CR**: Agrega un carácter `0x0D` al final.
- **ASCII + LF**: Agrega un carácter `0x0A` al final.
- **ASCII + CR + LF**: Agrega ambos caracteres `0x0D` y `0x0A`.
- **HEX**: Enviar valores como `02 04 56`.
- **BIN**: Enviar valores como `011 01010100`.
- **DEC**: Enviar valores como `128 255 4`.

> ⚠️ **Validación de formato:**  
> Si se introduce un formato inválido en los modos **HEX**, **BIN** o **DEC**, AppLoader mostrará el mensaje `*FormatError` en la terminal, indicando que debe revisarse el formato o los caracteres ingresados.

---

## 🧹 Limpiar pantalla

Haz clic en el botón **Clear** para limpiar todo el contenido de la terminal.

---

## 📜 Licencia

Este proyecto está licenciado bajo **MIT**. Consulta el archivo [LICENSE](https://github.com/JCesarCM93/DoItPicBoot/blob/main/LICENSE) para más detalles.

---

## 📫 Contacto y contribuciones

Si deseas colaborar con el desarrollo, reportar errores o proponer mejoras, puedes hacerlo directamente a través de GitHub mediante Issues o Pull Requests.

---

## 🚀 Ideas para futuras versiones (opcional)

- Soporte para otros modelos de microcontroladores PIC.
- Actualización de firmware de la tarjeta desde AppLoader.
- Versión por línea de comandos (CLI) para automatización.
- Verificación automática del contenido grabado (Verify after write).
- Respaldo y restauración de EEPROM.
