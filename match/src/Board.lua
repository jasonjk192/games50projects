--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]
local enableHelp = false

Board = Class{}
local dropShiny=false

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    self.level = level or 1
    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(math.min(18,self.level*3)), math.random(math.min(6,self.level))))
        end
    end

    while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        local hasShiny = self.tiles[y][1].isShiny

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
                if not hasShiny then
                    hasShiny = self.tiles[y][x].isShiny
                end
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color
                if matchNum<3 then hasShiny = self.tiles[y][x].isShiny end
                
                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    if matchNum >= 4 then
                        dropShiny=true
                    end
                    local match = {}
                    if hasShiny then
                        for x2 = 1, 8 do
                            table.insert(match, self.tiles[y][x2])
                        end
                    else
                    -- go backwards from here by matchNum
                        for x2 = x - 1, x - matchNum, -1 do
                            
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end
                    end
                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            if matchNum >= 4 then
                dropShiny=true
            end
            local match = {}
            if hasShiny then
                for x2 = 1, 8 do
                    table.insert(match, self.tiles[y][x2])
                end
            else
            -- go backwards from end of last row by matchNum
                for x = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end
            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    if matchNum >= 4 then
                        dropShiny=true
                    end
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                        if self.tiles[y2][x].isShiny then
                            for x2 = 1, 8 do
                                table.insert(match, self.tiles[y2][x2])
                            end
                        end
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            if matchNum >= 4 then
                dropShiny=true
            end
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
                if self.tiles[y][x].isShiny then
                    for x2 = 1, 8 do
                        table.insert(match, self.tiles[y][x2])
                    end
                end
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = Tile(x, y, math.random(math.min(18,self.level*3)), math.random(math.min(6,self.level)))
                if dropShiny then
                    tile = Tile(x, y, math.random(math.min(18,self.level*3)), math.random(math.min(6,self.level)),true)
                    dropShiny = false
                end
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

local caseno = 0
local y1=0 x1=0 y2=0 x2=0

function Board:checkPossibleMoves()
    for y = 1, 8 do
        for x = 1,6 do
            --checking for y, x+2
            if self.tiles[y][x].color == self.tiles[y][x+1].color then
                y1=y x1=x+2
                if x+3<=8 then if self.tiles[y][x].color == self.tiles[y][x+3].color then caseno=11 y2=y x2=x+3 return y,x+2,y,x+3 end
                elseif y+1<=8 then if self.tiles[y][x].color == self.tiles[y+1][x+2].color then caseno=12 y2=y+1 x2=x+2 return y,x+2,y+1,x+2 end
                elseif y-1>=1 then if self.tiles[y][x].color == self.tiles[y-1][x+2].color then caseno=13 y2=y-1 x2=x+2 return y,x+2,y-1,x+2 end
                end
            --checking for y, x
            elseif self.tiles[y][x+1].color == self.tiles[y][x+2].color then
                y1=y x1=x
                if x-1>=1 then if self.tiles[y][x+1].color == self.tiles[y][x-1].color then y2=y x2=x-1 caseno=21 return y,x,y,x-1 end
                elseif y+1<=8 then if self.tiles[y][x+1].color == self.tiles[y+1][x].color then y2=y+1 x2=x caseno=22 return y,x,y+1,x end
                elseif y-1>=1 then if self.tiles[y][x+1].color == self.tiles[y-1][x].color then y2=y-1 x2=x caseno=23 return y,x,y-1,x end
                end
            --checking for y, x+1
            elseif self.tiles[y][x].color == self.tiles[y][x+2].color then
                y1=y x1=x+1
                if y+1<=8 then if self.tiles[y][x].color == self.tiles[y+1][x+1].color then y2=y+1 x2=x+1 caseno=31 return y,x+1,y+1,x+1 end
                elseif y-1>=1 then if self.tiles[y][x].color == self.tiles[y-1][x+1].color then y2=y-1 x2=x+1 caseno=32 return y,x+1,y-1,x+1 end
                end
            end
        end
    end
    for x = 1, 8 do
        for y = 1,6 do
            --checking for y+2, x
            if self.tiles[y+1][x].color == self.tiles[y][x].color then
                y1=y+2 x1=x
                if y+3<=8 then if self.tiles[y][x].color == self.tiles[y+3][x].color then y2=y+3 x2=x caseno=41 return y+2,x,y+3,x end
                elseif x+1<=8 then if self.tiles[y][x].color == self.tiles[y+2][x+1].color then y2=y+2 x2=x+1 caseno=42 return y+2,x,y+2,x+1 end
                elseif x-1>=1 then if self.tiles[y][x].color == self.tiles[y+2][x-1].color then y2=y+2 x2=x-1 caseno=43 return y+2,x,y+2,x-1 end
                end
            --checking for y, x
            elseif self.tiles[y+1][x].color == self.tiles[y+2][x].color then
                y1=y x1=x
                if y-1>=1 then if self.tiles[y+1][x].color == self.tiles[y-1][x].color then y2=y-1 x2=x caseno=51 return y,x,y-1,x end
                elseif x+1<=8 then if self.tiles[y+1][x].color == self.tiles[y][x+1].color then y2=y x2=x+1 caseno=52 return y,x,y,x+1 end
                elseif x-1>=1 then if self.tiles[y+1][x].color == self.tiles[y][x-1].color then y2=y x2=x-1 caseno=53 return y,x,y,x-1 end
                end
            --checking for y+1, x
            elseif self.tiles[y][x].color == self.tiles[y+2][x].color then
                y1=y+1 x1=x
                if x+1<=8 then if self.tiles[y][x].color == self.tiles[y+1][x+1].color then y2=y+1 x2=x+1 caseno=61 return y+1,x,y+1,x+1 end
                elseif x-1>=1 then if self.tiles[y][x].color == self.tiles[y+1][x-1].color then y2=y+1 x2=x-1 caseno=62 return y+1,x,y+1,x-1 end
                end
            end
        end
    end
    return -1,-1,-1,-1
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
    if enableHelp then
        displayText('Tile 1 : '..tostring(x1)..', '..tostring(y1) , 5, VIRTUAL_HEIGHT-30)
        displayText('Tile 2 : '..tostring(x2)..', '..tostring(y2) , 5, VIRTUAL_HEIGHT-25)
        displayText('case : '..tostring(caseno) , 5, VIRTUAL_HEIGHT-20)
    end
end

function displayText(text, x,y)
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print(text, x, y)
    love.graphics.setColor(1,1,1,1)
end