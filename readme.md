# Karate Dance!

## Introduction

Hello and welcome to the **Karate Dance** read me!

I am developing an animation editor for the C64 that will allow you to build an animation to be played along with music.

It was inspired by the tool that Antonio Savona released to incorporate a dancing Karateka character with a SID tune.

The app is currently not finished and in fact doesn't even quite exist.  The only apps that are present are tools to manipulate frames and basic animation steps and to convert from data formats supplied by Antonio.


## Download and Installation

The Windows x64 (64 bit) binaries are available in the _bin_ folder as a compressed file.  You will need to decompress them before you can run them.


## Compiling

The tool apps are written using Delphi FMX.  You should find all you need in the _src_ folder.  The apps can be compiled with the latest Community Edition of Delphi.  

A variety of systems should be supported including MacOS, Win32/Win64 and Linux (assuming compiler feature availability).  Android and iOS are currently unsupported due to feature utilisation.


## CharsetChk

This tool can convert the optimised charsets output by Antonio's tool into fully specified charsets with all combinations.  

You can also convert frame files into a "normalised" charset utilisation in order to reverse the optimisation on the frames.  The StepsBuilder app expects frames to be "normalised".


## StepsBuilder

With this tool, you can create animation frames and logical, repeatable sequences called steps.  The final animation app will allow you to link sequences of these steps or individual frames to form an animation.

You start with an empty project.  The blank frame is currently fixed to being the one used for the Karateka dance.  

On the Frames tab, you can duplicate frames and edit them to form an animation sequence or you can import existing frames from a file.  You can't edit frames that are being used in animation steps.

Editing only has a simple pencil tool but there is full undo support.  You can also use an eraser to revert the selected cells to those in the background frame by using the right button.  Select the colour to draw from the toolbar.

There is an example set of frames, as supplied by Antonio, in the _data_ folder which can be imported.

The key points in a frame are tracked.  These are the outside edges of the frame's non-blank content and the mid point of this area.  These points are used to "link" animation sequences.

Once you have frames, you can create animation steps on the Steps tab.  Add frames and play the sequence with a variety of options.


## Future Development

- StepsBuilder will load and save project files.
- First pass animation builder will load animation projects and allow construction of final animation sequences.
- Animation builder will build C64 launchable programs.
- Animation builder will audition tune with animation.

## Contact

Please feel free to contact me for further information.  You can reach me at:
	
	mewpokemon {at} hotmail {dot} com

Please include the string "Karate Dance!" in the subject line or your mail might get lost.