-- File for handling default theme & merging with custom theme :3
local gtable = require('gears.table')
local gears = require("gears")
local filesystem = require('gears.filesystem')
local theme_dir = filesystem.get_configuration_dir() .. "/themes"

local default = dofile(theme_dir .. "/default-theme/init.lua")
-- Either use neko-theme or nixie-theme here
-- local userTheme = dofile(theme_dir .. "/nixie-theme/init.lua")

local theme_command = "cat ~/.config/awesome/themes/themeconfigs.txt | grep default: | awk '{print $2}'"
local selected_theme = io.popen(theme_command):read("*all"):gsub("\n[^\n]*$", "")
-- stdout:gsub("\n[^\n]*$", "")

--selected_theme.theme = 'neko-theme'
local userTheme = dofile(theme_dir .. "/" .. selected_theme .. "/init.lua")

local nekoEndTheme = {}
gtable.crush(nekoEndTheme, default.theme)
gtable.crush(nekoEndTheme, userTheme.theme)
default.theme_overrides(nekoEndTheme)
userTheme.theme_overrides(nekoEndTheme)

return nekoEndTheme
