-- Themes!!!
local filesystem = gears.filesystem
local theme_dir = filesystem.get_configuration_dir() .. '/themes'

-- wallpaper
local theme = {}
theme.wallpaper = theme_dir .. 'assets/ProtoBack.jpg'

return theme
