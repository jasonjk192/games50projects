--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerCarryWalkState = Class{__includes = EntityWalkState}

function PlayerCarryWalkState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerCarryWalkState:enter(params)
    self.objID = params.objID
    self.obj = params.obj
end

function PlayerCarryWalkState:update(dt)
    self.obj.x = self.entity.x
    self.obj.y = self.entity.y - self.entity.height/3

    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('walk-carry-left')
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('walk-carry-right')
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('walk-carry-up')
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('walk-carry-down')
    else
        self.entity:changeState('carry-idle',{objID = self.objID , obj = self.obj})
    end

    EntityWalkState.update(self, dt)
    if love.keyboard.wasPressed('space') then
        if self.entity.direction == 'left' then
            proj = Projectile(self.obj, {dx=-PROJECTILE_SPEED*1.5,dy=0} ,6)
        elseif self.entity.direction == 'right' then
            proj = Projectile(self.obj, {dx=PROJECTILE_SPEED*1.5,dy=0} ,6)
        elseif self.entity.direction == 'up' then
            proj = Projectile(self.obj, {dx=0,dy=-PROJECTILE_SPEED*1.5} ,6)
        elseif self.entity.direction == 'down' then
            proj = Projectile(self.obj, {dx=0,dy=PROJECTILE_SPEED*1.5} ,6)
        end
        table.insert(self.dungeon.currentRoom.projectiles,proj)
        gSounds['sword']:play()
        table.remove(self.dungeon.currentRoom.objects,self.objID)
        self.entity:changeState('idle')
    end
end

function PlayerCarryWalkState:render()
    EntityWalkState.render(self)
    self.obj:render(0,0)
end