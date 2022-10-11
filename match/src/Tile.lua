--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, shiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.isShiny = shiny or false
    if self.isShiny then
        self.alphaShiny = 0.5
        Timer.every(0.1, function()
            if self.alphaShiny<0.4 then
                self.alphaShiny  = self.alphaShiny+0.05
            else
                self.alphaShiny = 0.05
            end
        end)
    end
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    if self.isShiny then
        love.graphics.setBlendMode('add')

        love.graphics.setColor(1, 1, 1, self.alphaShiny)
        love.graphics.rectangle('fill', self.x +x,self.y+y, 32, 32, 4)

        -- back to alpha
        love.graphics.setBlendMode('alpha')
    end
end