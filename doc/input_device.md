# Input Device

## Sources

https://www.theworldofcdi.com/open-source/hardware-development/the-cd-i-controller-interface/
https://www.theworldofcdi.com/open-source/hardware-development/cd-i-gamepad-adapter/
https://github.com/anarterb/SNEStoCDi/blob/master/sketchSNEStoCDi.ino

Communication starts with device sending 0b11001010 to CD-i player.

Afterwards a frame of 3 is transmitted

    Idle state:
    0= 0b11000000
    1= 0b10000000
    2= 0b10000000

## Data format

* Protocol for Maneuvering Device

Only 7 bits. The 8th bit is always 1.

    Byte 0 ->  1  1  B1 B2 Y7 Y6 X7 X6
    Byte 1 ->  1  0  X5 X4 X3 X2 X1 X0
    Byte 2 ->  1  0  Y5 Y4 Y3 Y2 Y1 Y0

## Spoon

Baud rate is 1200

Spoon Start

    CA C0 80 80     This is Manuvering Device + No button Press
    CA FF           ??
    FE              ??
    CA C0 80 80     This is Manuvering Device + No button Press


Spoon D-Pad Left

    C3 BE 80    Permanently
    C3 B8 80    After a while

Spoon D-Pad Right

    C0 82 80    Permanently
    C0 88 80    After a while

Spoon D-Pad Up

    CC 80 BE    Permanently

Spoon D-Pad Down

    C0 80 82    Permanently

Spoon Left Press

    E0 80 80    Transmitted once

Spoon Left Release

    C0 80 80    Transmitted once

Spoon Right Press

    D0 80 80    Transmitted once

Spoon Right Release

    C0 80 80    Transmitted once


This means:

The right button is B2.
The left button is B1.

The speed increments over time
It starts with 2 and changes to 8.
The relativ coordinates are two's complement.

Pressing left is negative X.
Pressing right is positive X.
Pressing up is negative Y.
Pressing down is positve Y.

When the D-Pad is pressed, the Spoon will send permanently. Button presses cause transmission only on event.
