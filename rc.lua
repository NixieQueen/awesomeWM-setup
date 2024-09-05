-- Start the AwesomeWM!!! :3
pcall(require, "luarocks.loader")

-- owO UwU
-- Standard lua stuff
gears = require("gears")
naughty = require("naughty")
beautiful = require("beautiful")
dpi = beautiful.xresources.apply_dpi
awful = require("awful")
gfs = require("gears.filesystem")
config_dir = gfs.get_configuration_dir()
wibox = require("wibox")
ruled = require("ruled")

-- Animations library by: https://github.com/andOrlando/rubato
rubato = require("lib.rubato")

layout_dir = config_dir .. "layout/"
widget_dir = config_dir .. "widgets/"
modules_dir = config_dir .. "modules/"
themes_dir = config_dir .. "themes/"

beautiful.init(themes_dir .. "theme.lua")
icons = beautiful.icons

config = require("configs.config")
appicon = require("widgets.appicon")
clickable_container = require("widgets.clickable-container")
gifcontainer = require("widgets.gif-container")
arcbar = require("widgets.arcbar")
custom_arcbars = require("widgets.custom-arcbars")
weather_widget = require("widgets.weather")
calendar = require("widgets.calendar")
systray = require("widgets.systray")
interactive_popup = require("widgets.interactive-popup")
performance_switcher_widget = require("widgets.performance-switch")
music_player_widget = require("widgets.music-player")

widget_button = require("widgets.widget-button")
widget_button_picom = require("widgets.widget-button-picom")
--local default_dpi = 96

awful.screen.set_auto_dpi_enabled(true)

--for s in screen do
--	beautiful.xresources.set_dpi(default_dpi*(s.geometry.width/2256 * 0.82),s)
--end

-- Keybinds
awful.keyboard.append_global_keybindings({dofile(config_dir .. "/keys/keys.lua")})

-- term
terminal = os.getenv("TERMINAL") or "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
fileMan = os.getenv("FILEMANAGER") or "thunar"
browser = os.getenv("BROWSER") or "librewolf"

-- Layout
require("layout.init")

-- Widgets
require("widgets.brightness-slider")
require("widgets.volume-slider")

-- Modules
require("modules.topbar")
require("modules.exitmenu")
require("modules.brightness-notif")
require("modules.volume-notif")
require("modules.lockmenu")
require("modules.alttab")

require("modules.themeswitcher")
require("modules.left-panel")
require("modules.taskbar")

--dofile(modules_dir .. "nagitoppanel.lua")
require("modules.toppanel")
require("modules.applauncher")
require("modules.screenshottool")
require("modules.dynamicbackground")
--require("modules.tag-switcher")

-- Rules & Notification stuff
require("rules")

-- Apps to start at runtime! Picom compositor here \/ :3c
-- awful.spawn.with_shell("picom")
-- awful.util.spawn("redshift",false)
require("utils.startup-apps")
require("utils.screenmanager")

require("modules.welcomescreen")
-- for now, just start by doing this:
--dofile(config_dir .. "start.lua")

-- collect some GARBAGE :3c
gears.timer.start_new(10, function()
    collectgarbage("step", 20000)
    --collectgarbage("collect")
    return true
end)
