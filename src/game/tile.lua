-- tile object with color
function Tile (color)
    local self = {}

    -- initialization:
    self.init = function (color)
        self.color = color
    end

    self.init(color)
    return self
end
