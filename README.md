# Fiducial FEZ
A project for 3D-printing Zuish letters (from the indie game FEZ) and using them as fiducial markers to be scanned in and automatically translated to English.
This is for a 3-week long multimodal university project, so don't expect the cleanest code in the world, or the nicest workflow.

## Overview
This project is split into two main parts, printing and the web program. The former is an involved process for making Zuish letters into tiles, and baseplates to allow them to be arranged into grids. The latter is for taking pictures of the arranged tiles, scanning them as fiducial markers, and translating to English. The web portion is made using html and javascript, so that it may be loaded natively in desktop and mobile browsers for ease of use.

## Acknowledgements
The web portion of this project uses a custom-modified version of [js-aruco](https://github.com/jcmellado/js-aruco), a port of [ArUco](http://www.uco.es/investiga/grupos/ava/node/26) to javascript.

## Web Scanner
The in-browser scanner/translator can be found [here](https://legokidlogan.github.io/fiducial-fez/webcode/index.html) via github pages. As such, the html/js source code is not in this repo, but in [my github.io repo](https://github.com/legokidlogan/legokidlogan.github.io/tree/main/fiducial-fez). Everything in this repo is of my own work, while the web portion uses [js-aruco](https://github.com/jcmellado/js-aruco) and its webcam example, heavily modifies the library and html to support Zuish letters and red/blue symbol detection, and adds new code for handling the translation and user input.

The web scanner is able to translate messages made in Zuish using 3D-printed baseplates and tiles, via either webcam/back-camera live feed or uploaded images. It can also convert English messages into Zuish images, with an option to format it as if it were written using the physical pieces.

When writing messages using the physical pieces, note that tiles on the edges between two adjacent baseplates will be part of the same word; baseplate boundaries do *not* act like a space character. Changing columns (or rows, if rotated into the English-readable position) behave as you might expect, i.e. being new lines.

## Red and Blue Symbols?
This project uses more than just black and white for its fiducial markers. The English alphabet contains 26 letters, while Zuish only has 24 symbols. The letter pairs K and Q, and U and V have to share some symbols, leveraging context clues to determine what letter is being represented. For the sake of complete one-to-one translation, I have opted to distinguish these pairs with red and blue colors, while still using the same symbols.

As such, when these shared symbols are encountered in white, they will be translated ambiguously as `(KQ)` or `(UV)`, but when red or blue are used, the exact letters will be translated.

## Printable Objects
There are three main types of printable objects in this project:

1. Baseplates
    - Prints in white, black, and some arbitrary third color.
    - The third color is for a small plus sign in the top right.
      - When connecting baseplates or taking pictures of them, rotate them so this plus is in the top right.
      - Rotating the baseplate so that the plus is in the top left is the same as rotating your head to read FEZ's in-game messages in standard English format.
    - Has nibs and holes to allow baseplates to be connected together.
      - These need to be cleaned *very* thoroughly of supports once they're done being printed!
    - Has a grid of slots for placing tiles into.
      - Each slot has room for a small neodymium magnet, which can optionally be superglued in. Be careful with your magnet polarity!
      - The magnets to use are 5x2mm, though the size can be adjusted in the grasshopper file.
    - Default dimensions: 20x20x1cm, 8x8 grid, 64 magnets.
2. Tiles
    - Prints in white, then black. May also do red, then blue if those colors are needed.
    - The amount of tiles, letters to use, and red & blue status can be adjusted in the grasshopper file.
    - Each tile has a hole for a magnet.
    - Remember, each symbol covers 4 letters, so you don't need a ton of copies per each individual letter.
    - You'll likely need to remove wisps of filament and clean up some color boundaries once the print is done.
    - Default dimensions: 1.4x1.4x1cm, 1 magnet.
3. Translation Key
    - Prints in white, black, red, then blue.
    - A thin plate with each Zuish symbol and their rotations, along with their English letter counterparts.
    - Hold the key horizontally and read the letters on the bottom to translate symbols 'as-is.'
      - To read a sentence, it goes top->bottom, right->left.
    - Hold the key vertically and read the letters on the bottom to transalte symbols 'as English-readable.'
      - To read a sentence, it goes left->right, top->bottom.
    - The grasshopper file has an option to only print in black and white if needed.
    - Let the print fully cool off before you remove it from the bed, or it will warp!
    - Default dimensions: 20.3x13.7x0.3cm.

## Printing Process
In order to operate as fiducial markers, the tiles need to use multiple colors. Most common consumer-level 3D printers don't have automatic filament-swapping features, and prominent slicers like Cura don't allow the level of sub-layer control this project needs. As such, the bulk of the prints will be handled in the traditional model->slicer->gcode workflow, with an additional step to generate gcode for the fiducial markers and filament changes.

Admittedly, this new workflow isn't the cleanest, as it uses [lua 5.1/5.2](https://www.lua.org/) to generate the extra gcode instead of remaining entirely in [Rhino/Grasshopper](https://www.rhino3d.com/). Given more time, the lua portion could likely be moved to grasshopper. However, there would still be some back-and-forth with your slicer regardless, as seen later.

Before anything, make sure to download [lua](https://www.lua.org/) version 5.1 or 5.2, and [Rhino 8](https://www.rhino3d.com/). In Rhino, use the `Grasshopper` command to open Grasshopper, then load the [fez_grasshopper.gh](/printcode/rhino) file, and use a text editor or IDE of your choice to open [add_fez_gcode.lua](/printcode/lua/add_fez_gcode.lua). Both of these files have extensive config areas, including some parameters that are printer-specific, like buildplate size, nozzle output diameter, and print movement speeds. You'll want to make sure these match the specs of your own printer.

Lastly, try to use matte filaments for everything but white. For instance, Hatchbox Black works quite well. I forgot to do this when purchasing my red and blue filaments, making them more susceptible to glare, but it's still usable. Speaking of, as long as you use bright red and blue filaments, they should be detected, though the exact filaments I used were the red and blue 'Easy PLA' filaments from Overture.

Once you're ready, follow these steps to prepare each print:

1. Use [fez_grasshopper.gh](/printcode/rhino) in Rhino to generate models and lua code snippets. More details can be found in the grasshopper file.
2. Slice the models in Cura (or your slicer of choice).
3. Make some slight adjustments to the end of the resulting gcode file, noted shortly later.
4. Use [add_fez_gcode.lua](/printcode/lua/add_fez_gcode.lua) and the lua snippets from part 1 to generate the extra gcode.
5. Insert the new gcode, as described below, and print. Prints will first use white filament, then black, and if needed, red and/or blue. The baseplates instead do white, black, and some third color of your choice.


The very end of gcode files generated by Cura typically look something like this:
```
(...)
G1 X105.586 Y115.089 E300.46466
G1 X104.992 Y115.089 E300.48541
G1 X104.91 Y115.007 E300.48946
M204 S6000
M205 X30 Y30
G0 F30000 X104.26 Y115.007
;TIME_ELAPSED:226.738019
G1 F2400 E299.88946
M140 S0
M204 S4000
M205 X20 Y20
M107
END_PRINT
M82 ;absolute extrusion mode
M104 S0
;End of Gcode
;SETTING_3 {"global_quality": "[general]\\nversion = 4\\nname = Creality Ender 3
;SETTING_3  v3 - KaminoKGY - Cura\\ndefinition = custom\\n\\n[metadata]\\ntype =
;SETTING_3  quality_changes\\nquality_type = draft\\nsetting_ver
(...)
```

Here, the lines of interest are `G1 F2400 E299.88946` (the last `G1` command) and `M205 X20 Y20` (the last `M205` command).
For the `G1` line, replace the value after the `E` with a `-0.6`, then insert several blank lines and `M83 ; relative extrusion mode` directly above.
For the `M205` line, remove it.

In this case, you'll end up with something like this:
```
(...)
G1 X105.586 Y115.089 E300.46466
G1 X104.992 Y115.089 E300.48541
G1 X104.91 Y115.007 E300.48946
M204 S6000
M205 X30 Y30
G0 F30000 X104.26 Y115.007
;TIME_ELAPSED:226.738019



M83 ; relative extrusion mode
G1 F2400 E-0.6
M140 S0
M204 S4000
M107
END_PRINT
M82 ;absolute extrusion mode
M104 S0
;End of Gcode
;SETTING_3 {"global_quality": "[general]\\nversion = 4\\nname = Creality Ender 3
;SETTING_3  v3 - KaminoKGY - Cura\\ndefinition = custom\\n\\n[metadata]\\ntype =
;SETTING_3  quality_changes\\nquality_type = draft\\nsetting_ver
(...)
```

The specifics may vary per printer and slicer, so you'll need to carefully look for any differences in gcode commands your slicer outputs. [Reprap.org](https://reprap.org/wiki/G-code) has a page detailing many gcode commands for many kinds of firmwares. For the examples above, I was using an Ender 3 V3 and Cura.

One more thing you need to do with the sliced gcode is to look for the last-used X, Y, Z values. You'll find these in `G0` and `G1` commands, most likely finding the X and Y right at the very end, and the Z somewhere earlier, with the help of ctrl-F searching. If your gcode has a bunch of small numbers in the range of 1-10 instead of hundreds, there's a good chance your slicer used relative positioning instead of absolute positioning. If it did, you'll need to see if your slicer has options to use absolute positioning instead and re-slice the model.

Once you have the last-used X, Y, Z values, go to [add_fez_gcode.lua](/printcode/lua/add_fez_gcode.lua) and use them to define `startingPos` in the config area. This lets the script pick up where the printer last left off, to prevent any misalignments. Then, towards the bottom of the file is a section to paste the lua code snippet generated by the grasshopper script.

To run the lua script, open a command prompt and use the `cd` command to navigate to the top-level folder of this repo in your local files. Then, use `lua52 ./printcode/lua/add_fez_gcode.lua`. Replace `lua52` with `lua51` if you installed lua 5.1, etc. It will then create a `test_out.txt` file with the gcode to be copied and pasted into the blank space you made earlier in the gcode file. Now you can start printing!

Since not all printers support a gcode command to pause the print and wait for user input, whenever the print needs to change filament, it will rise up and move side-to-side to get your attention. When it does, use your printer's control interface to pause the print, cut the filament, swap the rolls, and extrude until the new filament is fully in. Then, resume the print and wait for the side-to-side to stop, where it will then release some filament in the air to ensure the nozzle is good to go (some printers suddenly eject filament when resuming a print, emptying the nozzle). While it does this, carefully collect the loose filament onto a folded paper towel and *gently* wipe the nozzle clean without disturbing its position.
