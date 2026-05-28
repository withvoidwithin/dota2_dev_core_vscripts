---- ════════════════════════════════════════════════════════════════
----        Copyright © WITHVOIDWITHIN — All rights reserved.
----         https://steamcommunity.com/id/withvoidwithin/
----               https://withvoidwithin.github.io/
---- ════════════════════════════════════════════════════════════════

--- @class _Utils
local Utils = {}

---- Numbers
---- ================================================================================================================================

--- Clamps a number between an optional minimum and maximum value.
--- If only `min` is provided, the value is clamped from below.
--- If only `max` is provided, the value is clamped from above.
--- If neither is provided, the original value is returned unchanged.
--- @param number number The value to clamp
--- @param min? number Optional lower bound
--- @param max? number Optional upper bound
--- @return number
--- **[ Server / Client ]**
function Utils:Clamp(number, min, max)
    if min and number < min then return min end
    if max and number > max then return max end
    return number
end

--- Generates a random number using a triangular (or V-shaped) distribution.
--- The peak of the distribution is controlled by `bias`, interpolated between `min` and `max`.
--- When `inverted` is true, the distribution is flipped into a V-shape,
--- making values near the peak less likely and values near the edges more likely.
--- @param min number Lower bound of the range
--- @param max number Upper bound of the range
--- @param bias? number Peak position as a normalized value [0, 1] (default: 0.5)
--- @param inverted? boolean Whether to invert into a V-shaped distribution (default: false)
--- @return number
--- **[ Server / Client ]**
function Utils:RandomDist(min, max, bias, inverted)
    bias = _Clamp(bias or 0.5, 0.001, 0.999)

    local u = RandomFloat(0, 1)
    local range = max - min

    if not inverted then
        if u < bias then
            return min + range * math.sqrt(u * bias)
        else
            return max - range * math.sqrt((1.0 - u) * (1.0 - bias))
        end
    else
        if u < bias then
            return min + (range * bias) * (1.0 - math.sqrt(u / bias))
        else
            return (min + range * bias) + (range * (1.0 - bias)) * math.sqrt((u - bias) / (1.0 - bias))
        end
    end
end

--- Remaps a number from one range [in_min, in_max] to another [out_min, out_max].
--- Input clamping is optional — if `should_clamp` is true, the input is clamped
--- to [in_min, in_max] before remapping, preventing out-of-range output values.
--- @param number number The value to remap
--- @param in_min number Input range lower bound
--- @param in_max number Input range upper bound
--- @param out_min number Output range lower bound
--- @param out_max number Output range upper bound
--- @param should_clamp? boolean Whether to clamp the input to [in_min, in_max] (default: false)
--- @return number
--- **[ Server / Client ]**
function Utils:Remap(number, in_min, in_max, out_min, out_max, should_clamp)
    if should_clamp then
        number = _Clamp(number, in_min, in_max)
    end
    return out_min + (number - in_min) * (out_max - out_min) / (in_max - in_min)
end

--- Rounds a number to a specified number of decimal places.
--- If `decimals` is not provided, rounds to the nearest integer.
--- Negative `decimals` rounds to the left of the decimal point (e.g. -1 rounds to tens).
--- @param number number The value to round
--- @param decimals? number Number of decimal places (default: 0)
--- @return number
--- **[ Server / Client ]**
function Utils:Round(number, decimals)
    local factor = 10 ^ (decimals or 0)
    return math.floor(number * factor + 0.5) / factor
end

---- Strings
---- ================================================================================================================================

--- Splits a string by a given separator into an array of substrings.
--- Empty parts (e.g. from a trailing separator) are ignored.
--- @param str string The string to split
--- @param sep? string Separator pattern (default: " ")
--- @return table
--- **[ Server / Client ]**
function Utils:SplitString(str, sep)
    sep = sep or " "
    local result = {}
    for part in str:gmatch("([^" .. sep .. "]+)") do
        result[#result + 1] = part
    end
    return result
end

---- Vectors
---- ================================================================================================================================

--- Returns a random point inside a square (AABB) defined by a center and half-size.
--- @param center Vector Center of the square
--- @param half_size number Half-size of the square
--- @return Vector
--- **[ Server / Client ]**
function Utils:GetRandomPointInSquare(center, half_size)
    return Vector(
        center.x + RandomFloat(-half_size, half_size),
        center.y + RandomFloat(-half_size, half_size),
        center.z
    )
end

--- Returns a random point inside a circle defined by a center and radius.
--- Uses rejection-free polar method for uniform distribution.
--- @param center Vector Center of the circle
--- @param radius number Radius of the circle
--- @return Vector
--- **[ Server / Client ]**
function Utils:GetRandomPointInCircle(center, radius)
    local angle = RandomFloat(0, 2 * math.pi)
    local dist = radius * math.sqrt(RandomFloat(0, 1))
    return Vector(
        center.x + dist * math.cos(angle),
        center.y + dist * math.sin(angle),
        center.z
    )
end

---- Tables
---- ================================================================================================================================

--- Returns a random key from a table, including both array and hash parts.
--- Returns nil if the table is empty.
--- @param tbl table The table to pick from
--- @return any
--- **[ Server / Client ]**
function Utils:GetTableRandomKey(tbl)
    local keys = {}
    for k in pairs(tbl) do
        keys[#keys + 1] = k
    end
    if #keys == 0 then return nil end
    return keys[RandomInt(1, #keys)]
end

--- Returns a random value from a table, including both array and hash parts.
--- Returns nil if the table is empty.
--- @param tbl table The table to pick from
--- @return any
--- **[ Server / Client ]**
function Utils:GetTableRandomValue(tbl)
    return tbl[_GetTableRandomKey(tbl)]
end

--- Returns the total number of elements in a table, including both array and hash parts.
--- Unlike the # operator, this correctly counts non-sequential and mixed tables.
--- @param tbl table The table to count
--- @return number
--- **[ Server / Client ]**
function Utils:GetTableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

return Utils
