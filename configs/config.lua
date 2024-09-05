-- This is a file written to configure certain settings in your AWM.
-- Most of this comes down to things like borders, screen setup and such.
-- For custom colours, please refer to your theme's init.lua file
local config = {
  borders = dpi(0),
  battery = false,
  screen_setup = 'dual',
  gaps = dpi(5),
  desktopicons = true,
  -- taglist refers to the layout the screen takes on, layout in order
  taglist = {2, 1},
  applauncher_name = true,
  taskbar_name = false,
  taskbar_type = 'dock', -- Available options: unity, dock & floating
  tag_switcher = true -- allow the 'on tag change' animation to play! This is resource intensive.
}
return config
