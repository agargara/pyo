-- tile object with tile type index
function Tile (type)
    local self = {}

    -- initialization:
    self.init = function (type)
        self.type = type
    end

    self.init(type)
    return self
end
