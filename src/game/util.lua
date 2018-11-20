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
	return c
end
