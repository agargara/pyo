-- cursor object with color and position
require 'game/util'

function Cursor (grid, row, col, color, thickness, gap)
    local self = {}

    -- initialization:
    self.init = function (grid, row, col, color, thickness, gap)
        self.grid = grid
        self.row = row
        self.col = col
        self.color = color
        self.thickness = thickness
        self.gap = gap
        self.radius = 0
    end

    self.move = function(x, y)
        -- do not allow moving if target cell does not exist,
        -- or if in swap mode and target cell is clearing
        local max_row = self.grid.game.grid_width
        local max_col = self.grid.game.grid_height
        local leap = 1
        if love.keyboard.isDown('d') then
            leap = 2 -- hold 'd' to leap two spaces
        end
        local target_row = self.row + (leap*y)
        local target_col = self.col + (leap*x)
        if (
            target_col > max_col or
            target_col < 1 or
            target_row > max_row or
            target_row < 1 or
            (self.grid.swapping and self.grid.grid[target_row][target_col].clearing)
        ) then
            return
        end
        -- if in swapping mode, swap tiles under old and new cursor positions
        if self.grid.swapping then
            self.grid.swap_tiles(self.row, self.col, target_row, target_col)
        end
        self.row = target_row
        self.col = target_col
    end

    self.draw = function()
        -- row/col offsets
        local w = self.grid.tile_width
        local h = self.grid.tile_height
        local p = self.grid.tile_padding
        local rowo = self.grid.margin["left"] + (self.row-1)*h + p - self.gap
        local colo = self.grid.margin["top"]  + (self.col-1)*w + p - self.gap
        local radius = self.radius * w
        love.graphics.setColor(self.color)
        love.graphics.setLineWidth(self.thickness)
        love.graphics.rectangle(
            "line",
            colo - (self.thickness * 0.5),
            rowo - (self.thickness * 0.5),
            w + self.thickness - (p*2) + (self.gap*2),
            h + self.thickness - (p*2) + (self.gap*2),
            radius
        )
    end

    self.init(grid, row, col, color, thickness, gap)
    return self
end
