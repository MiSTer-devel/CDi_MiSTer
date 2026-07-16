# FAQ, Issues and Quirks

The production quality of CD-i hardware and software is sometimes questionable.
For this reason, I've created a list of some known quirks, one might suspect of being caused
by emulation errors but are also present on the real machine.

* Is the "Digital Video Cartridge" supported?
    * Please stop asking! >.<
* The map of "Zelda - Wand of Gamelon" has micro jitter during scrolling
    * This also happens on real 210/05 hardware
* "Hotel Mario" seems to have the first samples of every ingame song repeated
    * You have good ears as it is barely noticeable. This also happens on real hardware.
* Some earlier CD-i titles have both stereo channels swapped
    * Yes, according to an [internal memo from Philips](http://icdia.co.uk/docs/mono2status.zip) there
      were manufacturing issues and some early players have the left and right channel swapped.
      This might explain discrepancies.
    * One known quirk is inverted stereo on the "Philips Logo Jingle" of "Zelda - Wand of Gamelon"
* During the rotating transition in "Myst" there are glitched lines at the bottom
    * This also happens to some extent on a real 210/05 hardware and is caused by a misplaced Video IRQ
      The video data is changed while it is displayed.
* When I load a save game in "Burn:Cycle" it plays a short and unclean loop of noise until I do something
    * I thought that was a bug in the core at first too. However, it is actually like this on a real CD-i too.
* The music of Burn:Cycle sometimes has "pops" and "clicks"
    * This game is special. It doesn't play music from CD like most games for this system would do.
    * Small loops of sampled music are loaded from CD, stored in memory and randomly concatenated together
      to create the background music. These samples are sometimes not very "loopable" creating a pop at looping points.
    * This issue is reproducible on a real 210/05 as well
* The music during the Philips Logo animation of Burn:Cycle has broken audio
    * This issue is reproducible on a real 210/05 as well
    * For some reason, it seems to be absent on other models with different hardware, like the 450/00
    * The problem can be fixed by overclocking the CPU
* Burn:Cycle - Random flickery animated text in front of the "Psychic Roulette" credit card terminal
    * This actually happens on the real machine. I also thought this might be a CPU speed issue, considering
      that the flickering disappears if the CPU is slightly overclocked.
* Flashback: The audio and video during the intro are asynchronous
    * This curiously happens on the real machine as well and doesn't even depend on 50 or 60 Hz
    * It seems to be an oversight by the developers when the game was ported to CD-i
* When dying in "Zelda's Adventure" the accompanying sound effect doesn't match the audio data on CD
    * Good catch! This is a programming error which can be reproduced on a real CD-i 210/05 as well,
      which causes the audio playback to start one sector too late.
    * The same phenomenon exists in the "Help cutscene" of "Zelda - Wand of Gamelon"
        * It is not audible in that game, because of silence in the beginning
* The intro music of Zenith is played only on the left audio channel
  * Yes, this happens on a real 210/05 too. To be sure, I've tested it as well
    on a 450/00. It seems to be an oversight by the developers.
* During the cinematic intro of Kether, the screen flickers to black on some frames during the fading slideshows
  * This curiously happens on a real 210/05 too.
* If I mash the buttons really hard when booting up Tetris, I get a colorful glitched screen instead of the Philips Logo
  * Congratulations for this obscure finding. This happens on a real 210/05 too!
* During the intro of "Zombie Dinos vom Planeten Zeltoid", the title text looks like the last row of pixels is missing during the scaling effect
  * Yes, an oversight it seems. The scaling operation is broken, even on the real machine.
* QuizMania - Missing animation graphics during intro and alignment issues during video playback in menu
  * This game seems to have problems with 60Hz/NTSC mode. Both issues can be reproduced using real 210/05 hardware
  * I assume that this was a local production for the italian market and no testing was performed on NTSC machines
* Inside the settings menu on the start screen, there are purple glitch pixels on the right edge of the screen
  * How could they miss this? It is also present on a real 210/05
* Lemmings is running slow on the core when compared to the Amiga version
  * "Oh No!" *Explodes* It is running as slow as on real hardware,
    but it seems that the CPU Turbo fixes this issue and makes it behave
    more like the Amiga version.
* There is a small green artifact at the top left of the Philips Intro in "Lost Eden"
  * I thought that this is a decoding error, but it is actually there on real hardware
* "Lost Eden" hangs for 1-2 seconds when the music restarts
  * This seems to be an oversight by the developers. It occurs on real hardware all well.
* Graphical glitches at the top of the Philips Intro in "Mystic Midway - Rest in Pieces"
  * Yes, those exist on real hardware as well and are maybe hidden by overscan
  * A side note, "Dr. Dearth" was probably filmed in front of a blue screen, but the cut out is not very good.
    Blue pixels at the edges are visible on real hardware as well.
* "The Lost Ride"
  * It sometimes has an unexpected mirrored column of pixels on the right side of the screen
    * This happens on real hardware as well. This seems to be an oversight by the developer.
  * The main menu has a weird freeze frame when the cutscene before that is skipped
    * Like on real hardware. I don't know what they were thinking.
* During the intro of "The Ultimate Noah's Ark", the Mike Wilks artwork has repeated pixels on the bottom and right edge.
  * This looks wrong but real hardware does that too.
  * There is also a weirdly wrong column of pixels during the title page on the left inside the black frame
* "Marlboro – Follow Your Dreams" is not booting and hangs on a cyan screen
  * You are probably using NTSC mode. Being made by a German publisher, this title was probably only tested on European models. It behaves like this on real hardware as well
* "AIMS - Frogs and How they Live (1995)(AIMS Multimedia)(US)\[DVC\]"
  * The movie on the disc has an audio issue from time code 00:04:23 to 00:04:28. This is not caused by an MPEG decoding issue,
    since it can be reproduced with modern playback software as well. The noise sounds like a broken recording from
    a magnetic tape during the authoring process.
* When pausing and resuming MPEG audio, sometimes a short blip of ~70ms can be heard, followed by a pause of ~250ms before actual Audio starts
  * This is a bug in the VMPEG ROM version 4.1 and is present on real hardware as well.
  * With the movie "Addams Family", at least one title is known to show this issue

