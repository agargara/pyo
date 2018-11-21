-- heads-up display for score, chain count, etc.
function HUD (game)
    local self = {}

    -- initialization:
    self.init = function (game)
        self.game = game
        -- set font
        love.graphics.setNewFont("resources/LiberationSans-Regular.ttf", 14)
    end

    -- draw the hud:
    self.draw = function ()
        -- text that we will display:
        local score_text = "Score: "..self.game.state.score
        local chain_text = "Chain: "..self.game.state.chain
        local combo_text = "Combo: "..self.game.state.combo

        -- draw text:
        love.graphics.print(score_text, 10, 10)
        if self.game.state.chain > 0 then
            love.graphics.print(chain_text, 100, 10)
        end
        if self.game.state.combo > 0 then
            love.graphics.print(combo_text, 200, 10)
        end
    end

    self.init(game)
    return self
end
