--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Projectile = Class{}

local origx = 0
local origy = 0

function Projectile:init(object, speed, range)
    self.object = object
    self.speed = speed
    self.range = range
    self.finish = false
    origx = self.object.x
    origy = self.object.y

    -- default empty collision callback
    self.onCollide = function() end
end

function Projectile:update(dt)
    if self:distance() < self.range*TILE_SIZE then
        self.object.x = self.object.x + self.speed.dx*dt
        self.object.y = self.object.y + self.speed.dy*dt
        self.object:update()
    else
        self.finish = true
    end
end

function Projectile:render()
    self.object:render(0,0)
    --love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
    --self.x, self.y)
end

function Projectile:distance()
    disx = math.abs(self.object.x - origx)
    disy = math.abs(self.object.y - origy)
    return math.sqrt(disx*disx + disy*disy)
end

function Projectile:wallCollide()
    if self.object.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
        return true
    end
    if self.object.x + self.object.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
        return true
    end
    if self.object.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.object.height / 2 then 
        return true
    end
    local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
                        + MAP_RENDER_OFFSET_Y - TILE_SIZE
    if self.object.y + self.object.height >= bottomEdge then
        return true
    end
    return false
end

function Projectile:collides(target)
    local selfY, selfHeight = self.object.y + self.object.height / 2, self.object.height - self.object.height / 2
    return not (self.object.x + self.object.width < target.x or self.object.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end