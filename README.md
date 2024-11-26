# Fiducial FEZ
A project for 3D-printing Zuish letters (from the indie game FEZ) and using them as fiducial markers to be scanned in and automatically translated to English. \
This is for a 3-week long multimodal university project, so don't expect the cleanest code in the world, or the nicest workflow. \

## Overview
This project is split into two main parts, printing and the web program. The former is an involved process for making Zuish letters into tiles, and baseplates to allow them to be arranged into grids. The latter is for taking pictures of the arranged tiles, scanning them as fiducial markers, and translating to English. The web portion is made using html and javascript, so that it may be loaded natively in desktop and mobile browsers for ease of use.

## Acknowledgements
The web portion of this project uses a custom-modified version of [js-aruco](https://github.com/jcmellado/js-aruco), a port of [ArUco](http://www.uco.es/investiga/grupos/ava/node/26) to javascript.

## Web Scanner
The in-browser scanner/translator can be found [here](https://legokidlogan.github.io/fiducial-fez/webcode/index.html) via github pages. As such, the html/js source code is not in this repo, but in [my github.io repo](https://github.com/legokidlogan/legokidlogan.github.io/fiducial-fez). Everything in this repo is of my own work, while the web portion uses [js-aruco](https://github.com/jcmellado/js-aruco), heavily modifies it to support Zuish letters and red/blue symbol detection, and adds new code for handling the translation and user input. \

**NOTE**: The web portion of this project is still being developed. Everything is being made public early for the sake of a progress update assignment. About one week remains until the project deadline.

## Red and Blue Symbols?
This project uses more than just black and white for its fiducial markers. The English alphabet contains 26 letters, while Zuish only has 24 symbols. The letter pairs K and Q, and U and V have to share some symbols, leveraging context clues to determine what letter is being represented. For the sake of complete one-to-one translation, I have opted to distinguish these pairs with red and blue colors, while still using the same symbols. \

As such, when these symbols are encountered in white, they will be translated ambiguously as `(KQ)` or `(UV)`, but when red or blue are used, the exact letters will be translated.

## Printing
In order to operate as fiducial markers, the tiles need to use multiple colors. Most common consumer-level 3D printers don't have automatic filament-swapping features, and prominent slicers like Cura don't allow the level of sub-layer control this project needs. As such, the bulk of the prints will be handled in the traditional model->slicer->gcode workflow, with an additional step to generate gcode for the fiducial markers and filament changes. \

Admittedly, this new workflow isn't the cleanest, as it uses [lua 5.1/5.2](https://www.lua.org/) to generate the extra gcode instead of remaining entirely in [Rhino/Grasshopper](https://www.rhino3d.com/). Given more time, the lua portion could likely be moved to grasshopper. However, there would still be some back-and-forth with your slicer regardless, as seen later. \

Before anything, make sure to download [lua](https://www.lua.org/) version 5.1 or 5.2, and [Rhino 8](https://www.rhino3d.com/). In Rhino, use the `Grasshopper` command to open Grasshopper, then load the [fez_grasshopper.gh](/printcode/rhino) file, and use a text editor or IDE of your choice to open [add_fez_gcode.lua](/printcode/lua/add_fez_gcode.lua). Both of these files have extensive config areas, including some parameters that are printer-specific, like buildplate size, nozzle output diameter, and print movement speeds. You'll want to make sure these match the specs of your own printer. \

Lastly, try to use matte filaments for everything but white. For instance, Hatchbox Black works quite well. I forgot to do this when purchasing my red and blue filaments, making them more susceptible to glare, but it's still usable. Speaking of, as long as you use bright red and blue filaments, they should be detected, though the exact filaments I used were the red and blue 'Easy PLA' filaments from Overture. \

Once you're ready, follow these steps to prepare each print:

1. Use [fez_grasshopper.gh](/printcode/rhino) in Rhino to generate models and lua code snippets. More details can be found in the grasshopper file.
2. Slice the models in Cura (or your slicer of choice).
3. Make some slight adjustments to the end of the resulting gcode file, noted shortly later.
4. Use [add_fez_gcode.lua](/printcode/lua/add_fez_gcode.lua) and the lua snippets from part 1 to generate the extra gcode.
5. Insert the new gcode, as described below, and print. Prints will first use white filament, then black, and if needed, red and/or blue.


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

Here, the lines of interest are `G1 F2400 E299.88946` (the last `G1` command) and `M205 X20 Y20` (the last `M205` command). \
For the `G1` line, replace the value after the `E` with a `-0.6`, then insert several blank lines and `M83 ; relative extrusion mode` directly above. \
For the `M205` line, remove it. \

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

The specifics may vary per printer and slicer, so you'll need to carefully look for any differences in gcode commands your slicer outputs. [Reprap.org](https://reprap.org/wiki/G-code) has a page detailing many gcode commands for many kinds of firmwares. For the examples above, I was using an Ender 3 V3 and Cura. \

One more thing you need to do with the sliced gcode is to look for the last-used X, Y, Z values. You'll find these in `G0` and `G1` commands, most likely finding the X and Y right at the very end, and the Z somewhere earlier, with the help of ctrl-F searching. If your gcode has a bunch of small numbers in the range of 1-10 instead of hundreds, there's a good chance your slicer used relative positioning instead of absolute positioning. If it did, you'll need to see if your slicer has options to use absolute positioning instead and re-slice the model. \

Once you have the last-used X, Y, Z values, go to [add_fez_gcode.lua](/printcode/lua/add_fez_gcode.lua) and use them to define `startingPos` in the config area. This lets the script pick up where the printer last left off, to prevent any misalignments. Then, towards the bottom of the file is a section to paste the lua code snippet generated by the grasshopper script. \

To run the lua script, open a command prompt and use the `cd` command to navigate to the top-level folder of this repo in your local files. Then, use `lua52 ./printcode/lua/add_fez_gcode.lua`. Replace `lua52` with `lua51` if you installed lua 5.1, etc. It will then create a `test_out.txt` file with the gcode to be copied and pasted into the blank space you made earlier in the gcode file. Now you can start printing! \

Since not all printers support a gcode command to pause the print and wait for user input, whenever the print needs to change filament, it will rise up and move side-to-side to get your attention. When it does, use your printer's control interface to pause the print, cut the filament, swap the rolls, and extrude until the new filament is fully in. Then, resume the print and wait for the side-to-side to stop, where it will then release some filament in the air to ensure the nozzle is good to go (some printers suddenly eject filament when resuming a print, emptying the nozzle). While it does this, carefully collect the loose filament onto a folded paper towel and *gently* wipe the nozzle clean without disturbing its position.