--[[
	Credits to the guy who made the youtube video about this.
	I just wrote it here, since I needed it for some project.
	
	Credits:
		The Organic Chemistry Tutor @Youtube 
		Video Link : [https://youtu.be/watch?v=dYPRYO8QhxU]
		Synotize#0000 (Don't have discord for this yet.)
]]

local function AngleDistance(vec1, vec2)
    local Angle = math.deg(math.acos(vec1:Dot(vec2)))
    return string.format("%.2f", Angle)
end

-- [Testing]
local Vec1 = Vector2.new(-2, 5).Unit
local Vec2 = Vector2.new(4, 3).Unit

print(AngleDistance(Vec1, Vec2))