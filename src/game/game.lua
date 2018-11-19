-- pyo
require 'game/grid'

function Game ()
    local self = {}

    -- initialization:
    self.init = function ()
        self.grid_width = 8
        self.grid_height = 8
        self.background = { 0, 0, 0 }

        self.grid = Grid(self)

        self.restart()
    end

    -- restart the game:
    self.restart = function ()
        self.grid.restart()
    end

    -- draw the game:
    self.draw = function ()
        love.graphics.setBackgroundColor(self.background)
        self.grid.draw()
    end

    -- update the game logic:
    self.update = function (dt)
        self.grid.update(dt)
    end

    -- handle keyboard input:
    self.keypressed = function (key)
        print(key)
    end

    self.init()
    return self
end
