Weeaboository
=============

A Weeaboo's Repository for Miscellaneous Things

This repository contains SDDM/KSplash themes and a work-in-progress gtk theme.
For your convenience, an "install script" is included...aka, it's just a cp line.
In theory, it will ask for sudo to dump the files into /usr/share/<place>. You can
look at the script "in-depth" if you are afraid of something malicious.

As a short note, all of the QML/QT themes were written importing the latest
libraries from QT5.7 (QtQuick 2.7, etc.), though the themes don't require anything
from said latest libraries. As such, if you aren't using the latest QT5.7, you can
change the import lines to the closest lower whole number (aka import QtQuick 2.7 
--> import QtQuick 2.0) and they should work on any QT5 version.

SDDM themes depend on:
- qt5-multimedia
- gstreamer0.10-ffmpeg (.mp4)
- gstreamer0.10-good-plugins (.webm, autoaudiosink)
- gstreamer0.10-base-plugins (.ogg)

KSplash themes depend on:
- qtquick
