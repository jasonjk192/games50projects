--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

KEYS=0

local balls = {}
local paddle_increase_score = 0

function addBalls(x, y)
    local ball = Ball()
    ball.x=x
    ball.y=y
    ball.dx = math.random(-200, 200)
    ball.dy = math.random(-50, -60)
    ball.skin = math.random(7)
    table.insert(balls, ball)
end

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level
    self.lockedbricks = params.lockedbricks or 0
    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
    table.insert(balls,self.ball)
    self.powerup = Powerups()
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
            gSounds['music']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        gSounds['music']:pause()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    if self.powerup.inPlay then 
        self.powerup:update(dt)
        if self.powerup:collides(self.paddle) then
            if self.powerup.type==9 then
                addBalls(self.paddle.x,self.paddle.y-8)
                self.powerup.inPlay=false
            elseif self.powerup.type==10 then
                KEYS=KEYS+1
                self.powerup.inPlay=false
            end
        end 
    end
    for kb, b in pairs(balls) do
        b:update(dt)
        
        if b:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            b.y = self.paddle.y - 8
            b.dy = -b.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if b.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                b.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - b.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif b.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                b.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - b.x))
            end

            gSounds['paddle-hit']:play()
        end
    

    -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and b:collides(brick) then

                -- add to score
                if not brick.locked then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                end
                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                if brick.locked and not brick.inPlay then
                    self.score = self.score + 1000
                    self.lockedbricks=self.lockedbricks-1
                end

                if not self.powerup.inPlay and not brick.locked then
                    if math.random(1,2)==2 and self.lockedbricks>0 and KEYS<self.lockedbricks then
                        self.powerup.x=brick.x
                        self.powerup.y=brick.y
                        self.powerup.type=10
                        self.powerup.inPlay=true
                    else
                        self.powerup.x=brick.x
                        self.powerup.y=brick.y
                        self.powerup.type=9
                        self.powerup.inPlay=true
                    end
                end

                paddle_increase_score=paddle_increase_score+(brick.tier * 200 + brick.color * 25)

                if paddle_increase_score>1000 then
                    paddle_increase_score=0
                    self.paddle.size=math.min(4,self.paddle.size+1)
                    self.paddle.width = math.min(128,self.paddle.width+32)
                end

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()
                    balls={}
                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if b.x + 2 < brick.x and b.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    b.dx = -b.dx
                    b.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif b.x + 6 > brick.x + brick.width and b.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    b.dx = -b.dx
                    b.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif b.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    b.dy = -b.dy
                    b.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    b.dy = -b.dy
                    b.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(b.dy) < 150 then
                    b.dy = b.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end

    -- if ball goes below bounds, revert to serve state and decrease health
        if b.y >= VIRTUAL_HEIGHT and #balls==1 then
            self.health = self.health - 1
            self.paddle.size = math.max(1,self.paddle.size-1)
            self.paddle.width = math.max(32,self.paddle.width-32)
            paddle_increase_score=0
            gSounds['hurt']:play()

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    lockedbricks = self.lockedbricks,
                    recoverPoints = self.recoverPoints
                })
            end
        elseif b.y >= VIRTUAL_HEIGHT and #balls>1 then
            table.remove(balls,kb)
        end
    end


    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for k, b in pairs(balls) do
        b:render(dt)
    end

    if self.powerup.inPlay then self.powerup:render() end

    if self.lockedbricks>0 then PlayState:displayKeys() end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end

function PlayState:displayKeys()
    -- simple FPS display across all states
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('KEYS: ' .. tostring(KEYS), 5, 25)
    love.graphics.setColor(255, 255, 255, 255)
end