-- Main neko theme, overrides default theme stuff
local gears = require('gears')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local config_dir = gears.filesystem.get_configuration_dir()
local config = dofile(config_dir .. "/configs/config.lua")

local theme_dir = gears.filesystem.get_configuration_dir() .. 'themes/neko-theme/'

local theme = {}

local theme_overrides = function(theme)
	theme.wallpaper = {
		-- The amount of variables here might be intimidating but fear not! You only need a few based on your config, make sure they are uncommented
		-- This part is for time-based backgrounds
		default = theme_dir .. "Default.jpg", -- this is a fallback, do not edit!
		afternoon = theme_dir .. "Oriwall.jpg", -- 'afternoon' is considered the time default, uncomment only these lines in case of a non-time-based setup
		morning = theme_dir .. "po3ypo3x9gi81.png",
		evening = theme_dir .. "background.jpg",
		night = theme_dir .. "background.jpg",

		-- This part is for season-based backgrounds
		-- Anything without a prefix ('summer_') is considered summer
--		winter_afternoon
--		winter_morning
--		winter_evening
--		winter_night
--		autumn_afternoon
--		autumn_morning
--		autumn_evening
--		autumn_night
--		spring_afternoon
--		spring_morning
--		spring_evening
--		spring_night

		-- This part is for weather-based backgrounds
--		afternoon_rain
--		morning_rain
--		evening_rain
--		night_rain
--		afternoon_thunder
--		morning_thunder
--		evening_thunder
--		night_thunder
	}
	
	theme.profile_pic = theme_dir .. "profile.svg"
	theme.bg_normal = "#0f0f0f"
	theme.bg_focus = '#31484a'
	theme.fg_normal = "#e663e3"
	theme.fg_focus = "#53adb5"
	theme.background = "#00000090"
	theme.taskbar_background = "#000000" .. "50"
	theme.transparent = "#000000" .. "00"
	theme.tab_menu_background = "#24295c" .. ""
	theme.tab_menu_border_normal = "#242222" .. ""
	theme.lockbackground = theme.background

	theme.bg_systray = "#69696900"
	theme.systray_icon_spacing = dpi(1)

	theme.sysfont = "fira sans" .. " "
	
	theme.font = theme.sysfont .. "10"
	
	theme.barfont = theme.sysfont .. "bold 12"
	theme.arcbarfont = theme.sysfont .. "bold 15"

	theme.calendar_font_size = dpi(25)
	theme.calendar_font = theme.sysfont .. "bold " .. theme.calendar_font_size
	
	theme.osd_font = theme.sysfont .. "bold 12"

	theme.weather_font = theme.sysfont .. "bold 22"
	
	theme.bar_font_size = tostring(dpi(14))
	theme.search_bar_font = theme.sysfont .. theme.bar_font_size

	theme.taskbar_font_size = tostring(dpi(15))
	theme.taskbar_font = theme.sysfont .. "bold " .. theme.taskbar_font_size
	
	theme.alttab_font_size = tostring(dpi(20))
	theme.alttab_font = theme.sysfont .. "bold " .. theme.alttab_font_size
	theme.alttab_bg_focus = "#111111" .. ""
	theme.alttab_bg_normal = "#333333" .. ""
	theme.alttab_bg_minimize = "#555555" .. ""
	theme.alttab_fg_focus = "#53adb5"
	theme.alttab_fg_minimize = '#c553c3'
	theme.alltab_client_bg = "#000000"

	theme.system_red_dark = '#EE4F84'
	theme.system_green_dark = '#53E2AE'
	theme.system_yellow_dark = '#F1FF52'
	theme.system_blue_dark = '#6498EF'
	
	theme.useless_gap = config.gaps or dpi(7)
	theme.titlebar_bg_normal = '#22222260'
	theme.titlebar_size = dpi(33)
	theme.rounded_size = dpi(20)
	
	theme.border_width = config.borders or dpi(3)
	theme.border_color_normal = "#693163"
	theme.border_color_active = "#53adb5"
	
	theme.primary = theme.fg_normal
	theme.primary_off = '#a848a6'
	theme.secondary = '#53adb5'
	theme.secondary_off = '#326b70'
	theme.tertiary = '#495da6'
	theme.tertiary_off = '#2f3d6e'
	theme.quaternary = '#8048ab'
	theme.quaternary_off = '#552f73'
	theme.quinary = '#9543a3'
	theme.quinary_off = '#512559'
	
	theme.exit_greeter_font = theme.sysfont .. "bold 48"
	theme.exit_name_font = theme.sysfont .. "bold 45"
	theme.welcome_greet_font = theme.sysfont .. "bold 80"
	theme.left_panel_clock_font = theme.sysfont .. "bold 35"
	theme.left_panel_date_font = theme.sysfont .. "bold 30"
	theme.clock_font = theme.sysfont .. "bold 60"
	theme.toppanel_clock_font_size = tostring(dpi(20))
	theme.toppanel_clock_font = theme.sysfont .. "bold " .. theme.toppanel_clock_font_size
	theme.themeswitcher_font = theme.sysfont .. "bold 45"
	
	theme.exit_font_size = tostring(dpi(25))
	theme.exit_power_font = theme.sysfont .. "Bold " .. theme.exit_font_size
	theme.icon_path = theme_dir .. 'icons/'
	theme.app_path = theme_dir .. 'apps/'
	theme.theme_path = theme_dir
	
	theme.leave_event = '#000000' .. '00'
	theme.enter_event = '#ffffff' .. '10'
	theme.press_event = '#ffffff' .. '15'
	theme.release_event = '#ffffff' .. '10'

	theme.groups_bg = '#ffffff' .. '20'
	theme.groups_title_bg = '#ffffff' .. '25'
	theme.groups_radius = dpi(9)

	theme.titlebar_close_button_normal = theme.icon_path .. "close_normal.svg"
	theme.titlebar_close_button_focus = theme.icon_path .. "close_focus.svg"
	theme.titlebar_close_button_normal_hover = theme.icon_path .. "close_normal_hover.svg"
	theme.titlebar_close_button_focus_hover = theme.icon_path .. "close_focus_hover.svg"
	
	theme.titlebar_minimize_button_normal = theme.icon_path .. "minimize_normal.svg"
	theme.titlebar_minimize_button_focus = theme.icon_path .. "minimize_focus.svg"
	theme.titlebar_minimize_button_normal_hover = theme.icon_path .. "minimize_normal_hover.svg"
	theme.titlebar_minimize_button_focus_hover = theme.icon_path .. "minimize_focus_hover.svg"

	theme.titlebar_maximized_button_normal_inactive = theme.icon_path .. "maximized_normal_inactive.svg"
	theme.titlebar_maximized_button_focus_inactive = theme.icon_path .. "maximized_focus_inactive.svg"
	theme.titlebar_maximized_button_focus_inactive_hover = theme.icon_path .. "maximized_focus_inactive_hover.svg"
	theme.titlebar_maximized_button_normal_inactive_hover = theme.icon_path .. "maximized_normal_inactive_hover.svg"
	theme.titlebar_maximized_button_normal_active = theme.icon_path .. "maximized_normal_active.svg"
	theme.titlebar_maximized_button_focus_active = theme.icon_path .. "maximized_focus_active.svg"
	theme.titlebar_maximized_button_focus_active_hover = theme.icon_path .. "maximized_focus_active_hover.svg"
	theme.titlebar_maximized_button_normal_active_hover = theme.icon_path .. "maximized_normal_active_hover.svg"

	theme.icons = {}

	theme.icons.reboot = theme.icon_path .. "restart.svg"
	theme.icons.suspend = theme.icon_path .. "power-sleep.svg"
	theme.icons.logout = theme.icon_path .. "logout.svg"
	theme.icons.shutdown = theme.icon_path .. "power.svg"
	theme.icons.lock = theme.icon_path .. "lock.svg"
	
	theme.icons.cpu = theme.icon_path .. "memory.svg"
	theme.icons.memory = theme.icon_path .. "memory.svg"
	theme.icons.temperature = theme.icon_path .. "thermometer.svg"
	theme.icons.disk = theme.icon_path .. "harddisk.svg"
	theme.icons.battery = theme.icon_path .. "battery-discharge.svg"
	theme.icons.battery_charge = theme.icon_path .. "battery-charge.svg"

	theme.icons.sun = theme.icon_path .. "sun.svg"
	theme.icons.moon = theme.icon_path .. "moon.svg"

	theme.icons.terminal = theme.icon_path .. "terminal.svg"
	theme.icons.folder = theme.icon_path .. "folder.svg"

	theme.icons.brightness = theme.icon_path .. "brightness.svg"
	theme.icons.welcomegif = theme.icon_path .. "welcome.gif"

	theme.gif_ratio = 5/6
	theme.welcomegif_width = dpi(825*theme.gif_ratio)
	theme.welcomegif_height = dpi(900*theme.gif_ratio)

	-- Notification parameters
	theme.notification_font_size = dpi(12)
	theme.notification_font = theme.sysfont .. "bold " .. theme.notification_font_size
	theme.notification_bg = theme.background
	theme.notification_fg = theme.secondary
	theme.notification_border_width = 0
	theme.notification_border_color = theme.transparent
	theme.notification_shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, dpi(20))
	end
	theme.notification_opacity = 1
	theme.notification_margin = dpi(5)
	--theme.notification_width
	--theme.notification_height
	theme.notification_max_height = dpi(100)
	theme.notification_max_width = dpi(450)
	--theme.notification_icon_size

end

return {
	theme = theme,
	theme_overrides = theme_overrides
}
