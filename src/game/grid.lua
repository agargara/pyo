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
            4
        )
    end

    -- initialize grid with random tile array
    self.init_grid = function()
        self.grid = {}
        for row=1, game.grid_height do
            self.grid[row] = {}
            for col=1, game.grid_width do
                self.grid[row][col] = Tile(math.random(1, self.game.num_tile_types))
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
                self.draw_tile(row, col, self.grid[row][col])
            end
        end
        -- draw cursor
        self.draw_cursor()
    end

    self.draw_tile = function(row, col, tile)
        love.graphics.setColor(self.game.theme.tiles[tile.type])
        love.graphics.rectangle(
            "fill",
            self.margin["left"] + ((row-1) * self.tile_width) + self.tile_padding,
            self.margin["top"]  + ((col-1) * self.tile_height) + self.tile_padding,
            self.tile_width - (self.tile_padding*2),
            self.tile_height - (self.tile_padding*2)
        )
    end

    self.draw_cursor = function()
        -- x/y offsets
        local xo = self.margin["left"] + (self.cursor.x-1)*self.tile_width + self.tile_padding
        local yo = self.margin["top"]  + (self.cursor.y-1)*self.tile_height + self.tile_padding
        local radius = self.cursor.radius * self.tile_width
        -- draw outline
        love.graphics.setColor({0,0,0})
        love.graphics.setLineWidth(self.cursor.thickness + 2)
        love.graphics.rectangle(
            "line",
            xo - ((self.cursor.thickness) * 0.5),
            yo - ((self.cursor.thickness) * 0.5),
            self.tile_width  + self.cursor.thickness - (self.tile_padding*2),
            self.tile_height + self.cursor.thickness - (self.tile_padding*2),
            radius
        )
        -- draw fill
        love.graphics.setColor(self.cursor.color)
        love.graphics.setLineWidth(self.cursor.thickness)
        love.graphics.rectangle(
            "line",
            xo - (self.cursor.thickness * 0.5),
            yo - (self.cursor.thickness * 0.5),
            self.tile_width  + self.cursor.thickness - (self.tile_padding*2),
            self.tile_height + self.cursor.thickness - (self.tile_padding*2),
            radius
        )
    end

    self.increase_cursor_size = function()
        self.cursor.thickness = self.cursor.thickness + 1
    end

    self.init(game)
    return self
end
