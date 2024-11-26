
require( "printcode/lua/libs/vector" )
local fezShapes = require( "printcode/lua/libs/fez_shapes" )

local shapeSize = fezShapes.shapeSize
local letterToShape = fezShapes.letterToShape
local shapes = fezShapes.shapes
local rotateShape = fezShapes.rotateShape


-- CONFIG
local startingPos = Vector( DEFINEME ) -- Starting position for symbol code, obtained by examining the last position in the base file.

local printerBounds = Vector( 220, 220, 250 ) -- The maximum bounds of the printable area, in mm.
local nozzleWidth = 0.4 -- Width of the nozzle, in mm.
local extrudeRate = 0.02 -- Rate of extrusion, in mm/mm.
local printSpeed = 800 -- Speed of the print head, in mm/s.
local travelSpeed = 1200 -- Speed of the print head when not extruding, in mm/s.
local printTemperature = 200 -- Temperature of the print head, in degrees Celsius.

local linesPerPixel = 5 -- Number of square rings per pixel. This must match linesPerPixel from the grasshopper file.
local layerHeight = 0.1 -- Height of each layer, in mm.
local symbolLayers = 2 -- Number of layers to print for each symbol.
local extrudeRetract = 0.6 -- Length to retract/unretract the filament by when raising up between distinct sections.

local upAndAwayHeight = 70 -- Height to move the printer to when going far out of the way.
local filamentChangeAttentionSpeed = 3000 -- Speed to move back and forth to get the user's attention, since many printers can't initiate a pause-and-wait-for-user command.
local filamentChangeAttentionPasses = 10
local filamentChangeExtrudeMoveAmount = 50 -- After unpausing a print, some printers (like the Ender 3 V3) suddenly eject filament, so we need to extrude some to fill the gap. False to disable.
local filamentChangeExtrudeMoveSpeed = 400
local filamentChangeExtrudeRate = 0.1

local outFileName = "test_out.txt"
-- END CONFIG


local gcodeCurPos = startingPos:clone()
local gcodeExtrudePos = 0
local gcodeCurTemperature = printTemperature
local pixelWidth = nozzleWidth * linesPerPixel
local outStr = ""


local function round( x, idp )
    local mult = 10 ^ ( idp or 0 )

    return math.floor( x * mult + 0.5 ) / mult
end

local function appendLine( str )
    outStr = outStr .. str .. "\n"
end

-- Move to a position with a specific speed and extrusion amount. Leave extrudeLength nil to not extrude.
local function gcodeMoveToRaw( pos, moveSpeed, extrudeLength )
    local x = pos[1]
    local y = pos[2]
    local z = pos[3]

    if x < 0 or x > printerBounds[1] or y < 0 or y > printerBounds[2] or z < 0 or z > printerBounds[3] then
        error( "Position out of bounds: " .. pos )
    end

    local str = "G1 X" .. x .. " Y" .. y .. " Z" .. z

    if extrudeLength then
        gcodeExtrudePos = gcodeExtrudePos + extrudeLength

        str = str .. " E" .. gcodeExtrudePos
    end

    str = str .. " F" .. moveSpeed
    gcodeCurPos = pos

    appendLine( str )
end

-- Moves to a location and (does or does not) extrude, using extrude rate and move speed params set in the config.
local function gcodeMoveTo( pos, doExtrude )
    if doExtrude then
        local dist = gcodeCurPos:getDistance( pos )

        gcodeMoveToRaw( pos, printSpeed, extrudeRate * dist )
    else
        gcodeMoveToRaw( pos, travelSpeed )
    end
end

local function gcodeMoveBy( posDelta, doExtrude )
    gcodeMoveTo( gcodeCurPos + posDelta, doExtrude )
end

local function gcodeExtrudeBy( extrudeDelta )
    if extrudeDelta == 0 then return end

    gcodeExtrudePos = gcodeExtrudePos + extrudeDelta

    appendLine( "G1 E" .. gcodeExtrudePos )
end

