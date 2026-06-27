# TODOs and known issues

* Check if speed of mouse device really is the max, a CD-i can take
    * Also check the accumulator
* "INXS - Listen Like Thieves (USA)" has distorted audio
    * Distorted on 260628
    * Seems to work on 260502
    * Pregap related? Might be a problem on Linux side
* "Burn-Cycle (USA Europe) (Disc 1) (The Game)" has a pop during the cutscene when entering the bar.
    * Problem is absent in German version
* "Chaos Control"
    * Video glitches when pausing and resuming. MPEG stream is actually damaged! Even mplayer has some issues.
* Random hang of playback controls in Addams Family Disc 2. Movie still playing. Sudden rainbow colors.
    * Reproduced by frequently pausing and resuming
    * No regression. Always present since 251123
    * Can be reproduced on cdiemu as well
* Randomly no audio in Mad Dog McCree? Unclear reproduction
* Check random audio video out of sync (e.g. Mad Dog McCree)
* Check correct timing of DVC clipping functionality when scroll bit is reset
* Moving window homebrew test timing is broken with 260123
    * Was working in 260104. Also broken with 260116
    * Proposed fix with 40637f4904
    * Will be broken again with the addition of frame synced updates
* Frequency response of CDIC and MPEG audio output might not be 100% accurate
* Add support for an emulated Peacekeeper Revolver Light Gun
* "Uncover featuring Tatjana (Europe)" graphical issues
    * Corruption of MPEG footage in single step mode?
    * Broken since at least 260116
    * Application crashes on 251228 and 260104
    * Working last on? Did it work at all?
* Regression of "Historia del Arte Español" (working in DVC rc2)
    * Blank video?
* Fix Christmas Crisis bonus ride
    * Might still stutter. Analysis required.
* "Mutant Rampage - Bodyslam" has a tendency to freeze?
* "The Last Bounty Hunter", "Drug Wars", "Mad Dog 2", "Who Shot Johnny Rock?" have regressions (works in rc2)?
* "The Lost Ride" has video and audio glitches
    * It changes Sequence Parameters on the fly
* "Crime Patrol" has video glitches?
* "Solar Crusade" has video glitches?
* "Brain Dead 13" has video glitches when switching MPEG streams
* "The Secret of Nimh" (Philips Edition) has the wrong frame rate? Sometimes?
* Slow motion with VCDs is desyncing audio and video
    * Too many frames in output FIFO
* Leaving the cake Puzzle in 7th Guest freezes (everytime?)
* Sound bugs on the police procedures disk?
* Find a better solution for reducing CPU speed
* Give a signal to the user when CPU data stalling occured
* Find a better solution for CD data stalling (plugging USB devices)
    * PSX core seems to halt the whole machine to avoid this situation
* Fix regression: Audio hiccups during Philips Logo in Burn:Cycle
    * A workaround is CPU overclocking
* Investigate input responsiveness (skipped events?)
* Fix hang on audio track stop or change in media player
* Cheat support?
* Fix reset behaviour (Core is sometimes hanging after reset)
* Investigate desaturated colors / low contrast in "Photo CD Sample Disc"
    * Probably fixable with 16-235 to 0-255 scaling
    * More investigation needed
* Find a solution for the video mode reset during system resets
    * The ST flag is the issue here, causing a video mode change
* Check compatibility with CDs that have track index 2 as opposed to the usual 0 and 1
    * Possible discs? "Philips CDI Format Test Disc 1 (Europe)" and a disc by Zeneca Pharmaceuticals Group, "An Interactive Medical Program"
* Possibly adding support for the Quizard arcade hardware

## Low priority and crazy ideas

* Try to utilize 24 bit audio sample size with HDMI, because 16 bit are not enough for CD-i audio hardware
    * The Mono I hardware has the option to mix 2x 16 bit together as single mono output.
    * To allow this, the MiSTer needs to halve the volume of a single channel to fix clipping
* Possibly adding support for other PCBs (like Mono II)
* Refurbish I2C for the front display and show the content as picture in picture during changes?
    * It might not even be required at all.
* Implement the speed setting of the 22ER9017 Touchpad
    * 22ER9021 should be enough right now
* Integration test to confirm equal output of MPEG video during simulation vs synthesis
    * MiSTer only Register for audio loudness analysis and for detecting a white dot from CD-i software
    * Automatic check of audio vs video sync
    * Playing a short video (from CD!) again and again on repeat
    