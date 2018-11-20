-- cursor object with color and position
require 'game/util'

function Cursor (grid, x, y, color, thickness, gap)
    local self = {}

    -- initialization:
    self.init = function (grid, x, y, color, thickness, gap)
        self.grid = grid
        self.x = x
        self.y = y
        self.color = color
        self.thickness = thickness
        self.gap = gap
        self.radius = 0
        self.leap = 1 -- amount to leap when moving
    end

    self.move = function(x, y)
        local old_x = self.x
        local old_y = self.y
        local max_x = self.grid.game.grid_width
        local max_y = self.grid.game.grid_height
        self.x = clamp(self.x + (self.leap * x), 1, max_x)
        self.y = clamp(self.y + (self.leap * y), 1, max_y)
        self.leap = 1 -- reset leap after movement
        -- if in swapping mode, swap tiles under old and new cursor positions
        if self.grid.swapping then
            self.grid.swap_tiles(old_x, old_y, self.x, self.y)
            -- if 's' is not held, deselect tile and cancel swap mode
            if not love.keyboard.isDown('s') then
                self.grid.grid[self.x][self.y].selected = false
                self.grid.swapping = false
            end
        end
    end

    self.draw = function()
        -- x/y offsets
        local w = self.grid.tile_width
        local h = self.grid.tile_height
        local p = self.grid.tile_padding
        local xo = self.grid.margin["left"] + (self.x-1)*w + p - self.gap
        local yo = self.grid.margin["top"]  + (self.y-1)*h + p - self.gap
        local radius = self.radius * w
        love.graphics.setColor(self.color)
        love.graphics.setLineWidth(self.thickness)
        love.graphics.rectangle(
            "line",
            xo - (self.thickness * 0.5),
            yo - (self.thickness * 0.5),
            w + self.thickness - (p*2) + (self.gap*2),
            h + self.thickness - (p*2) + (self.gap*2),
            radius
        )
    end

    self.init(grid, x, y, color, thickness, gap)
    return self
end