-- Move far up above the print
local function gcodeUpAndAway()
    local pos = Vector(
        gcodeCurPos[1],
        gcodeCurPos[2],
        upAndAwayHeight
    )

    gcodeMoveTo( pos, false )
end

local function gcodeSetTemperature( temp )
    appendLine( "M109 S" .. temp .. " ; Change temperature and wait" )
    gcodeCurTemperature = temp
end

local function gcodeChangeFilament( zOffsetWhenDone )
    zOffsetWhenDone = zOffsetWhenDone or 0

    local oldPos = gcodeCurPos:clone()
    local oldTemp = gcodeCurTemperature

    gcodeUpAndAway()

    local oldPosAbove = gcodeCurPos
    local z = oldPosAbove[3]

    appendLine( "\n; Change filament" )
    gcodeMoveTo( Vector( printerBounds[1] - 5, printerBounds[2] - 5, z ), false )

    local pos1 = gcodeCurPos:clone()
    local pos2 = pos1 + Vector( -printerBounds[1] / 2, 0, 0 )

    -- Get the user's attention so they can pause the print and change the filament.
    -- Ender-series printers seem to ignore M0, and doing it with manual gcode is risky, so let the user handle it.
    for _ = 1, filamentChangeAttentionPasses do
        gcodeMoveToRaw( pos2, filamentChangeAttentionSpeed, false )
        gcodeMoveToRaw( pos1, filamentChangeAttentionSpeed, false )
    end

    gcodeSetTemperature( oldTemp )

    if filamentChangeExtrudeMoveAmount then
        gcodeMoveToRaw( pos1 + Vector( 0, -filamentChangeExtrudeMoveAmount, 0 ), filamentChangeExtrudeMoveSpeed, filamentChangeExtrudeMoveAmount * filamentChangeExtrudeRate )
    end


    gcodeMoveTo( oldPosAbove, false )
    gcodeMoveTo( oldPos + Vector( 0, 0, zOffsetWhenDone ), false )
    gcodeExtrudeBy( 0.1 ) -- The first bit of extrusion usually struggles to stay on, assist it by pushing out some extra filament to smush onto the existing object.
    appendLine( "" )
end

--[[
    - Prints a series of concentric square rings, starting from the outermost ring and moving inward.

    center: (Vector)
        - The center position of the pixel (bottom in the z-axis).
    numLayers: (number)
        - The number of layers to print.
    outerRadius: (number)
        - The outer radius of the square to print.
    numSquares: (number)
        - The number of square rings to print.
        - Will get clamped to prevent overfilling of the square.
--]]
local function gcodePrintSquareRings( center, numLayers, outerRadius, numSquares )
    local maxSquares = outerRadius / nozzleWidth
    local maxSquaresCeil = math.ceil( maxSquares )
    local printDotInMiddle = false

    -- Clamp the number of squares.
    numSquares = math.min( numSquares or math.huge, maxSquaresCeil )

    local maxSquaresFloor = math.floor( maxSquares )

    if numSquares > maxSquaresFloor then
        -- If numSquares is >= floor(maxSquares) + 0.5, then also print a single dot to fill the center.
        printDotInMiddle = numSquares - maxSquaresFloor >= 0.5
        numSquares = maxSquaresFloor
    else
        -- Force the number of squares to be an integer.
        numSquares = math.floor( numSquares )
    end

    -- Adjust the outer radius to account for the nozzle width, putting us on the middle of the line.
    outerRadius = outerRadius - nozzleWidth / 2

    local layerUp = Vector( 0, 0, layerHeight )

    appendLine( "\n; square rings" )

    for _ = 1, numLayers do
        center = center + layerUp

        local radius = outerRadius

        for _ = 1, numSquares do
            gcodeMoveTo( center + Vector( -radius, radius, 0 ), false )
            gcodeMoveTo( center + Vector( radius, radius, 0 ), true )
            gcodeMoveTo( center + Vector( radius, -radius, 0 ), true )
            gcodeMoveTo( center + Vector( -radius, -radius, 0 ), true )
            gcodeMoveTo( center + Vector( -radius, radius - nozzleWidth / 2, 0 ), true )

            radius = radius - nozzleWidth
        end

        if printDotInMiddle then
            gcodeMoveBy( layerUp, false )
            gcodeMoveTo( center + layerUp, false )
            gcodeMoveTo( center, false )
            gcodeExtrudeBy( extrudeRate * nozzleWidth )
            gcodeMoveBy( layerUp, false )
        end

        -- Move straight up so we don't push into the previous layer when starting the next.
        gcodeMoveBy( layerUp, false )
    end

    appendLine( "" )
