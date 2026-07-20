# Burn:Cycle

## Pop sound at the bar cutscene

Go to the bar, listen to the cutscene that probably has audio played from disc.
At the end, there is a zoom into the bar counter and
the game switches back to the ambience. A pop can be heard.

Only in the US release. Absent in German version.

cdiemu-0.5.3-beta9 also has the same pop issue.
Some analysis might be possible using.

    et trp
    et fun cdic
    et dev cdic
    ef logburn

MAME 0cd59423 doesn't have this problem.

According to the log from cdiemu, the audio channel register is never set.
This means that the audiomap from CPU is constantly active to deliver even CD audio.

At this point, I've assumed that the coding does change? But that is not the case.
According to MAME, the coding is always 0x44 while the game is running.

    [:cdic] Procesing audio map from 2800
    [:cdic] Coding is 44
    [:cdic] Procesing audio map from 3200
    [:cdic] Coding is 44
    [:cdic] Procesing audio map from 2800

A destillation program to dump the CDIC DMA data from cdiemu was written.
I've checked this file with FFmpeg and the complaint became clear.

    filter 1 19 3
    filter 3 3b 1
    filter 1 1b 1
    filter 0 d -1
    unknown XA-ADPCM shift -1
    filter 3 3b 1
    filter 1 1c 0
    filter 1 1c 0

The shifting parameter is negative. I shall clamp it like MAME does too.
