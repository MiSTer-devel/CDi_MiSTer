# Litil Divil

## Bouncing graphics directly at the beginning during 60 Hz mode

When taking control over the character.

Is the problem coming from ICA/DCA?

    cat log | grep -e png -e SS_DC

Actually not, there is some DC_WrLI going on for fading but not much...

It turns out that the ICA length is maxed out.
During the intro, while the character is walking across those stairs,
ICA0 has 1054 instructions -> 2108 memory fetches a 16 bit
ICA1 has 1034 instructions -> 2068 memory fetches a 16 bit

Since at some point I've added a stalling to the ICA units to save
memory bandwith for the poor CPU, the stalling was too much
and with NTSC the ICA wasn't finished before the end of vertical active.

With the new configuration, our ICA allows up to 1300 instructions or
2600 memory fetches. That is barely below the specified maximum
of the MCD212 but hopefully the applications stay in tone with the Green Book.

With Litil Divil, there the headroom in NTSC is 5 lines.