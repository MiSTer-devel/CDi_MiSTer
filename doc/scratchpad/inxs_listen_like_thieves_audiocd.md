# INXS - Listen Like Thieves (USA)

The audio seems broken. Lucky for me, this also occurs in simulation.

According to the commands

    CDIC Write Command Register 1e00 0024    Reset Mode 2
    CDIC Write Command Register 1e00 0027    Fetch TOC

    CDIC Write Time High Register 1e01 0002
    CDIC Write Time Low Register 1e02 3300
    CDIC Write Time Low Register 1e02 b300
    CDIC Write Command Register 1e00 0028    Play CDDA

More detail 

    cat log | grep -e "Write Time" -e "Write Command" -e "Audio Co" -e png

    Written video_260.png
    Written video_261.png
    CDIC Read Z Buffer Register / Audio Control Register 1ffd 0000
    CDIC Write Time High Register 1e01 0002
    CDIC Write Time Low Register 1e02 3300
    CDIC Write Time Low Register 1e02 b300
    CDIC Write Command Register 1e00 0028
    Written video_262.png
    ...
    Written video_284.png
    CDIC Read Z Buffer Register / Audio Control Register 1ffd 0000
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 0800
    Written video_285.png
    Written video_286.png

Everything normal so far. Trace needed.
For some reason, I do have the feeling that the data stream is not stopped
after TOC reading and it just goes directly into CDDA playback. That might be an issue.

No, it seems that I've assumed the first CDDA sector being always in the same buffer.
This is not the case. I assume that CD-i Fan was right and CDDA is never stored anywhere.
It is directly played back. The data also backs that up as the CDIC RAM shows no sign of updated
sample data.

Right now, this core stores the CDDA data in the buffer and plays it using the same
state machine as ADPCM. This might be totaly wrong but still works.

