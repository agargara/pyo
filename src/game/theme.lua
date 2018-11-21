local theme1 = {
    background = 0xf4f4f8,   -- white
    tiles = {
        0xae3a3a, -- red
        0x2f8b2f, -- green
        0x313F76, -- blue
        0xaea93a, -- yellow
        0x542d75, -- purple
        0xae8a3a, -- gold
    }
}

local theme2 = {
    background = 0xf4f4f8,   -- white
    tiles = {
        0xfe4a49, -- red
        0x4afe49, -- green
        0x2ab7ca, -- blue
        0xfed766, -- yellow
        0xe6e6ea, -- grey
        0x643d85, -- purple
    }
}

local themes = { theme1, theme2 }

function Theme (game)
    local self = {}

    -- initialization:
    self.init = function (game)
        self.background = nil
        self.tiles = nil

        self.theme_index = 1
        self.load_theme(self.theme_index)
    end

    -- load a given theme:
    self.load_theme = function (index)
        local theme = themes[index]

        self.background = self.hex_to_rgb(theme.background)
        self.tiles = self.hex_to_rgb(theme.tiles)

        self.theme_index = index
    end

    -- load the next theme to the current one:
    self.load_next_theme = function ()
        local index = self.theme_index + 1

        if index > #themes then
            index = 1
        end

        self.load_theme(index)
    end

    self.hex_to_rgb = function(hex)
        if (type(hex) == "table") then
            rgb_table = {}
            for key, value in pairs(hex) do
                rgb_table[key] = self.hex_to_rgb(value)
            end
            return rgb_table
        else
            local r = bit.rshift(bit.band(hex, 0xFF0000), 16)
            local g = bit.rshift(bit.band(hex, 0x00FF00), 8)
            local b = bit.band(hex, 0x0000FF)
            return {r, g, b}
        end
    end

    self.init()
    return self
end