end

--[[
    - Prints a single pixel centered at the given position.
    - Based on the pixelWidth param in the config section.

    center: (Vector)
        - The center position of the pixel (bottom in the z-axis).
    numLayers: (number)
        - The number of layers to print.
--]]
local function gcodePrintPixel( center, numLayers )
    local outerRadius = pixelWidth / 2
    local numSquares = ( pixelWidth / nozzleWidth ) / 2

    gcodePrintSquareRings( center, numLayers, outerRadius, numSquares )
end

--[[
    - Prints a symbol at the given position.

    shape: (table of tables of numbers)
        - The shape to use for the symbol.
        - Should be a NxN grid of 1s and 0s.
        - Cell [1][1] is the top-left corner (from viewer's perspective), so low x and high y for typical printer coordinates.
    center: (Vector)
        - The center position of the symbol (bottom in the z-axis).
    doOnes: (boolean)
        - Whether to print the 1s or the 0s of the shape.
        - If false, will also add a one-pixel-wide border around the shape, as required by ArUco.

    - Example:
        - gcodePrintSymbol( letterToShape.a, Vector( 20, 20, tileHeight ), true )
--]]
local function gcodePrintSymbol( shape, center, doOnes )
    local shapeSizeEff = #shape
    local raiseAbove = Vector( 0, 0, layerHeight * ( symbolLayers + 1 ) + 5 )

    gcodeMoveTo( center + raiseAbove, false )

    local compareVal = doOnes and 1 or 0
    local topLeftLength = ( shapeSizeEff - 1 ) * pixelWidth / 2
    local topLeftPos = center + Vector( -topLeftLength, topLeftLength, 0 ) -- Center of the top left pixel.

    for r, row in ipairs( shape ) do
        for c, val in ipairs( row ) do
            if val == compareVal then
                local pos = topLeftPos + Vector( ( c - 1 ) * pixelWidth, - ( r - 1 ) * pixelWidth, 0 )

                gcodeExtrudeBy( -extrudeRetract )
                gcodeMoveTo( pos + raiseAbove, false )
                gcodeExtrudeBy( extrudeRetract )
                gcodePrintPixel( pos, symbolLayers )
            end
        end
    end

    if not doOnes then
        local numSquares = round( pixelWidth / nozzleWidth )
        local outerRadius = pixelWidth * ( shapeSizeEff / 2 + 1 )

        gcodeExtrudeBy( -extrudeRetract )
        gcodeMoveTo( topLeftPos + raiseAbove + Vector( -pixelWidth, pixelWidth, 0 ), false )
        gcodeExtrudeBy( extrudeRetract )
        gcodePrintSquareRings( center, symbolLayers, outerRadius, numSquares )
    end
end






io.output( outFileName )

appendLine( "; *************** FEZ Symbols **************" )
appendLine( "G92 E0 ; Reset extruder coords" )
appendLine( "G90 ; Absolute positioning" ) -- Note: Your file should already be using absolute positioning, in order to obtain startingPos!
appendLine( "M82 ; Absolute extrusion" )
--gcodeSetTemperature( printTemperature )



-- YOUR CODE HERE









-- END YOUR CODE



gcodeMoveTo( Vector( gcodeCurPos[1], gcodeCurPos[2], math.max( gcodeCurPos[3] + 50, printerBounds[3] - 5 ) ), false )
appendLine( "; *************** End FEZ Symbols **************" )

io.write( outStr )
