
Weeb-Themes
=============
### A Weeaboo's Repository for Miscellaneous Theme-related Things

This repository contains a variety of SDDM/KSplash/GTK/Grub themes in various states of work-in-progress.
For your convenience, an "install script" is included...aka, it's just a cp line. In theory, it will ask for sudo to dump the files into /usr/share/\<place>. You can look at the script "in-depth" if you are afraid of something malicious.

As a short note, all of the QML/QT themes were written importing the latest libraries from QT5.7 (QtQuick 2.7, etc.), though the themes don't require anything from said latest libraries. As such, if you aren't using the latest QT5.7, you can change the import lines to the closest lower whole number (aka import QtQuick 2.7 -> import QtQuick 2.0) and they should work on any QT5 version.

#### Weeb-SDDM-Themes
- Dependencies:
    - qt5-multimedia
    - gstreamer0.10-ffmpeg (.mp4)
    - gstreamer0.10-good-plugins (.webm, autoaudiosink)
    - gstreamer0.10-base-plugins (.ogg)

#### Weeb-GTK-Themes
- Notes:
    Currently there is only really one work-in-progress GTK theme that kind of works here and there, but for the most part, this endeavor is on hold because trying to make a GTK theme is goddam confusing.

#### Weeb-KSplashX-Themes
- Dependencies:
    - qtquick

#### Weeb-Grub-Themes
- Notes:
    Currently there is only a single script for previewing/assisting in creating grub_init_tune ([original script](http://www.iavit.org/~john/debian/grub.html)). It can accept files, a environment variable GRUB_INIT_TUNE, or a somewhat janky custom notation that removes most thinking. 

    There is some slight customizations that can be made regarding the separator for the custom format and the granularity of the notes using the "sep" and "maxNote" variables respectively. It is optimal to set the maxNote to the lowest duration note for nice small numbers (ex. 8 for 8th notes up, 16 for 16th notes up, 64 for 64th notes up, etc.)

    The notes were tuned to A4 or 440Hz based off of the [equal tempered scale](www.phy.mtu.edu/~suits/NoteFreqCalcs.html). While you can change the base note using Fo and FoOCTA, the effect is probably minimal.

    GRUB_INIT_TUNE Format:
    `<tempo> <freq> <duration> <freq> <duration>...`

    Custom Janky Format:
    `<tempo> <note>*<duration> <note>*<duration>...`

- Notes on custom format:
    - Tempo is the normal tempo you can find on any sheet music (BPM)
    - Note notations are in the vein of "NoteOctave*Duration" (ex. C4\*4 = Middle C quarter note)
    - Parser is literally terrible and only counts the length of the "NoteOctave"
        - Sharps are any NoteOctave that is 3 characters long (ex. A.5*4)
        - Rests are any NoteOctave that is 1 character long (ex. R\*8)
        - Duration can be carried over from the last note (ex. C4\*8 D4 E4 A4 G5\*4 B5)
    - It is WAY easier to use than a frequency table and fudging with the tempo.
