--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerJumpState = Class{__includes = BaseState}

function PlayerJumpState:init(player, gravity)
    self.player = player
    self.gravity = gravity
    self.animation = Animation {
        frames = {3},
        interval = 1
    }
    self.player.currentAnimation = self.animation
end

function PlayerJumpState:enter(params)
    gSounds['jump']:play()
    self.player.dy = PLAYER_JUMP_VELOCITY
end

function PlayerJumpState:update(dt)
    self.player.currentAnimation:update(dt)
    self.player.dy = self.player.dy + self.gravity
    self.player.y = self.player.y + (self.player.dy * dt)

    -- go into the falling state when y velocity is positive
    if self.player.dy >= 0 then
        self.player:changeState('falling')
    end

    self.player.y = self.player.y + (self.player.dy * dt)

    -- look at two tiles above our head and check for collisions; 3 pixels of leeway for getting through gaps
    local tileLeft = self.player.map:pointToTile(self.player.x + 3, self.player.y)
    local tileRight = self.player.map:pointToTile(self.player.x + self.player.width - 3, self.player.y)

    -- if we get a collision up top, go into the falling state immediately
    if (tileLeft and tileRight) and (tileLeft:collidable() or tileRight:collidable()) then
        self.player.dy = 0
        self.player:changeState('falling')

    -- else test our sides for blocks
    elseif love.keyboard.isDown('left') then
        self.player.direction = 'left'
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
        self.player:checkLeftCollisions(dt)
    elseif love.keyboard.isDown('right') then
        self.player.direction = 'right'
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
        self.player:checkRightCollisions(dt)
    end

    -- check if we've collided with any collidable game objects
    for k, object in pairs(self.player.level.objects) do
        if object:collides(self.player) then
            if object.type == 'lock' and self.player.key>0 then
                gSounds['empty-block']:play()
                table.remove(self.player.level.objects, k)
                self.player.key = self.player.key - 1
                table.insert(self.player.level.objects,
                    GameObject {
                        texture = 'poles',
                        x = TILE_SIZE * (self.player.map.width - 2),
                        y = (3) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = math.random(6),
                    }
                )
                local animframe = 1+(math.random(4)-1)*3
                table.insert(self.player.level.objects,
                    GameObject {
                        texture = 'flags',
                        type= 'flag',
                        x = TILE_SIZE * (self.player.map.width - 1)-8,
                        y = (3) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        collidable=true,
                        consumable = true,
                        solid = false,
                        onConsume = function(player, object)
                            gSounds['pickup']:play()
                            gStateMachine:change('play', {
                                levelno = self.player.levelno+1,
                                score = self.player.score
                            }) end,
                        frame = animframe,
                        animation = Animation {
                            frames = {animframe, animframe+1},
                            interval = 0.5
                        }
                    }
                )
            elseif object.solid then
                object.onCollide(object)
                self.player.y = object.y + object.height
                self.player.dy = 0
                self.player:changeState('falling')
            elseif object.consumable then
                object.onConsume(self.player)
                table.remove(self.player.level.objects, k)
            end
        end
    end

    -- check if we've collided with any entities and die if so
    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self.player) then
            gSounds['death']:play()
            gStateMachine:change('start')
        end
    end
end