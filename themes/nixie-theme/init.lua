-- Main neko theme, overrides default theme stuff
local gears = require('gears')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local config_dir = gears.filesystem.get_configuration_dir()
local config = dofile(config_dir .. "/configs/config.lua")

local theme_dir = gears.filesystem.get_configuration_dir() .. 'themes/neko-theme/'
local background_dir = theme_dir .. "backgrounds/"

local theme = {}

local theme_overrides = function(theme)
	theme.wallpaper = {
		-- The amount of variables here might be intimidating but fear not! You only need a few based on your config, make sure they are uncommented
		-- This part is for time-based backgrounds
		default = background_dir .. "CarNixieAfternoon.jpg", -- this is a fallback, do not edit!
		afternoon = background_dir .. "CarNixieAfternoon.png", -- 'afternoon' is considered the time default, uncomment only these lines in case of a non-time-based setup
		morning = background_dir .. "CarNixieMorning.png",
		evening = background_dir .. "CarNixieEvening.png",
		night = background_dir .. "CarNixieNight.png",

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

	theme.config = config

	-- All the basic colours!
	theme.primary = "#f4b8e4"
	theme.primary_off = '#b78bab'
	theme.secondary = '#ca9ee6'
	theme.secondary_off = '#9b79af'
	theme.tertiary = '#81c8be'
	theme.tertiary_off = '#639991'
	theme.quaternary = '#babbf1'
	theme.quaternary_off = '#8f90ba'
	theme.quinary = '#a6d189'
	theme.quinary_off = '#7b9b66'

	-- Some standards
	theme.item_bg_focus = "#303446"
	theme.item_bg_normal = "#51576d"
	theme.item_bg_minimize = "#626880"
	theme.item_fg_focus = theme.secondary
	theme.item_fg_minimize = theme.secondary_off
	theme.item_client_bg = "#232634"
	theme.profile_pic = theme_dir .. "profile.svg"

	-- Global font
	theme.sysfont = "fira sans" .. " "
	theme.sysboldfont = theme.sysfont .. "bold "
	theme.font = theme.sysfont .. "10"

	-- General awesomeWM items
	theme.bg_normal = theme.item_bg_normal
	theme.bg_focus = theme.item_bg_focus
	theme.fg_normal = theme.primary
	theme.fg_focus = theme.item_fg_focus
	theme.bg = "#303446"
	theme.background = theme.bg-- .. "90"
	theme.transparent = "#232634" .. "00"

	-- This part is for the taskbar!
	theme.taskbar_bg = theme.background-- .. "50"
	theme.taskbar_bg_minimize = theme.item_bg_minimize
	theme.taskbar_bg_focus = theme.item_bg_focus
	theme.taskbar_bg_normal = theme.item_bg_normal
	theme.taskbar_client_bg = theme.item_client_bg
	theme.taskbar_fg = theme.primary
	theme.taskbar_fg_off = theme.primary_off
	theme.taskbar_text_colour = theme.secondary

	-- Theme for left-panel
	theme.left_panel_bg = theme.background-- .. "50"
	theme.left_panel_text_colour = theme.primary
	theme.left_panel_text_colour_secondary = theme.secondary
	theme.left_panel_profile_picture = theme.profile_pic
	theme.left_panel_widget_bg = theme.item_bg_normal
	theme.left_panel_widget_fg = theme.secondary
	theme.left_panel_widget_bg_focus = theme.primary_off
	theme.left_panel_widget_bg_normal = theme.primary
	theme.left_panel_widget_text_size = dpi(15)
	theme.left_panel_widget_text = theme.sysboldfont .. theme.left_panel_widget_text_size
	theme.left_panel_profile_bg = background_dir .. "MountainDragon.png"

	-- Theme for arcbars in left-panel
	theme.arc_bar_bg = theme.item_bg_normal

	-- Theme for music player
	theme.music_player_bg = theme.item_bg_normal
	theme.music_player_fg = theme.primary
	theme.music_player_fg_off = theme.primary_off
	theme.music_player_button_bg = theme.item_bg_normal
	theme.music_player_title_font_size = dpi(20)
	theme.music_player_title_font = theme.sysboldfont .. theme.music_player_title_font_size
	theme.music_player_artist_font_size = dpi(15)
	theme.music_player_artist_font = theme.sysboldfont .. theme.music_player_artist_font_size
	theme.music_player_album_font_size = dpi(10)
	theme.music_player_album_font = theme.sysboldfont .. theme.music_player_album_font_size

	-- Theme for weather app
	theme.weather_app_bg = theme.item_bg_normal
	theme.weather_app_fg_primary = theme.primary
	theme.weather_app_fg_secondary = theme.secondary
	theme.weather_app_fg_tertiary = theme.tertiary
	theme.weather_app_fg_quaternary = theme.quaternary
	theme.weather_app_fg_quinary = theme.quinary

	-- This part is for the applauncher
	theme.applauncher_bg = theme.background .. "40"
	theme.applauncher_text_colour = theme.secondary
	theme.applauncher_search_colour = theme.primary
	theme.applauncher_search_colour_off = theme.primary_off
	theme.applauncher_bg_normal = theme.item_bg_normal --.. "DD"
	theme.applauncher_index_bg = theme.item_bg_normal .. "EE"
	theme.applauncher_selected_field = theme.primary

	-- Toppanel!
	theme.toppanel_bg = theme.background-- .. "50"
	theme.toppanel_app_fg = theme.primary
	theme.toppanel_app_fg_off = theme.primary_off
	theme.keyboardlayoutwidget_font_size = dpi(15)
	theme.keyboardlayoutwidget_font = theme.sysboldfont .. theme.keyboardlayoutwidget_font_size

	-- Performance widget
	theme.performancewidget_font_size = dpi(15)
	theme.performancewidget_font = theme.sysboldfont .. theme.performancewidget_font_size
	theme.performancewidget_font_colour = theme.primary
	theme.performancewidget_font_colour_off = theme.primary_off
	theme.performancewidget_bg_normal = theme.item_bg_normal
	theme.performancewidget_selector_bg = theme.performancewidget_font_colour
	theme.performancewidget_bg = theme.background

	-- Quitmenu
	theme.quitmenu_bg = theme.background .. "40"
	theme.quitmenu_fg = theme.primary

	-- Screenshotting tool
	theme.screenshot_folder = string.gsub(gfs.get_xdg_config_home(),".config/","") .. "/Pictures/Screenshots/"
	theme.screenshot_prefix = "Screenshot from "
	theme.screenshot_date_format = "%Y-%m-%d %H-%M-%S"
	theme.screenshot_frame_color = theme.primary
	theme.screenshot_frame_shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, dpi(15)) end

	theme.tab_menu_background = "#24295c" .. ""
	theme.tab_menu_border_normal = "#242222" .. ""
	theme.lockbackground = theme.background

	theme.bg_calendar = theme.item_bg_focus .. "80"
	theme.calendar_font_size = dpi(25)
	theme.calendar_font = theme.sysboldfont .. theme.calendar_font_size

	theme.bg_systray = "#09090900"
	theme.systray_icon_spacing = dpi(1)
	theme.systray_max_rows = 2
