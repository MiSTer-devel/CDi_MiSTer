# SNAC (Serial Native Accessory Converter)

The User port of the MiSTer offers 7 data lines to use for the core.
The serial port of the CD-i - at the front or back - makes use of 8 pins.
6 of those are data lines. Together with one line for the infrared signal
for the remote controller, this seems to be a match.

Since every CD-i has different types of ports, we rely on the common denominator.
Two SNAC modes are offered.

The **RS232 Mode** simulates a back port of a 210/05. It is connected to the UART of the SCC68070.

The **Dual Input Mode** simulates the front port of a CD-i that supports the official input port splitter.

* Without a splitter, it can take one pointing device which is connected to the SLAVE.
* With the splitter, the second device is connected to the SCC68070

|     | Dual Input Mode                            | RS232 Mode                       | Direction |
| --- | ------------------------------------------ | -------------------------------- | --------- |
| 1   | RXD1                                       | \-                               | In        |
| 2   | RXD2                                       | RXD                              | In        |
| 3   | TXD2                                       | TXD                              | Out       |
| 4   | RTS1                                       | DTR                              | Out       |
| 5   | GND                                        | GND                              |           |
| 6   | \-                                         | CTS                              | In        |
| 7   | RTS2                                       | RTS                              | Out       |
| 8   | +5V                                        | +5V                              |           |
| 9   | RC-Eye                                     | RC-Eye                           | In        |
|     | Can take 2 controllers<br>using a splitter | Fully compatible<br>to back Port |           |
