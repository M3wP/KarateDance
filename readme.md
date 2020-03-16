# Karate Dance!

## Introduction

Hello and welcome to the **Karate Dance** read me!

I am developing an animation editor for the C64 that will allow you to build an animation to be played along with music.

It was inspired by the tool that Antonio Savona released to incorporate a dancing Karateka character with a SID tune.

The DanceAnimator app has been added now to the suite.  You can use the libraries created by the StepsLibrarian to construct your very own karate dance or any other animation that uses the same technique.

_**Please Note:**  The app previously called "StepsBuilder" is now called "StepsLibrarian".  The _src_ folder has been flattened._


## Download and Installation

The Windows x64 (64 bit) binaries are available in the _bin_ folder as a compressed file.  You will need to decompress them before you can run them.  The apps have now been built to require "run-time packages".  This decreases the total size of the installation but increases the number of files to include.

The DanceAnimator app makes use of the XSID project to produce audio during the audition.  XSID has been made into a set of libraries for this project.  The XSID libraries depend on the libSIDPlay and libReSID libraries I made for the XSID project.  You can find more information about XSID in that project's space.  All of these libraries are supplied in the binary download file.


## Compiling

The tool apps are written using Delphi FMX.  You should find all you need in the _src_ folder (except for the libSIDPlay and libReSID libraries, see below).  The apps can be compiled with the latest Community Edition of Delphi 10.3.  

A variety of systems should be supported including MacOS, Win32/Win64 and Linux (assuming compiler feature availability).  Android and iOS are currently unsupported due to feature utilisation.

You will require the libSIDPlay and libReSID libraries for your platform which you can build from the sources in the XSID project, available from that project's space on GitHub:  [https://github.com/M3wP/XSID](https://github.com/M3wP/XSID)

## Applications

### CharsetChk

This tool can convert the optimised charsets output by Antonio's tool into fully specified charsets with all combinations.  

You can also convert frame files into a "normalised" charset utilisation in order to reverse the optimisation on the frames.  The StepsLibrarian app expects frames to be "normalised".

The screens file and charset file supplied by Antonio are in the _data/org_ folder.


### StepsLibrarian

_**Important:**  There has been a change in the file format used for libraries since the first version.  This notice will be removed at next milestone release.  The change is quite simple and a fix is easy to apply.  Please contact me for further information.  A further, non-breaking change is planned to decrease the size of generated library files._

With this app, you can create animation frames and logical, repeatable sequences called steps.  These frames and steps are saved together to form an animation "library".  The final animation app will allow you to link sequences of these steps or individual frames from the library to form a complete animation.

You start with an empty library.  The blank frame and colour palette are defaulted to the ones used in the Karateka dance.  You can change the colour palette and blank frame only while the background frame is the only frame in the library.

On the Frames tab, you can duplicate frames and edit them to form an animation sequence or you can import existing frames from a file.  

You can import frames from a set of screen snapshots or from suitable graphical images.  These graphic images must have four (4) colours or less and be of the correct size/proportion or cannot be imported.  When importing graphical images, you must also map the colours used in each image to the ones used in the library and C64 palette before they can be imported.

Editing only has a simple pencil tool but there is full undo support.  Select the colour to draw from the toolbar.  You can also use an eraser to revert the target cells to those in the background frame by using the right mouse button.  You can't edit frames that are being used in animation steps.

There is an example set of frame screens which can be imported from the _data_ folder.  They were converted as required from those supplied by Antonio.

The key points in a frame are tracked.  These are the outside edges of the frame's non-blank content and the mid point of this area.  These points are used to "link" animation sequences.

Once you have frames, you can create animation steps on the Steps tab.  Add frames and play the sequence with a variety of options.

You can save your changes on the Project tab or load a previous session.

### DanceAnimator

_**Note:**  You will need to supply the location of the Songlengths file from the HVSC (High Voltage SID Collection) in order to get the duration of the SIDTune songs.  You do this on the Configure tab.  The default duration is currently three minutes (03:00) and cannot be changed at this time._

The functionality is very limited and there is no real project file handling but the goal of producing a custom dance animation can be achieved.  The app still cannot export to a C64 compatible animation, however.

To start working with an animation project in the app, first link to a library on the Animation tab.  Now you can construct an animation on the Sequence tab by adding the steps in the order you want them to appear.  Linkage method and offset handling may or may not function correctly at this time except for in the case of linking position by frames and possibly smart linking.  Individual frames cannot yet be added to the animation, either.

You can select a SIDTune song to play with the animation.  Select the SID file by clicking on the "Open..." button on the Audio tab.  Currently, only the default song can be played (this is an oversight, my apologies).  When you compile the animation, an XSID file will be built for the selected SIDTune song.  This will allow for playback during auditions.

Once you have constructed a sequence and selected any song, you must "compile" or build the animation sequence data.  Do this on the Make tab.  Some statistics are shown.  Compiling the XSID file (a conversion of the SID file), will take some time but this is only done when the SIDTune or song is changed.

You may now audition the animation on the Audition tab.


## Future Development

- DanceAnimator will allow project save/load.
- DanceAnimator will build C64 launchable programs.

## Contact

Please feel free to contact me for further information.  You can reach me at:
	
	mewpokemon {at} hotmail {dot} com

Please include the string "Karate Dance!" in the subject line or your mail might get lost.