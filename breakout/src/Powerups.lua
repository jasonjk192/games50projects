Powerups = Class{}

function Powerups:init(type, x , y)
    -- simple positional and dimensional variables
    self.width = 16
    self.height = 16
    self.x = x
    self.y = y
    self.type = type or 1
    self.inPlay = false
end

--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function Powerups:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function Powerups:update(dt)
    self.y = self.y + 30 * dt

    if self.y>VIRTUAL_HEIGHT then self.inPlay=false end
end

function Powerups:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type],self.x, self.y)
end