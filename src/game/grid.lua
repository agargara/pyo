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
        self.clear_speed = 255*1.4 -- larger numbers are faster
        -- time to wait before letting tiles fall (seconds)
        self.fall_delay = 0.2
        -- time since last clear
        self.last_clear = 0
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

    -- update: animate each tile in grid, handle cleared tiles
    self.update = function (dt)
        local columns_to_update = {}
        local no_tiles_clearing = true
        -- check each tile in grid:
        for row=1, #self.grid do
            for col=1, #self.grid[row] do
                local t = self.grid[row][col]
                -- if tile is clearing, update fade animation
                if t.clearing then
                    no_tiles_clearing = false
                    -- decrease alpha (fade out)
                    t.alpha = math.max(t.alpha - (self.clear_speed * dt), 0)
                    -- when alpha 0 is reached, clear tile
                    if t.alpha <= 0 then
                        -- change from "clearing" to "cleared" (swap now possible)
                        t.clearing = false
                        t.cleared = true
                    end
                elseif t.cleared then
                    t.dead_time = t.dead_time + dt
                    if t.dead_time > self.fall_delay then
                        -- mark column for update
                        columns_to_update[col] = true
                    else
                        no_tiles_clearing = false
                    end
                end
            end
        end
        -- after checking all tiles, update marked columns
        for col in pairs(columns_to_update) do
            self.update_column(col)
        end
        -- if no tiles were clearing/cleared before fall delay,
        -- increase time since last clear
        if no_tiles_clearing then
            self.last_clear = self.last_clear + dt
            -- reset chain counter after last clear
            if self.last_clear > 0.1 then
                self.game.state.chain = 0
                self.game.state.combo = 0
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
        -- do not allow swapping from blank tile, or if either tile is clearing
        if (
            self.grid[row1][col1].cleared or
            self.grid[row1][col1].clearing or
            self.grid[row2][col2].clearing
        ) then
            return
        end
        -- if target tile is nil or cleared, apply gravity to swapped tile
        -- TODO
        -- if not self.grid[row2][col2] or self.grid[row2][col2].cleared then
        --
        -- end
        -- swap
        self.grid[row1][col1], self.grid[row2][col2] = self.grid[row2][col2], self.grid[row1][col1]
        -- check if a match was made from either of the swapped tiles
        local matches = self.find_matches_from_tile(row1, col1)
        local matches2 = self.find_matches_from_tile(row2, col2)
        -- merge matches
        for k,v in pairs(matches2) do matches[k] = v end
        -- report matched tiles to state
        self.game.state.report_matches(matches)
        self.last_clear = 0
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
            (not self.grid[row][col].clearing) and
            (not self.grid[row][col].cleared) and
            self.grid[row][col].type == t
        )
    end

    -- update a column by checking for deleted blocks and making blocks fall
    self.update_column = function(col)
        -- start with lowest row and move up
        for row = self.game.grid_height, 1, -1 do
            local t = self.grid[row][col]
            -- if t is cleared, blocks above should fall
            if t.cleared and t.dead_time > self.fall_delay then
                -- find first non-cleared tile above
                local row_above = row - 1
                while row_above > 0 and self.grid[row_above][col].cleared do
                    row_above = row_above - 1
                end
                -- if row above is OOB, make new random tile
                if row_above < 1 then
                    local type = math.random(1, self.game.num_tile_types)
                    self.grid[row][col] = Tile(self, type, 4)
                -- otherwise swap with tile above unless it is clearing
                elseif not self.grid[row_above][col].clearing then
                    self.grid[row][col], self.grid[row_above][col] = self.grid[row_above][col], self.grid[row][col]
                    -- deselect fallen tile
                    self.grid[row][col].selected = false
                end
                -- reselect cursor tile if swapping
                if self.swapping then
                    self.grid[self.cursor.row][self.cursor.col].selected = true
                end
            end
        end
        -- find new matches created by fallen blocks
        for row = self.game.grid_height, 1, -1 do
            local t = self.grid[row][col]
            -- if there are cleared tiles below this tile, do not process matches
            local skip = false
            for row_below = row + 1, self.game.grid_height, 1 do
                if self.grid[row_below][col].cleared then
                    skip = true
                    break
                end
            end
            if skip then break end
            -- find and erase new matches
            local matches = self.find_matches_from_tile(row, col)
            -- report matched tiles to state
            self.last_clear = 0
            self.game.state.report_matches(matches)
            for point in pairs(matches) do
                self.grid[point[1]][point[2]].clearing = true
            end
        end
    end

    self.init(game)
    return self
end
