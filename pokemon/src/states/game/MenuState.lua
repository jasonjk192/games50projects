--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

MenuState = Class{__includes = BaseState}

function MenuState:init(def)
    self.itemSelectable = def.itemSelectable
    self.state = def.state
    local size = #def.items * 18
    self.levelUpMenu = Menu {
        x = VIRTUAL_WIDTH/2 - 48,
        y = VIRTUAL_HEIGHT/2 - size/2,
        width = 96,
        height = size,
        itemSelectable = def.itemSelectable,
        items = def.items
        }
    self.onFinish = def.onFinish
end

function MenuState:exit()
    if self.onFinish then
        self.onFinish()
    end
end

function MenuState:update(dt)
    self.levelUpMenu:update(dt)
   if (love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter')) and not self.itemSelectable then
        gStateStack:pop()
    end
end

function MenuState:render()
    local prevfont = love.graphics.getFont()
    love.graphics.setFont(gFonts['small'])
    self.levelUpMenu:render()
    love.graphics.setFont(prevfont)
end