function clamp(val, lower, upper)
    assert(val and lower and upper, "error: val, lower, upper required for clamp")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function mix_colors(c1, c2, mix)
	local c = {0,0,0}
	for i=1,3 do
		c[i] = (c1[i] + (c2[i] - c1[i]) * mix)
	end
    if c1[4] ~= nil then c[4] = c1[4] end
	return c
end

-- Count the number of non-nil keys in a table...because lua is stupid
function count_keys(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end
