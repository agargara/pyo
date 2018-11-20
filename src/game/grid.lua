-- grid which contains tiles and cursor.
require 'game/tile'
require 'game/cursor'
require 'game/util'
local inspect = require 'lib/inspect'

-- Create a new grid:
function Grid (game)
    local self = {}

    -- initialization:
    self.init = function (game)
        self.game = game
        -- make grid of tiles
        self.tile_width = 40
        self.tile_height = 40
        self.tile_padding = 4
        self.init_grid()
        -- grid display margin
        self.margin = {
            left = self.tile_width,
            top = self.tile_height
        }
        -- init cursor
        self.cursor = Cursor(
            self,
            game.grid_height / 2,
            game.grid_width / 2,
            {0,0,0},
            4, --thickness
            0 --gap
        )
        -- in swap mode or not?
        self.swapping = false
        -- animation settings
        self.clear_speed = 1
    end

    -- initialize grid with random tile array
    self.init_grid = function()
        self.grid = {}
        for row=1, game.grid_height do
            self.grid[row] = {}
            for col=1, game.grid_width do
                repeat
                    local type = math.random(1, self.game.num_tile_types)
                    self.grid[row][col] = Tile(self, type, 4)
                until (next(self.find_matches_from_tile(row, col)) == nil)
            end
        end
    end

    -- restart the grid:
    self.restart = function ()
        self.init_grid()
    end

    -- update the animation logic:
    self.update = function (dt)
        -- update each tile in grid:
        for row=1, #self.grid do
            for col=1, #self.grid[row] do
                self.grid[row][col].update(dt, row, col)
            end
        end
    end

    self.draw = function ()
        -- draw each tile in grid:
        for row=1, #self.grid do
            for col=1, #self.grid[row] do
                self.grid[row][col].draw(row, col)
            end
        end
        -- draw cursor
        self.cursor.draw()
    end

    self.increase_cursor_size = function()
        self.cursor.thickness = self.cursor.thickness + 1
    end

    -- select current tile (activated when 's' key is pressed)
    self.select_tile = function()
        -- if already swapping, ignore input
        if self.swapping then
            return
        end
        self.swapping = true
        self.grid[self.cursor.row][self.cursor.col].selected = true
    end

    -- deselect current tile (activated when 's' key is released)
    self.deselect_tile = function()
        self.swapping = false
        self.grid[self.cursor.row][self.cursor.col].selected = false
    end

    -- swap two tiles
    self.swap_tiles = function(row1, col1, row2, col2)
        -- do not allow swapping if tiles are clearing
        if self.grid[row1][col1].clearing or self.grid[row2][col2].clearing then
            return
        end
        -- swap
        self.grid[row1][col1], self.grid[row2][col2] = self.grid[row2][col2], self.grid[row1][col1]
        -- check if a match was made from either of the swapped tiles
        local matches = self.find_matches_from_tile(row1, col1)
        local matches2 = self.find_matches_from_tile(row2, col2)
        -- merge matches
        for k,v in pairs(matches2) do matches[k] = v end
        -- erase matched tiles
        for point, v in pairs(matches) do
            self.grid[point[1]][point[2]].clearing = true
        end
    end

    -- find a match starting from a specific tile, optional direction
    self.find_matches_from_tile = function(row, col)
        local t = self.grid[row][col].type
        local vert_matches = {}
        local hori_matches = {}
        local matches = {}
        -- search up starting at row-1
        for r = row-1, 1, -1 do
            if self.tile_is_type(r, col, t) then
                vert_matches[{r,col}] = true
            else
                break
            end
        end
        -- search down starting at row+1
        for r = row+1, #self.grid, 1 do
            if self.tile_is_type(r, col, t) then
                vert_matches[{r,col}] = true
            else
                break
            end
        end
        -- search right starting at col+1
        for c = col+1, #self.grid[row], 1 do
            if self.tile_is_type(row, c, t) then
                hori_matches[{row,c}] = true
            else
                break
            end
        end
        -- search left starting at col-1
        for c = col-1, 1, -1 do
            if self.tile_is_type(row, c, t) then
                hori_matches[{row,c}] = true
            else
                break
            end
        end
        -- if 2 more more vertical matches, add to match array
        if count_keys(vert_matches) >= 2 then
            matches[{row,col}] = true
            for k,v in pairs(vert_matches) do matches[k] = v end
        end
        -- if 2 more more horizontal matches, add to match array
        if count_keys(hori_matches) >= 2 then
            matches[{row,col}] = true
            for k,v in pairs(hori_matches) do matches[k] = v end
        end
        return matches
    end

    -- test if a tile at given coordinate is a certain type
    self.tile_is_type = function(row, col, t)
        return (
            self.grid[row] and
            self.grid[row][col] and
            self.grid[row][col].type == t
        )
    end

    -- delete a tile
    self.delete_tile = function(row, col)
        -- replace tile with tile above, repeat to top
        -- TODO animate falling
        for r = row, 1, -1 do
            if r == 1 then
                -- at top, add random new tile that does not make a match
                repeat
                    local type = math.random(1, self.game.num_tile_types)
                    self.grid[r][col] = Tile(self, type, 4)
                until (next(self.find_matches_from_tile(r, col)) == nil)
            else
                self.grid[r][col] = self.grid[r-1][col]
            end
        end
        -- check for new matches caused by falling tiles
        for r = row, 1, -1 do
            local m = self.find_matches_from_tile(r, col)
            for point,v in pairs(m) do
                self.grid[point[1]][point[2]].clearing = true
            end
        end
    end

    self.init(game)
    return self
end