--	theme.systray_skip_bg = true

	theme.alttab_bg = theme.background
	theme.alttab_bg_focus = theme.item_bg_focus
	theme.alttab_bg_normal = theme.item_bg_normal
	theme.alttab_bg_minimize = theme.item_bg_minimize
	theme.alttab_fg_focus = theme.item_fg_focus
	theme.alttab_fg_minimize = theme.item_fg_minimize
	theme.alltab_client_bg = theme.item_client_bg

	theme.system_red_dark = '#EE4F84'
	theme.system_green_dark = '#53E2AE'
	theme.system_yellow_dark = '#F1FF52'
	theme.system_blue_dark = '#6498EF'
	
	theme.useless_gap = theme.config.gaps or dpi(7)
	theme.titlebar_bg_normal = '#22222260'
	theme.titlebar_size = dpi(33)
	theme.rounded_size = dpi(20)
	
	theme.border_width = theme.config.borders or dpi(3)
	theme.border_color_normal = "#693163"
	theme.border_color_active = "#53adb5"

	theme.icon_path = theme_dir .. 'icons/'
	theme.app_path = theme_dir .. 'apps/'
	theme.tag_path = theme_dir .. 'tags/'
	theme.theme_path = theme_dir
	
--	theme.leave_event = '#000000' .. '00'
--	theme.enter_event = '#ffffff' .. '10'
--	theme.press_event = '#ffffff' .. '15'
--	theme.release_event = '#ffffff' .. '10'

	theme.leave_event = theme.transparent
	theme.enter_event = theme.tertiary .. "70"
	theme.press_event = theme.tertiary
	theme.release_event = theme.tertiary .. "70"

	theme.groups_bg = '#ffffff' .. '20'
	theme.groups_title_bg = '#ffffff' .. '25'
	theme.groups_radius = dpi(9)

