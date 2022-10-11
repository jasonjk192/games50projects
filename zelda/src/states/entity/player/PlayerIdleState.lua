--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    self.entity.offsetY = 5
    self.entity.offsetX = 0
    self.entity:changeAnimation('idle-' .. self.entity.direction)
end

function PlayerIdleState:enter(params)
    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0

    local direction = self.entity.direction
    
    local hitboxX, hitboxY, hitboxWidth, hitboxHeight

    if direction == 'left' then
        hitboxWidth = 12
        hitboxHeight = 24
        hitboxX = self.entity.x - hitboxWidth
        hitboxY = self.entity.y
    elseif direction == 'right' then
        hitboxWidth = 12
        hitboxHeight = 24
        hitboxX = self.entity.x + self.entity.width
        hitboxY = self.entity.y
    elseif direction == 'up' then
        hitboxWidth = 24
        hitboxHeight = 20
        hitboxX = self.entity.x - hitboxWidth/2 + self.entity.width/2
        hitboxY = self.entity.y - hitboxHeight/2
    else
        hitboxWidth = 24
        hitboxHeight = 20
        hitboxX = self.entity.x - hitboxWidth/2 + self.entity.width/2
        hitboxY = self.entity.y + self.entity.height/2
    end

    self.objectHitbox = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
    end

    if love.keyboard.wasPressed('return') then
        for k, object in pairs(self.dungeon.currentRoom.objects) do
            if object:collides(self.objectHitbox) then
                if object.type == 'pot' then
                    self.entity:changeState('lift', {objID = k , obj = object})
                    break
                end
            end
        end
    end
end

function PlayerIdleState:render()
    EntityIdleState.render(self)
    --[[love.graphics.setColor(1, 0, 1, 1)
    love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
    love.graphics.rectangle('line', self.objectHitbox.x, self.objectHitbox.y,
        self.objectHitbox.width, self.objectHitbox.height)
    love.graphics.setColor(1, 1, 1, 1)]]
end

function debugHitbox()
-- debug for player and hurtbox collision rects
    love.graphics.setColor(1, 0, 1, 1)
    love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
    love.graphics.rectangle('line', self.objectHitbox.x, self.objectHitbox.y,
        self.objectHitbox.width, self.objectHitbox.height)
    love.graphics.setColor(1, 1, 1, 1)
end