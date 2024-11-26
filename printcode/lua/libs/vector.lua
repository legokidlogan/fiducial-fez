if Vector then return end


local vectorMeta = {}
local vectorMethods = {}
local xyz = { x = 1, y = 2, z = 3, [1] = 1, [2] = 2, [3] = 3, }

local debugGetmetatable = debug.getmetatable
local mathSqrt = math.sqrt


local function isnumber( x )
    return type( x ) == "number"
end

local function round( x, idp )
    local mult = 10 ^ ( idp or 0 )

    return math.floor( x * mult + 0.5 ) / mult
end


----- GLOBAL FUNCTIONS -----

function Vector( x, y, z )
    x = x or 0
    y = y or 0
    z = z or 0

    local vec = { x, y, z }
    setmetatable( vec, vectorMeta )

    return vec
end


----- METAMETHODS -----

function vectorMeta.__index( t, k )
    local method = vectorMethods[k]
    if method ~= nil then return method end

    local xyzInd = xyz[k]

    if xyzInd then
        return rawget( t, xyzInd )
    end
end

function vectorMeta.__newindex( t, k, v )
    local xyzInd = xyz[k]

    if xyzInd then
        rawset( t, xyzInd, v )
    end
end

function vectorMeta.__tostring( a )
    return "Vector( " .. a[1] .. ", " .. a[2] .. ", " .. a[3] .. " )"
end

function vectorMeta.__add( a, b )
    return Vector( a[1] + b[1], a[2] + b[2], a[3] + b[3] )
end

function vectorMeta.__sub( a, b )
    return Vector( a[1] - b[1], a[2] - b[2], a[3] - b[3] )
end

function vectorMeta.__mul( a, b )
    if isnumber( a ) then
        return Vector( a * b[1], a * b[2], a * b[3] )
    elseif isnumber( b ) then
        return Vector( a[1] * b, a[2] * b, a[3] * b )
    elseif debugGetmetatable( a ) == vectorMeta and debugGetmetatable( b ) == vectorMeta then
        return a[1] * b[1] + a[2] * b[2] + a[3] * b[3]
    else
        error( "Invalid multiplication" )
    end
end

function vectorMeta.__div( a, b )
    if isnumber( b ) then
        return Vector( a[1] / b, a[2] / b, a[3] / b )
    elseif debugGetmetatable( a ) == vectorMeta and debugGetmetatable( b ) == vectorMeta then
        return Vector( a[1] / b[1], a[2] / b[2], a[3] / b[3] )
    else
        error( "Invalid division" )
    end
end

function vectorMeta.__unm( a )
    return Vector( -a[1], -a[2], -a[3] )
end

function vectorMeta.__eq( a, b )
    return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end


----- INSTANCE FUNCTIONS -----

-- Returns the vector's length.
function vectorMethods:getLength()
    local x = self[1]
    local y = self[2]
    local z = self[3]

    return mathSqrt( x * x + y * y + z * z )
end

-- Returns the square of the vector's length.
function vectorMethods:getlengthSqr()
    local x = self[1]
    local y = self[2]
    local z = self[3]

    return x * x + y * y + z * z
end

-- Returns the vector's length in the xy plane.
function vectorMethods:getLength2D()
    local x = self[1]
    local y = self[2]

    return mathSqrt( x * x + y * y )
end

-- Returns the square of the vector's length in the xy plane.
function vectorMethods:getLength2DSqr()
    local x = self[1]
    local y = self[2]

    return x * x + y * y
end

-- Returns a new vector with the same direction but with a length of 1.
function vectorMethods:getNormalized()
    local x = self[1]
    local y = self[2]
    local z = self[3]

    local length = mathSqrt( x * x + y * y + z * z )

    return Vector( x / length, y / length, z / length )
end

-- Normalizes the vector. Self-modifies.
function vectorMethods:normalize()
    local x = self[1]
    local y = self[2]
    local z = self[3]

    local length = mathSqrt( x * x + y * y + z * z )

    self[1] = x / length
    self[2] = y / length
    self[3] = z / length

    return self
end

-- Returns the distance between this vector and another.
function vectorMethods:getDistance( b )
    local x = self[1] - b[1]
    local y = self[2] - b[2]
    local z = self[3] - b[3]

    return mathSqrt( x * x + y * y + z * z )
end

-- Returns the square of the distance between this vector and another.
function vectorMethods:getDistanceSqr( b )
    local x = self[1] - b[1]
    local y = self[2] - b[2]
    local z = self[3] - b[3]

    return x * x + y * y + z * z
end

-- Dot product of this vector and another.
function vectorMethods:dot( b )
    return self[1] * b[1] + self[2] * b[2] + self[3] * b[3]
end

-- Cross product of this vector and another.
function vectorMethods:cross( b )
    local ax = self[1]
    local ay = self[2]
    local az = self[3]

    local bx = b[1]
    local by = b[2]
    local bz = b[3]

    return Vector( ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx )
end

-- Returns a new vector with each component rounded by idp decimal places.
function vectorMethods:getRounded( idp )
    return Vector( round( self[1], idp ), round( self[2], idp ), round( self[3], idp ) )
end

-- Rounds each component by idp decimal places. Self-modifies.
function vectorMethods:round( idp )
    self[1] = round( self[1], idp )
    self[2] = round( self[2], idp )
    self[3] = round( self[3], idp )

    return self
end

-- Is this vector equal to zero?
function vectorMethods:isZero()
    return self[1] == 0 and self[2] == 0 and self[3] == 0
end

-- Adds another vector to this one. Self-modifies.
function vectorMethods:add( b )
    self[1] = self[1] + b[1]
    self[2] = self[2] + b[2]
    self[3] = self[3] + b[3]

    return self
end

-- Subtracts another vector from this one. Self-modifies.
function vectorMethods:sub( b )
    self[1] = self[1] - b[1]
    self[2] = self[2] - b[2]
    self[3] = self[3] - b[3]

    return self
end

-- Multiplies this vector by a scalar. Self-modifies.
function vectorMethods:mul( s )
    self[1] = self[1] * s
    self[2] = self[2] * s
    self[3] = self[3] * s

    return self
end

-- Divides this vector by a scalar. Self-modifies.
function vectorMethods:div( s )
    self[1] = self[1] / s
    self[2] = self[2] / s
    self[3] = self[3] / s

    return self
end

-- Performs piecewise multiplication with another vector. Self-modifies.
function vectorMethods:vmul( b )
    self[1] = self[1] * b[1]
    self[2] = self[2] * b[2]
    self[3] = self[3] * b[3]

    return self
end

-- Performs piecewise division with another vector. Self-modifies.
function vectorMethods:vdiv( b )
    self[1] = self[1] / b[1]
    self[2] = self[2] / b[2]
    self[3] = self[3] / b[3]

    return self
end

-- Sets the x component and returns self.
function vectorMethods:setX( x )
    self[1] = x

    return self
end

-- Sets the y component and returns self.
function vectorMethods:setY( y )
    self[2] = y

    return self
end

-- Sets the z component and returns self.
function vectorMethods:setZ( z )
    self[3] = z

    return self
end

-- Sets all components to 0 and returns self.
function vectorMethods:setZero()
    self[1] = 0
    self[2] = 0
    self[3] = 0

    return self
end

-- Returns a copy of this vector.
function vectorMethods:clone()
    return Vector( self[1], self[2], self[3] )
end

-- Copies the values of b into this vector and returns self.
function vectorMethods:setFrom( b )
    self[1] = b[1]
    self[2] = b[2]
    self[3] = b[3]

    return self
end