--	theme.titlebar_close_button_normal = theme.icon_path .. "close_normal.svg"
--	theme.titlebar_close_button_focus = theme.icon_path .. "close_focus.svg"
--	theme.titlebar_close_button_normal_hover = theme.icon_path .. "close_normal_hover.svg"
--	theme.titlebar_close_button_focus_hover = theme.icon_path .. "close_focus_hover.svg"
--
--	theme.titlebar_minimize_button_normal = theme.icon_path .. "minimize_normal.svg"
--	theme.titlebar_minimize_button_focus = theme.icon_path .. "minimize_focus.svg"
--	theme.titlebar_minimize_button_normal_hover = theme.icon_path .. "minimize_normal_hover.svg"
--	theme.titlebar_minimize_button_focus_hover = theme.icon_path .. "minimize_focus_hover.svg"
--
--	theme.titlebar_maximized_button_normal_inactive = theme.icon_path .. "maximized_normal_inactive.svg"
--	theme.titlebar_maximized_button_focus_inactive = theme.icon_path .. "maximized_focus_inactive.svg"
--	theme.titlebar_maximized_button_focus_inactive_hover = theme.icon_path .. "maximized_focus_inactive_hover.svg"
--	theme.titlebar_maximized_button_normal_inactive_hover = theme.icon_path .. "maximized_normal_inactive_hover.svg"
--	theme.titlebar_maximized_button_normal_active = theme.icon_path .. "maximized_normal_active.svg"
--	theme.titlebar_maximized_button_focus_active = theme.icon_path .. "maximized_focus_active.svg"
--	theme.titlebar_maximized_button_focus_active_hover = theme.icon_path .. "maximized_focus_active_hover.svg"
--	theme.titlebar_maximized_button_normal_active_hover = theme.icon_path .. "maximized_normal_active_hover.svg"

	theme.titlebar_close_button_normal = gears.color.recolor_image(theme.icon_path .. "close_normal.svg", theme.primary_off)
	theme.titlebar_close_button_focus = theme.titlebar_close_button_normal
	theme.titlebar_close_button_normal_hover = gears.color.recolor_image(theme.icon_path .. "close_normal_hover.svg", theme.primary)
	theme.titlebar_close_button_focus_hover = theme.titlebar_close_button_normal_hover

	theme.titlebar_minimize_button_normal = gears.color.recolor_image(theme.icon_path .. "minimize_normal.svg", theme.secondary_off)
	theme.titlebar_minimize_button_focus = theme.titlebar_minimize_button_normal
	theme.titlebar_minimize_button_normal_hover = gears.color.recolor_image(theme.icon_path .. "minimize_normal_hover.svg", theme.secondary)
	theme.titlebar_minimize_button_focus_hover = theme.titlebar_minimize_button_normal_hover

	theme.titlebar_maximized_button_normal_inactive = gears.color.recolor_image(theme.icon_path .. "maximized_normal_inactive.svg", theme.tertiary_off)
	theme.titlebar_maximized_button_focus_inactive = theme.titlebar_maximized_button_normal_inactive
	theme.titlebar_maximized_button_normal_inactive_hover = gears.color.recolor_image(theme.icon_path .. "maximized_normal_inactive_hover.svg", theme.tertiary)
	theme.titlebar_maximized_button_focus_inactive_hover = theme.titlebar_maximized_button_normal_inactive_hover
	theme.titlebar_maximized_button_normal_active = gears.color.recolor_image(theme.icon_path .. "maximized_normal_active.svg", theme.quaternary_off)
	theme.titlebar_maximized_button_focus_active = theme.titlebar_maximized_button_normal_active
	theme.titlebar_maximized_button_normal_active_hover = gears.color.recolor_image(theme.icon_path .. "maximized_normal_active_hover.svg", theme.quaternary)
	theme.titlebar_maximized_button_focus_active_hover = theme.titlebar_maximized_button_normal_active_hover

	-- icons!
	theme.icons = {}

	theme.icons.reboot = theme.icon_path .. "restart.svg"
	theme.icons.suspend = theme.icon_path .. "power-sleep.svg"
	theme.icons.logout = theme.icon_path .. "logout.svg"
	theme.icons.shutdown = theme.icon_path .. "power.svg"
	theme.icons.lock = theme.icon_path .. "lock.svg"
	theme.icons.checkbox = theme.icon_path .. "checkbox.svg"
	
	theme.icons.cpu = theme.icon_path .. "memory.svg"
	theme.icons.memory = theme.icon_path .. "memory.svg"
	theme.icons.temperature = theme.icon_path .. "thermometer.svg"
	theme.icons.disk = theme.icon_path .. "harddisk.svg"
	theme.icons.battery = theme.icon_path .. "battery-discharge.svg"
	theme.icons.battery_charge = theme.icon_path .. "battery-charge.svg"

	-- weather icons
	theme.icons.sun = theme.icon_path .. "sun.svg"
	theme.icons.moon = theme.icon_path .. "moon.svg"
	theme.icons.cloudy = theme.icon_path .. "cloudy.svg"
	theme.icons.fog = theme.icon_path .. "fog.svg"
	theme.icons.rain = theme.icon_path .. "rain.svg"
	theme.icons.thunderstorm = theme.icon_path .. "thunderstorm.svg"
	theme.icons.snow = theme.icon_path .. "snow.svg"

	theme.icons.terminal = theme.icon_path .. "terminal.svg"
	theme.icons.folder = theme.icon_path .. "folder.svg"

	-- left panel icons
	theme.icons.option_arrow = theme.icons.logout
	theme.icons.picom = theme.icons.cpu

	-- music player icons
	theme.icons.play_button = theme.icons.logout
	theme.icons.pause_button = theme.icons.memory
	theme.icons.previous_button = theme.icons.logout
	theme.icons.next_button = theme.icons.logout

	theme.icons.brightness = theme.icon_path .. "brightness.svg"

	-- welcome gif
	theme.welcomegif_bg = theme.transparent
	theme.icons.welcomegif = theme.icon_path .. "welcome.gif"
	theme.gif_ratio = 5/6
	theme.welcomegif_width = dpi(825*theme.gif_ratio)
	theme.welcomegif_height = dpi(900*theme.gif_ratio)

	-- tags
	theme.layout_cornernw = gears.color.recolor_image(theme.tag_path .. "cornernww.png", theme.primary)
	theme.layout_cornerne = gears.color.recolor_image(theme.tag_path .. "cornernew.png", theme.primary)
	theme.layout_cornersw = gears.color.recolor_image(theme.tag_path .. "cornersww.png", theme.primary)
	theme.layout_cornerse = gears.color.recolor_image(theme.tag_path .. "cornersew.png", theme.primary)
	theme.layout_fairh = gears.color.recolor_image(theme.tag_path .. "fairhw.png", theme.primary)
	theme.layout_fairv = gears.color.recolor_image(theme.tag_path .. "fairvw.png", theme.primary)
	theme.layout_floating = gears.color.recolor_image(theme.tag_path .. "floatingw.png", theme.primary)
	theme.layout_magnifier = gears.color.recolor_image(theme.tag_path .. "magnifierw.png", theme.primary)
	theme.layout_max = gears.color.recolor_image(theme.tag_path .. "maxw.png", theme.primary)
	theme.layout_fullscreen = gears.color.recolor_image(theme.tag_path .. "fullscreenw.png", theme.primary)
	theme.layout_spiral = gears.color.recolor_image(theme.tag_path .. "spiralw.png", theme.primary)
	theme.layout_dwindle = gears.color.recolor_image(theme.tag_path .. "dwindlew.png", theme.primary)
	theme.layout_tile = gears.color.recolor_image(theme.tag_path .. "tilew.png", theme.primary)
	theme.layout_tiletop = gears.color.recolor_image(theme.tag_path .. "tiletopw.png", theme.primary)
	theme.layout_tilebottom = gears.color.recolor_image(theme.tag_path .. "tilebottomw.png", theme.primary)
	theme.layout_tileleft = gears.color.recolor_image(theme.tag_path .. "tileleftw.png", theme.primary)

	-- taglist
	theme.taglist_fg_focus = theme.secondary
	theme.taglist_bg_focus = theme.tertiary
	theme.taglist_fg_urgent = theme.quinary
	theme.taglist_bg_urgent = theme.quaternary_off
	theme.taglist_fg_empty = theme.primary
	theme.taglist_bg_empty = theme.transparent
	theme.taglist_fg_occupied = theme.primary
	theme.taglist_bg_occupied = theme.transparent
	theme.taglist_font = theme.sysboldfont .. "11"

	-- Notification parameters
	theme.notification_font_size = dpi(12)
	theme.notification_font = theme.sysboldfont .. theme.notification_font_size
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
