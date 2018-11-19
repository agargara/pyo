function clamp(val, lower, upper)
    assert(val and lower and upper, "error: val, lower, upper required for clamp")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end
