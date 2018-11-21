-- pyo
require 'game/state'
require 'game/grid'
require 'game/theme'
require 'game/hud'


function Game ()
    local self = {}

    -- initialization:
    self.init = function ()
        self.theme = Theme(self)
        self.grid_width = 8
        self.grid_height = 8
        self.num_tile_types = 6

        self.das = 0.2 -- delay auto shift (key repeat delay)
        self.das_timer = 0

        self.state = State(self)
        self.grid = Grid(self)
        self.hud  = HUD(self)

        self.restart()
    end

    -- restart the game:
    self.restart = function ()
        self.grid.restart()
    end

    -- draw the game:
    self.draw = function ()
        love.graphics.setBackgroundColor(self.theme.background)
        self.grid.draw()
        self.hud.draw()
    end

    -- update the game logic:
    self.update = function (dt)
        self.handle_held_keys(dt)
        self.grid.update(dt)
    end

    self.handle_held_keys = function(dt)
        self.das_timer = self.das_timer + dt
        if self.das_timer >= self.das then
            -- hjkl: movement keys (vim style)
            if love.keyboard.isDown('h') then
                self.grid.cursor.move(-1, 0)
            elseif love.keyboard.isDown('j') then
                self.grid.cursor.move(0, 1)
            elseif love.keyboard.isDown('k') then
                self.grid.cursor.move(0, -1)
            elseif love.keyboard.isDown('l') then
                self.grid.cursor.move(1, 0)
            else
                -- reset timer if no keys held
                self.das_timer = 0
            end
        end
    end

    -- handle keyboard input:
    self.keypressed = function (key)
        -- d: double leap
        if key == 'd' then
            self.grid.cursor.leap = 2
        -- hjkl: movement keys (vim style)
        elseif key == 'h' then
            self.grid.cursor.move(-1, 0)
            self.das_timer = 0
        elseif key == 'j' then
            self.grid.cursor.move(0, 1)
            self.das_timer = 0
        elseif key == 'k' then
            self.grid.cursor.move(0, -1)
            self.das_timer = 0
        elseif key == 'l' then
            self.grid.cursor.move(1, 0)
            self.das_timer = 0
        -- s: select current tile
        elseif key == 's' then
            self.grid.select_tile()
        -- t: change theme
        elseif key == 't' then
            self.theme.load_next_theme()
        end
    end

    self.keyreleased = function(key)
        if key == 's' then
            self.grid.deselect_tile()
        end
    end

    self.init()
    return self
end
