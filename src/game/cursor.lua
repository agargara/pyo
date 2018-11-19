-- cursor object with color and position
require 'game/util'

function Cursor (grid, x, y, color, thickness)
    local self = {}

    -- initialization:
    self.init = function (grid, x, y, color, thickness)
        self.grid = grid
        self.x = x
        self.y = y
        self.color = color
        self.thickness = thickness
        self.radius = 0
        self.leap = 1 -- amount to leap when moving
    end

    self.move = function(x, y)
        local max_x = self.grid.game.grid_width
        local max_y = self.grid.game.grid_height
        self.x = clamp(self.x + (self.leap * x), 1, max_x)
        self.y = clamp(self.y + (self.leap * y), 1, max_y)
        self.leap = 1 -- reset leap after movement
    end

    self.init(grid, x, y, color, thickness)
    return self
end
