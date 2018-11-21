-- tile object with tile type index
function Tile (grid, type, border)
    local self = {}

    -- initialization:
    self.init = function (grid, type, border)
        self.grid = grid
        self.type = type
        self.border = border
        self.selected = false
        self.clearing = false
        self.cleared = false
        self.alpha = 1.0
        self.dead_time = 0
    end

    -- draw this tile
    self.draw = function(row, col)
        local color = self.grid.game.theme.tiles[self.type]
        -- brighten color if tile is selected
        if self.selected then
            color = (mix_colors(color, {1, 1, 1}, 0.5))
        end
        color[4] = self.alpha -- set alpha

        -- row/col offsets
        local w = self.grid.tile_width
        local h = self.grid.tile_height
        local p = self.grid.tile_padding
        local rowo = self.grid.margin["left"] + (row-1)*h + p
        local colo = self.grid.margin["top"]  + (col-1)*w + p
        -- fill
        love.graphics.setColor(mix_colors(color, {1, 1, 1}, 0.2))
        love.graphics.rectangle(
            "fill",
            colo,
            rowo,
            w - (p*2),
            h - (p*2)
        )
        -- outline
        if self.border and self.border > 0 then
            love.graphics.setColor(color)
            love.graphics.setLineWidth(self.border)
            love.graphics.rectangle(
                "line",
                colo + (self.border*0.5),
                rowo + (self.border*0.5),
                w - (p*2) - self.border,
                h - (p*2) - self.border
            )
        end
    end

    self.init(grid, type, border)
    return self
end
