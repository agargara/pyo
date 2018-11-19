-- grid which contains tiles,
-- also handles animations
require 'game/tile'

-- Create a new grid:
function Grid (game)
    local self = {}

    -- initialization:
    self.init = function (game)
        self.game = game
        -- possible colors
        self.colors = {
            {255, 255, 0},
            {255, 0, 255},
            {0, 255, 255}
        }
        -- make grid of tiles
        self.tile_width = 40
        self.tile_height = 40
        self.init_grid()
        -- grid display margin
        self.margin = {
            left = self.tile_width,
            top = self.tile_height
        }
    end

    -- initialize grid with random tile array
    self.init_grid = function()
        self.grid = {}
        for row=1, game.grid_height do
            self.grid[row] = {}
            for col=1, game.grid_width do
                local color = self.colors[math.random(#self.colors)]
                self.grid[row][col] = Tile(color)
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

    -- draw each tile in grid:
    self.draw = function ()
        for row=1, #self.grid do
            for col=1, #self.grid[row] do
                self.draw_tile(row, col, self.grid[row][col])
            end
        end
    end

    self.draw_tile = function(row, col, tile)
        love.graphics.setColor(tile.color)
        love.graphics.rectangle(
            "fill",
            self.margin["left"] + ((row-1) * self.tile_width),
            self.margin["top"]  + ((col-1) * self.tile_height),
            self.tile_width,
            self.tile_height
        )
    end

    self.init(game)
    return self
end
