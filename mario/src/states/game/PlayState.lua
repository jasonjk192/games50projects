--[[
    GD50
    Super Mario Bros. Remake

    -- PlayState Class --
]]

PlayState = Class{__includes = BaseState}

key_color = 0

function PlayState:init()
    self.camX = 0
    self.camY = 0
    
    self.background = math.random(3)
    self.backgroundX = 0
    self.gravityOn = true
    self.gravityAmount = 6
    
    key_color=math.random(4)
end

function PlayState:enter(def)
    self.levelno = def.levelno
    self.score = def.score
    self.level = LevelMaker.generate((self.levelno-1)*50+50, 10)
    self.tileMap = self.level.tileMap
    clearx=PlayState:returnSolidGround(self.tileMap)

    self.player = Player({
        x = (clearx-1)*TILE_SIZE, y = 0,
        width = 16, height = 20,
        texture = 'green-alien',
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkingState(self.player) end,
            ['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
            ['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end
        },
        map = self.tileMap,
        level = self.level,
        levelno = self.levelno,
        score = self.score
    })

    self:spawnEnemies()

    self.player:changeState('falling')
end

function PlayState:update(dt)
    Timer.update(dt)

    if love.keyboard.wasPressed('r') and DEBUG_ON then
        gStateMachine:change('start')
    end

    if love.keyboard.wasPressed('t') and DEBUG_ON then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end

    -- remove any nils from pickups, etc.
    self.level:clear()

    -- update player and level
    self.player:update(dt)
    self.level:update(dt)

    -- constrain player X no matter which state
    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end

    self:updateCamera()
end

function PlayState:render()
    love.graphics.push()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    -- translate the entire view of the scene to emulate a camera
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))
    
    self.level:render()

    self.player:render()
    love.graphics.pop()
    
    -- render score
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(tostring(self.player.score), 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(self.player.score), 4, 4)

    --render level no
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print('World '..tostring(self.player.levelno), VIRTUAL_WIDTH-44, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('World '..tostring(self.player.levelno), VIRTUAL_WIDTH-45, 4)

    --render key graphic
    if self.player.key>0 then 
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.draw(gTextures['locks_keys'], gFrames['locks_keys'][key_color],5, 15)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(gTextures['locks_keys'], gFrames['locks_keys'][key_color],4, 14)
    end


    if DEBUG_ON then
        displayText('lock : '..tostring(LevelMaker.getlx())..','..tostring(LevelMaker.getly()),10,40)
        displayText('key : '..tostring(LevelMaker.getkx())..','..tostring(LevelMaker.getky()),10,50)
        displayText('player : '..tostring(math.round(self.player.x/16))..','..tostring(math.round(self.player.y/16)),10,60)
        displayText(tostring(self.player.key),10,70)
        displayText('level : '..tostring(self.levelno),10,80)
    end

    
end

function displayText(text, x,y)
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print(text, x, y)
    love.graphics.setColor(1,1,1,1)
end

function PlayState:updateCamera()
    -- clamp movement of the camera's X between 0 and the map bounds - virtual width,
    -- setting it half the screen to the left of the player so they are in the center
    self.camX = math.max(0,
        math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

    -- adjust background X to move a third the rate of the camera for parallax
    self.backgroundX = (self.camX / 3) % 256
end

--[[
    Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
    -- spawn snails in the level
    for x = 1, self.tileMap.width do

        -- flag for whether there's ground on this column of the level
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    -- random chance, 1 in 20
                    if math.random(20) == 1 then
                        
                        -- instantiate snail, declaring in advance so we can pass it into state machine
                        local snail
                        snail = Snail {
                            texture = 'creatures',
                            x = (x - 1) * TILE_SIZE,
                            y = (y - 2) * TILE_SIZE + 2,
                            width = 16,
                            height = 16,
                            stateMachine = StateMachine {
                                ['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
                                ['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
                                ['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
                            }
                        }
                        snail:changeState('idle', {
                            wait = math.random(5)
                        })

                        table.insert(self.level.entities, snail)
                    end
                end
            end
        end
    end
end

function PlayState:returnSolidGround(tileMap)
    for x = 1, tileMap.width do
        local groundFound = false
        for y = 1, tileMap.height do
            if not groundFound then
                if tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    return x
                end
            end
        end
    end
    return -1
end

function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end