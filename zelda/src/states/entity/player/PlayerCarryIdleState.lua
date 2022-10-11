--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerCarryIdleState = Class{__includes = EntityIdleState}

function PlayerCarryIdleState:init(player, dungeon)
    self.entity=player
    self.dungeon=dungeon
end

function PlayerCarryIdleState:enter(params)
    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
    self.entity:changeAnimation('idle-carry-' .. self.entity.direction)
    self.objID = params.objID
    self.obj = params.obj

    self.obj.x = self.entity.x
    self.obj.y = self.entity.y - self.entity.height/3

    if self.entity.direction == 'left' then
        self.drop_obj_x = self.entity.x - self.entity.width - 2
        self.drop_obj_y = self.entity.y
    elseif self.entity.direction == 'right' then
        self.drop_obj_x = self.entity.x + self.obj.width + 2
        self.drop_obj_y = self.entity.y
    elseif self.entity.direction == 'up' then
        self.drop_obj_x = self.entity.x
        self.drop_obj_y = self.entity.y - self.obj.height - 2
    else
        self.drop_obj_x = self.entity.x
        self.drop_obj_y = self.entity.y + self.entity.height + 2
    end
end

function PlayerCarryIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('carry-walk',{objID = self.objID , obj = self.obj})
    end
    
    if love.keyboard.wasPressed('return') then
        self.obj.x = self.drop_obj_x
        self.obj.y = self.drop_obj_y
        self.obj.solid = true
        self.entity:changeState('idle')
    end

    if love.keyboard.wasPressed('space') then
        if self.entity.direction == 'left' then
            proj = Projectile(self.obj, {dx=-PROJECTILE_SPEED,dy=0} ,4)
        elseif self.entity.direction == 'right' then
            proj = Projectile(self.obj, {dx=PROJECTILE_SPEED,dy=0} ,4)
        elseif self.entity.direction == 'up' then
            proj = Projectile(self.obj, {dx=0,dy=-PROJECTILE_SPEED} ,4)
        elseif self.entity.direction == 'down' then
            proj = Projectile(self.obj, {dx=0,dy=PROJECTILE_SPEED} ,4)
        end
        table.insert(self.dungeon.currentRoom.projectiles,proj)
        gSounds['sword']:play()
        table.remove(self.dungeon.currentRoom.objects,self.objID)
        self.entity:changeState('idle')
    end
end

function PlayerCarryIdleState:render()
    EntityIdleState.render(self)
    self.obj:render(0,0)
end