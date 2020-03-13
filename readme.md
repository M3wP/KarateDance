# Karate Dance!

## Introduction

Hello and welcome to the **Karate Dance** read me!

I am developing an animation editor for the C64 that will allow you to build an animation to be played along with music.

It was inspired by the tool that Antonio Savona released to incorporate a dancing Karateka character with a SID tune.

The DanceAnimator app has been added now to the suite.  You can use the libraries created by the StepsLibrarian to construct your very own karate dance or any other animation that uses the same technique.

_**Please Note:**  The app previously called "StepsBuilder" is now called "StepsLibrarian".  The _src_ folder has been flattened._


## Download and Installation

The Windows x64 (64 bit) binaries are available in the _bin_ folder as a compressed file.  You will need to decompress them before you can run them.  The apps have now been built to require "run-time packages".  This decreases the total size of the installation but increases the number of files to include.


## Compiling

The tool apps are written using Delphi FMX.  You should find all you need in the _src_ folder.  The apps can be compiled with the latest Community Edition of Delphi.  

A variety of systems should be supported including MacOS, Win32/Win64 and Linux (assuming compiler feature availability).  Android and iOS are currently unsupported due to feature utilisation.

## Applications

### CharsetChk

This tool can convert the optimised charsets output by Antonio's tool into fully specified charsets with all combinations.  

You can also convert frame files into a "normalised" charset utilisation in order to reverse the optimisation on the frames.  The StepsBuilder app expects frames to be "normalised".

The files supplied by Antonio are in the _data/org_ folder.


### StepsLibrarian

_**Important:**  There has been a change in the file format used for libraries since the first version.  This notice will be removed at next milestone release and updated if necessary in between.  The change is quite simple and a fix is easy to apply.  Please contact me for further information.  A further, non-breaking change is planned to decrease the size of generated library files._

With this app, you can create animation frames and logical, repeatable sequences called steps.  These frames and steps are saved together to form an animation "library".  The final animation app will allow you to link sequences of these steps or individual frames from a library to form an animation proper.

You start with an empty library.  The blank frame and colour palette are defaulted the ones used in the Karateka dance.  You can change the colour palette and blank frame only while the background frame is the only frame in the library.

On the Frames tab, you can duplicate frames and edit them to form an animation sequence or you can import existing frames from a file.  

You can import frames from a set of screen snapshots or from suitable graphical images.  These graphic images must have four (4) colours or less and be of the correct size/proportion.

Editing only has a simple pencil tool but there is full undo support.  You can also use an eraser to revert the selected cells to those in the background frame by using the right button.  Select the colour to draw from the toolbar.  You can't edit frames that are being used in animation steps.

There is an example set of frame screens which can be imported from the _data_ folder.  They were converted as required from those supplied by Antonio.

The key points in a frame are tracked.  These are the outside edges of the frame's non-blank content and the mid point of this area.  These points are used to "link" animation sequences.

Once you have frames, you can create animation steps on the Steps tab.  Add frames and play the sequence with a variety of options.

You can save your changes on the Project tab or load a previous session.

### DanceAnimator

The functionality is very limited and the overall quality quite crude but the goal of producing a custom dance animation can be achieved.

The app cannot export to a C64 compatible animation at this time, nor can it play music with auditions.

To operate the app, first link to a library on the Animation tab.  Now you can construct an animation on the Sequence tab by adding the steps in the order you want them to appear.  Linkage method and offset handling may or may not function correctly at this time except for in the case of linking position by frames and possibly smart linking.  Individual frames cannot yet be added to the animation, either.

Once you have constructed a sequence, you must "compile" or build the animation sequence data.  Do this on the Data tab.  Some statistics are shown.

You may now audition the animation on the Audition tab.


## Future Development

- First pass animation builder will load animation projects and allow construction of final animation sequences.
- Animation builder will build C64 launchable programs.
- Animation builder will audition tune with animation.

## Contact

Please feel free to contact me for further information.  You can reach me at:
	
	mewpokemon {at} hotmail {dot} com

Please include the string "Karate Dance!" in the subject line or your mail might get lost.