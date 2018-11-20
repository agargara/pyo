-- grid which contains tiles and cursor.
require 'game/tile'
require 'game/cursor'

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
                until (self.find_match_from_tile(row, col) == false)
            end
        end
    end

    -- restart the grid:
    self.restart = function ()
        self.init_grid()
    end

    -- update the animation logic:
    self.update = function (dt)
        -- TODO
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
        self.grid[self.cursor.x][self.cursor.y].selected = true
    end

    -- deselect current tile (activated when 's' key is released)
    self.deselect_tile = function()
        self.swapping = false
        self.grid[self.cursor.x][self.cursor.y].selected = false
    end

    -- swap two tiles
    self.swap_tiles = function(x1, y1, x2, y2)
        -- swap
        local temp_tile = self.grid[x1][y1]
        self.grid[x1][y1] = self.grid[x2][y2]
        self.grid[x2][y2] = temp_tile
        -- check if a match was made from either of the swapped tiles
        if (
            self.find_match_from_tile(x1, y1) or
            self.find_match_from_tile(x2, y2)
        ) then
            print("match!")
        end
    end

    -- find a match starting from a specific tile, optional direction
    self.find_match_from_tile = function(row, col)
        local t = self.grid[row][col].type
        if (
            -- up
            (   self.tiles_match(row, col, row-1, col) and
                self.tiles_match(row, col, row-2, col)
            ) or
            -- right
            (   self.tiles_match(row, col, row, col+1) and
                self.tiles_match(row, col, row, col+2)
            ) or
            -- down
            (   self.tiles_match(row, col, row+1, col) and
                self.tiles_match(row, col, row+2, col)
            ) or
            -- left
            (   self.tiles_match(row, col, row, col-1) and
                self.tiles_match(row, col, row, col-2)
            ) or
            -- middle horizontal
            (   self.tiles_match(row, col, row, col-1) and
                self.tiles_match(row, col, row, col+1)
            ) or
            -- middle vertical
            (   self.tiles_match(row, col, row-1, col) and
                self.tiles_match(row, col, row+1, col)
            )
        ) then
            return true
        else
            return false
        end
    end

    -- test if two tiles at given coordinates match
    self.tiles_match = function(row1, col1, row2, col2)
        return (
            self.grid[row1] and
            self.grid[row2] and
            self.grid[row1][col1] and
            self.grid[row2][col2] and
            self.grid[row1][col1].type == self.grid[row2][col2].type
        )
    end

    self.init(game)
    return self
end
