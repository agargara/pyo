require 'game/util'

-- keep track of game state (score, chain count, etc.)
function State (game)
    local self = {}

    -- initialization:
    self.init = function (game)
        self.game = game
        self.score = 0
        self.chain = 0
        self.combo = 0
        self.last_chain_time = 0
    end

    -- reset state:
    self.restart = function ()
        self.score = 0
        self.chain = 0
        self.combo = 0
    end

    -- report new matches
    self.report_matches = function(matches)
        -- count tiles in match
        local num_tiles = 0
        for point in pairs(matches) do num_tiles = num_tiles + 1 end
        if num_tiles > 0 then
            self.combo = num_tiles
            -- increase chain counter if time has passed since last chain
            if ((love.timer.getTime() - self.last_chain_time) > 0.01) then
                self.chain = self.chain + 1
                self.last_chain_time = love.timer.getTime()
            end
            -- increase score for each tile in match
            self.score = self.score + (self.chain * self.combo_to_score(self.combo))
        end
    end

    -- convert combo to score
    self.combo_to_score = function(combo)
        if combo == 3 then
            return 10
        elseif combo == 4 then
            return 50
        elseif combo == 5 then
            return 100
        else
            return round_to_x(combo * (combo / 1.2) * 10, 10)
        end
    end

    self.init(game)
    return self
end
