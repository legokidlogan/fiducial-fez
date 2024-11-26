
--[[
    - This script is for examining the hamming distance of symbols used in this project,
        and outputting them in js format for use with creating the website.
    - You will not need to use this, it is merely for my own reference.
--]]

require( "printcode/lua/libs/vector" )
local fezShapes = require( "printcode/lua/libs/fez_shapes" )

local shapeSize = fezShapes.shapeSize
local letterToShape = fezShapes.letterToShape
local shapes = fezShapes.shapes
local rotateShape = fezShapes.rotateShape


local outFileName = "test_out.txt"


local nameReplacements = {
    ["K"] = "KQ",
    ["Q"] = "KQ",
    ["U"] = "UV",
    ["V"] = "UV",
}
local letterNames = {
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "R", "S", "T", "U", "W", "X", "Y", "Z",
    --"Q", "V",
}
local shapeNames = { "cornerTL", "cornerTR", "cornerBL", "cornerBR", }
local symbolShapes = {}
local symbolNames = {}

for i, name in ipairs( letterNames ) do
    symbolShapes[i] = letterToShape[name]
    symbolNames[i] = name
end

for _, name in ipairs( shapeNames ) do
    table.insert( symbolShapes, shapes[name][0] )
    table.insert( symbolNames, name )
end


local function getHammingDist( shape1, shape2 )
    if shape1 == shape2 then return 0 end

    local dist = 0

    for y = 1, shapeSize do
        for x = 1, shapeSize do
            if shape1[y][x] ~= shape2[y][x] then
                dist = dist + 1
            end
        end
    end

    return dist
end



-- Print out min and max hamming distances between all symbol shapes

local minHD = math.huge
local maxHD = -math.huge

for i = 1, #symbolShapes do
    for j = i + 1, #symbolShapes do
        local hd = getHammingDist( symbolShapes[i], symbolShapes[j] )
        minHD = math.min( minHD, hd )
        maxHD = math.max( maxHD, hd )
    end
end

print( "minHD = " .. minHD )
print( "maxHD = " .. maxHD )



-- Output symbol shapes in js format, to be used in the website

io.output( outFileName )

local jsStr = "var allSymbolBits = [\n"

for i, shape in ipairs( symbolShapes ) do
    jsStr = jsStr .. "  [ "

    for y = 1, shapeSize do
        jsStr = jsStr .. "["

        for x = 1, shapeSize do
            jsStr = jsStr .. shape[y][x]
            if x < shapeSize then jsStr = jsStr .. "," end
        end

        jsStr = jsStr .. "]"

        if y < shapeSize then jsStr = jsStr .. ", " end
    end

    local name = symbolNames[i]
    name = nameReplacements[name] or name

    jsStr = jsStr .. string.format( " ], // %2d %s\n", i - 1, name )
end

jsStr = jsStr .. "];"

io.write( jsStr )
