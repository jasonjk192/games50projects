--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerLiftState = Class{__includes = BaseState}

function PlayerLiftState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.player.offsetY = 5
    self.player.offsetX = 0
    self.player:changeAnimation('lift-' .. self.player.direction)
end

function PlayerLiftState:enter(params)
    self.objID = params.objID
    self.obj = params.obj
    self.obj.solid = false
    self.player.currentAnimation:refresh()

    if self.player.direction == 'left' then
        self.obj_x = {self.player.x-8,self.player.x-8,self.player.x}
        self.obj_y = {self.player.y+4, self.player.y, self.player.y - self.player.height/3}
    elseif self.player.direction == 'right' then
        self.obj_x = {self.player.x+8,self.player.x+8,self.player.x}
        self.obj_y = {self.player.y+4, self.player.y, self.player.y - self.player.height/3}
    elseif self.player.direction == 'up' then
        self.obj_x = {self.obj.x,self.player.x,self.player.x}
        self.obj_y = {self.player.y+4, self.player.y, self.player.y - self.player.height/3}
    else
        self.obj_x = {self.player.x,self.player.x,self.player.x}
        self.obj_y = {self.player.y+4, self.player.y, self.player.y - self.player.height/3}
    end
end

function PlayerLiftState:update(dt)
    self.obj.x = self.obj_x[self.player.currentAnimation.currentFrame]
    self.obj.y = self.obj_y[self.player.currentAnimation.currentFrame]
    if self.player.currentAnimation.finish then
        self.player:changeState('carry-idle',{objID = self.objID , obj=self.obj})
    end
end

function PlayerLiftState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end