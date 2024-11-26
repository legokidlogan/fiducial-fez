local shapeSize = 5
local letterToShape = {}
local shapes = {
    squiggle = { [0] = {
        { 0, 0, 0, 0, 0 },
        { 1, 1, 0, 1, 1 },
        { 0, 1, 1, 1, 0 },
        { 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0 },
    } },
    swirl = { [0] = {
        { 0, 0, 0, 0, 0 },
        { 0, 1, 1, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 1, 1, 1, 1, 0 },
        { 0, 0, 0, 0, 0 },
    } },
    side = { [0] = {
        { 0, 0, 0, 0, 0 },
        { 0, 0, 0, 1, 1 },
        { 0, 0, 0, 1, 0 },
        { 0, 0, 0, 1, 1 },
        { 0, 0, 0, 0, 0 },
    } },
    corner = { [0] = {
        { 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0 },
        { 1, 1, 0, 0, 0 },
        { 0, 1, 0, 0, 0 },
    } },
    zag = { [0] = {
        { 0, 0, 0, 0, 0 },
        { 1, 1, 0, 0, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 1, 1, 1 },
        { 0, 0, 0, 0, 0 },
    } },
    tree = { [0] = {
        { 0, 0, 0, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 1, 1, 1, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 0, 0, 0, 0 },
    } },

    cornerTL = { [0] = {
        { 0, 0, 1, 0, 0 },
        { 0, 1, 1, 0, 0 },
        { 0, 0, 1, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 0, 0 },
    } },
    cornerTR = { [0] = {
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 1, 0 },
    } },
    cornerBL = { [0] = {
        { 0, 1, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 1, 0 },
        { 1, 1, 0, 0, 0 },
        { 0, 1, 0, 1, 0 },
    } },
    cornerBR = { [0] = {
        { 0, 0, 1, 1, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 0, 0, 1, 0 },
    } },

    plus = { [0] = {
        { 0, 0, 0, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 1, 1, 1, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 0, 0, 0 },
    } },

    englishA = { [0] = {
        { 0, 0, 1, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 1, 0 },
        { 0, 1, 0, 1, 0 },
    } },
    englishB = { [0] = {
        { 0, 1, 1, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 0, 0 },
    } },
    englishC = { [0] = {
        { 0, 1, 1, 1, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 1, 1, 0 },
    } },
    englishD = { [0] = {
        { 0, 1, 1, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 0, 0 },
    } },
    englishE = { [0] = {
        { 0, 1, 1, 1, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 1, 1, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 1, 1, 0 },
    } },
    englishF = { [0] = {
        { 0, 1, 1, 1, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 1, 1, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 0, 0, 0 },
    } },
    englishG = { [0] = {
        { 0, 1, 1, 1, 0 },
        { 1, 0, 0, 0, 0 },
        { 1, 0, 1, 1, 0 },
        { 1, 0, 0, 1, 0 },
        { 0, 1, 1, 1, 0 },
    } },
    englishH = { [0] = {
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
    } },
    englishI = { [0] = {
        { 0, 1, 1, 1, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 1, 1, 1, 0 },
    } },
    englishJ = { [0] = {
        { 0, 1, 1, 1, 0 },
        { 0, 0, 0, 1, 0 },
        { 0, 0, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 0, 1, 0, 0 },
    } },
    englishK = { [0] = {
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
    } },
    englishL = { [0] = {
        { 0, 1, 0, 0, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 1, 1, 0 },
    } },
    englishM = { [0] = {
        { 1, 0, 0, 0, 1 },
        { 1, 1, 0, 1, 1 },
        { 1, 0, 1, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
    } },
    englishN = { [0] = {
        { 1, 0, 0, 1, 0 },
        { 1, 1, 0, 1, 0 },
        { 1, 0, 1, 1, 0 },
        { 1, 0, 0, 1, 0 },
        { 1, 0, 0, 1, 0 },
    } },
    englishO = { [0] = {
        { 1, 1, 1, 1, 1 },
        { 1, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 1, 1, 1, 1, 1 },
    } },
    englishP = { [0] = {
        { 0, 1, 1, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 0, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 1, 0, 0, 0 },
    } },
    englishQ = { [0] = {
        { 0, 0, 0, 0, 0 },
        { 0, 1, 1, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 1, 0 },
        { 0, 0, 0, 0, 1 },
    } },
    englishR = { [0] = {
        { 0, 1, 1, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
    } },
    englishS = { [0] = {
        { 0, 0, 1, 1, 0 },
        { 0, 1, 0, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 0, 1, 0 },
        { 0, 1, 1, 0, 0 },
    } },
    englishT = { [0] = {
        { 0, 1, 1, 1, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
    } },
    englishU = { [0] = {
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 1, 1, 0 },
    } },
    englishV = { [0] = {
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 0, 1, 0, 0 },
    } },
    englishW = { [0] = {
        { 1, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 1, 0, 1, 0, 1 },
        { 0, 1, 0, 1, 0 },
    } },
    englishX = { [0] = {
        { 1, 0, 0, 0, 1 },
        { 0, 1, 0, 1, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 1, 0, 1, 0 },
        { 1, 0, 0, 0, 1 },
    } },
    englishY = { [0] = {
        { 0, 1, 0, 1, 0 },
        { 0, 1, 0, 1, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
    } },
    englishZ = { [0] = {
        { 1, 1, 1, 1, 1 },
        { 0, 0, 0, 1, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 1, 0, 0, 0 },
        { 1, 1, 1, 1, 1 },
    } },
}


-- Rotates the shape 90 degrees clockwise rotAmount times, returning the matrix result.
-- Returns by reference.
local function rotateShape( shapeName, rotAmount )
    rotAmount = rotAmount % 4

    local rotations = shapes[shapeName]
    local shape = rotations[rotAmount]
    if shape then return shape end

    prevShape = rotateShape( shapeName, rotAmount - 1 )
    shape = {}

    for i = 1, shapeSize do
        shape[i] = {}
    end

    -- row 1 -> col 5, row 2 -> col 4, etc.
    for r = 1, shapeSize do
        local prevShapeRow = prevShape[r]

        for c = 1, shapeSize do
            shape[c][shapeSize - r + 1] = prevShapeRow[c]
        end
    end

    rotations[rotAmount] = shape

    return shape
end


do
    local letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }

    letterToShape.a = rotateShape( "squiggle", 0 )
    letterToShape.b = rotateShape( "swirl", 0 )
    letterToShape.c = rotateShape( "side", 0 )
    letterToShape.d = rotateShape( "corner", 0 )
    letterToShape.e = rotateShape( "zag", 0 )
    letterToShape.f = rotateShape( "tree", 0 )
    letterToShape.g = rotateShape( "squiggle", 1 )
    letterToShape.h = rotateShape( "swirl", 3 )
    letterToShape.i = rotateShape( "side", 3 )
    letterToShape.j = rotateShape( "corner", 3 )
    letterToShape.k = rotateShape( "zag", 3 )
    letterToShape.l = rotateShape( "tree", 3 )
    letterToShape.m = rotateShape( "squiggle", 2 )
    letterToShape.n = rotateShape( "swirl", 2 )
    letterToShape.o = rotateShape( "side", 2 )
    letterToShape.p = rotateShape( "corner", 2 )
    letterToShape.q = rotateShape( "zag", 3 )
    letterToShape.r = rotateShape( "tree", 2 )
    letterToShape.s = rotateShape( "squiggle", 3 )
    letterToShape.t = rotateShape( "swirl", 1 )
    letterToShape.u = rotateShape( "side", 1 )
    letterToShape.v = rotateShape( "side", 1 )
    letterToShape.w = rotateShape( "corner", 1 )
    letterToShape.x = rotateShape( "zag", 1 )
    letterToShape.y = rotateShape( "tree", 1 )
    letterToShape.z = rotateShape( "zag", 2 )

    for _, letterLower in ipairs( letters ) do
        local letterUpper = letterLower:upper()

        letterToShape[letterUpper] = letterToShape[letterLower]
    end
end


return {
    shapeSize = 5,
    shapes = shapes,
    letterToShape = letterToShape,
    rotateShape = rotateShape,
}
