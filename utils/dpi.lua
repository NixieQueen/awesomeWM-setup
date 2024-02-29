-- This utility is like the default awesomeWM dpi() option, except it can distinguish between width and height among other small tweaks
-- The default dpi everything was written on is 2256x1504 3:2 13.5 inch.
local config = {
  width = 2256,
  height = 1504,
}

local dpi_width = function(width,s)
  if s then
    return width * (s.geometry.width / config.width)
  else
    return width
  end
end

local dpi_height = function(height,s)
  if s then
    return height * (s.geometry.height / config.height)
  else
    return height
  end
end

local dpi_fixed = function(wihe,s)
  if s then
    return math.min(dpi_width(wihe,s), dpi_height(wihe,s))
  else
    return wihe
  end
end

return {
  dpi_width = dpi_width,
  dpi_height = dpi_height,
  dpi_fixed = dpi_fixed
}
