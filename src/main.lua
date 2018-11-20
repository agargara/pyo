-- pyo

require 'game/game'

function love.load ()
    -- display title in window bar
    local major, minor, revision, codename = love.getVersion()
    love.window.setTitle(string.format("pyo (love2d %d.%d.%d)", major, minor, revision))

    -- initialize seed:
    math.randomseed(os.time())

    local game = Game()

    love.draw = game.draw
    love.update = game.update
    love.resize = game.resize
    love.keypressed = game.keypressed
    love.keyreleased = game.keyreleased
    love.mousepressed = game.mousepressed
end
