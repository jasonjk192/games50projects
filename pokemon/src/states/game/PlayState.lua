--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.level = Level()

    gSounds['field-music']:setLooping(true)
    gSounds['field-music']:play()

    self.dialogueOpened = false
end

function PlayState:update(dt)
    if not self.dialogueOpened and love.keyboard.wasPressed('m') then
        menu_items = {
            {
                text = self.level.player.party.pokemon[1].name .. " | level ".. self.level.player.party.pokemon[1].level,
                onSelect = function()
                    gStateStack:pop()
                    local pokemon_stats = {
                        {text="HP : "..tostring(self.level.player.party.pokemon[1].currentHP)},
                        {text="ATT : "..tostring(self.level.player.party.pokemon[1].attack)},
                        {text="DEF : "..tostring(self.level.player.party.pokemon[1].defense)},
                        {text="SPD : "..tostring(self.level.player.party.pokemon[1].speed)}
                    }
                    gStateStack:push(MenuState({itemSelectable = false, items=pokemon_stats}))
                end
            }
        }
        
        gStateStack:push(MenuState({itemSelectable = true, items=menu_items}))
    end
    if not self.dialogueOpened and love.keyboard.wasPressed('p') then
        
        -- heal player pokemon
        gSounds['heal']:play()
        self.level.player.party.pokemon[1].currentHP = self.level.player.party.pokemon[1].HP
        
        -- show a dialogue for it, allowing us to do so again when closed
        gStateStack:push(DialogueState('Your Pokemon has been healed!',
    
        function()
            self.dialogueOpened = false
        end))
    end

    self.level:update(dt)
end

function PlayState:render()
    self.level:render()
end