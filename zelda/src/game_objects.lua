--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['pot_1'] = {
        type = 'pot',
        texture = 'tiles',
        frame = 14,
        width = 16,
        height = 16,
        solid=true,
        defaultState = 'unbroken',
        states = {
            ['unbroken'] = { frame = 14 } ,
            ['broken'] = { frame = 52 }
        }
    },
    ['pot_2'] = {
        type = 'pot',
        texture = 'tiles',
        frame = 15,
        width = 16,
        height = 16,
        solid=true,
        defaultState = 'unbroken',
        states = {
            ['unbroken'] = { frame = 15 } ,
            ['broken'] = { frame = 53 }
        }
    },
    ['pot_3'] = {
        type = 'pot',
        texture = 'tiles',
        frame = 16,
        width = 16,
        height = 16,
        solid=true,
        defaultState = 'unbroken',
        states = {
            ['unbroken'] = { frame = 16 } ,
            ['broken'] = { frame = 54 }
        }
    },
    ['health'] = {
        type = 'health',
        texture = 'hearts',
        frame = 6,
        width = 16,
        height = 16,
        solid=false,
        consumable = true,
        defaultState = 'dropped',
        states = {
            ['dropped'] = {
                frame = 6
            }
        }
    },
}