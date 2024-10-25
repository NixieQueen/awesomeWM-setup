-- cool left panel module!

-- defining bars first
local arcbar_size = dpi(90)
local cpu_bar = custom_arcbars("cpu", arcbar_size, dpi(180), beautiful.primary, beautiful.primary_off)
local temp_bar = custom_arcbars("temperature", arcbar_size, dpi(180), beautiful.secondary, beautiful.secondary_off)
local bat_bar
if config.battery then
	bat_bar = custom_arcbars("battery", arcbar_size, dpi(180), beautiful.tertiary, beautiful.tertiary_off)
else
	bat_bar = custom_arcbars("gpu", arcbar_size, dpi(180), beautiful.tertiary, beautiful.tertiary_off)
end
local mem_bar = custom_arcbars("memory", arcbar_size, dpi(180), beautiful.quaternary, beautiful.quaternary_off)
local disk_bar = custom_arcbars("disk", arcbar_size, dpi(180), beautiful.quinary, beautiful.quinary_off)

local battery_icon_update = function()
	awful.spawn.easy_async_with_shell(
		[[sh -c "echo $(upower -d | grep -m 1 state | awk '{print $2}')"]], function(stdout)
		local state = stdout:match('[^\n]*')
		if state == 'discharging' then
			bat_bar:emit_signal("widget::bar:change_icon", icons.battery, beautiful.tertiary)
		end
		if state == 'charging' then
			bat_bar:emit_signal("widget::bar:change_icon", icons.battery_charge, beautiful.tertiary)
		end
	end)
end
local function create_profile_box()
	-- profile name & profile picture!
	local profile_name = wibox.widget {
		markup = '$USER',
		font = beautiful.sysboldfont .. dpi(35),
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local profile_picture = wibox.widget {
		{
			id = 'profile_image',
			image = beautiful.left_panel_profile_picture,
			resize = true,
			widget = wibox.widget.imagebox,
		},
		shape = gears.shape.circle,
		shape_border_width = beautiful.border_width * 3,
		shape_border_color = beautiful.border_color_active,
		--forced_width = dpi(90),
		--forced_height = dpi(90),
		widget = wibox.container.background,
	}

	local update_profile_pic = function()
		awful.spawn.easy_async_with_shell(
			[[sh -c "$HOME/.config/awesome/utils/update-profile"]],
			function(stdout)
				profile_picture.profile_image:set_image(stdout:match('[^\n]*'))
				profile_picture.profile_image:emit_signal('widget::redraw_needed')
			end
		)
	end

	local update_profile_name = function()
		awful.spawn.easy_async_with_shell(
			[[sh -c 'printf "$(whoami)"']],
			function(stdout)
				profile_name:set_markup(stdout:sub(1,1):upper()..stdout:sub(2))
				profile_name:emit_signal('widget::redraw_needed')
		end)
	end

	update_profile_pic()
	update_profile_name()
	local idle_messages = {
		":3c",
		"^w^",
		">.<",
		">:3",
		">.>",
		"QwQ"
	}
	local idle_message = wibox.widget {
		markup = 'OwO',
		font = beautiful.sysboldfont .. dpi(30),
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local update_idle_message = function()
		idle_message:set_markup(idle_messages[math.random(#idle_messages)])
		idle_message:emit_signal("widget::redraw_needed")
	end
	update_idle_message()

	local profile_name_sep = wibox.widget {
		layout = wibox.layout.ratio.vertical,
		spacing = dpi(10),
		profile_name,
		{
			layout = wibox.container.background,
			fg = beautiful.secondary,
			idle_message,
		}
	}
	profile_name_sep:adjust_ratio(1, 0.5, 0.5)

	local profile_pic_sep = wibox.widget {
		layout = wibox.layout.ratio.horizontal,
		{
			layout = wibox.container.margin,
			top = dpi(20),
			left = dpi(20),
			bottom = dpi(20),
			right = dpi(20),
			profile_picture,
		},
		{
			layout = wibox.layout.align.vertical,
			expand = 'none',
			nil,
			{
				layout = wibox.container.margin,
				top = dpi(20),
				right = dpi(20),
				bottom = dpi(20),
				profile_name_sep,
			},
			nil,
		},
	}
	profile_pic_sep:adjust_ratio(1, 0.3, 0.7)

	local profile_box = wibox.widget {
		layout = wibox.container.background,
		forced_width = dpi(700),
		forced_height = dpi(270),
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, dpi(20))
		end,
		{
			layout = wibox.layout.stack,
			{
				widget = wibox.widget.imagebox,
				image = beautiful.left_panel_profile_bg,
				horizontal_fit_policy = "fit",
				forced_width = dpi(700),
			},
			{
				widget = wibox.container.background,
				bg = beautiful.left_panel_widget_bg .. "30",
			},
			profile_pic_sep,
		},
	}

	return profile_box
end


-- function for buttons in main menu!
local build_function_button = function(name, icon, callback)
	local function_button_label= wibox.widget {
		text = name,
		font = beautiful.sysboldfont .. dpi(25),
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local function_button = wibox.widget {
		{
			{
				{
					{
						image = icon,
						widget = wibox.widget.imagebox
					},
					margins = dpi(16),
					widget = wibox.container.margin
				},
				bg = beautiful.groups_bg,
				widget = wibox.container.background
			},
			shape = gears.shape.rounded_rect,
			forced_width = dpi(80),
			forced_height = dpi(80),
			widget = clickable_container
		},
		left = dpi(2),
		right = dpi(2),
		widget = wibox.container.margin
	}

	local left_panel_item = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(5),
		function_button
	}

	left_panel_item:connect_signal(
		'button::release',
		function()
			callback()
		end
	)
	return left_panel_item
end

-- Music player widget!
local music_player = music_player_widget(dpi(700), dpi(200))
local weather_app = weather_widget(dpi(700), dpi(200), "Stockholm")

local picom_widget = widget_button_picom(beautiful.left_panel_widget_bg_normal, dpi(700), dpi(50), beautiful.left_panel_widget_text)

-- left panel setup
local create_left_panel = function(s)
	local height_offset = dpi(72)
	local x_offset = dpi(6)
	if config.taskbar_type == "dock" then
		height_offset = dpi(160)
	elseif config.taskbar_type == "unity" then
		x_offset = dpi(97)
	end

	local left_panel = wibox {
		screen = s,
		visible = false,
		ontop = true,
		type = 'normal',
		width = dpi(640),
		height = s.geometry.height-height_offset,
		x = s.geometry.x-dpi(640),
		y = s.geometry.y-dpi(20),
		--bg = beautiful.tab_menu_background .. '95',
		bg = beautiful.left_panel_bg,
		fg = beautiful.left_panel_text_colour
	}

	local profile_box = create_profile_box()

	local left_panel_bars = wibox.widget {
		layout = wibox.layout.flex.horizontal,
		spacing = dpi(30),
		cpu_bar,
		temp_bar,
		bat_bar,
		mem_bar,
		disk_bar,
	}

	local left_panel_options = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(10),
		{
			layout = wibox.layout.flex.horizontal,
			spacing = dpi(20),
			picom_widget,
			picom_widget,
		},
		{
			layout = wibox.layout.flex.horizontal,
			spacing = dpi(20),
			picom_widget,
			picom_widget,
		}
	}

	-- local left_panel_widgets = wibox.widget {
	-- 	layout = wibox.layout.fixed.vertical,
	-- 	spacing = dpi(50),
	-- 	profile_box,
	-- 	music_player,
	-- 	weather_app,
	-- 	{
	-- 		layout = wibox.layout.flex.horizontal,
	-- 		spacing = dpi(5),
	-- 		cpu_bar,
	-- 		temp_bar,
	-- 		bat_bar,
	-- 		mem_bar,
	-- 		disk_bar
	-- 	},
	-- 	picom_widget
	-- }
	left_panel.scrolled = 0
	--left_panel_widgets.point = {x=0,y=left_panel.scrolled}

	profile_box.start_point = {x=0, y=0}
	music_player.start_point = {x=0, y=310}
	weather_app.start_point = {x=0, y=550}
	left_panel_bars.start_point = {x=0, y=800}
	left_panel_options.start_point = {x=0, y=1000}

	profile_box.point = {x=0, y=0}
	music_player.point = {x=0, y=0}
	weather_app.point = {x=0, y=0}
	left_panel_bars.point = {x=0, y=0}
	left_panel_options.point = {x=0, y=0}


	local manual_layout = wibox.widget {
		layout = wibox.layout.manual,
		profile_box,
		music_player,
		weather_app,
		left_panel_bars,
		left_panel_options,
		-- left_panel_widgets
	}

	local max_scroll_length = manual_layout.children[#manual_layout.children].start_point.y

	left_panel.scroll = rubato.timed {
		intro = 0.15,
		duration = 0.3,
		easing = rubato.quadratic,
		subscribed = function(pos)
			left_panel.scrolled = pos
			for i in pairs(manual_layout.children) do
				local widget = manual_layout.children[i]
				manual_layout:move(i, {x=0, y=widget.start_point.y + pos})
			end
		end
	}

	left_panel : setup {
		margins = dpi(50),
		layout = wibox.container.margin,
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			nil,
			manual_layout,
			nil,
		},
	}
	left_panel.animation = rubato.timed {
		intro = 0.5,
		duration = 1.0,
		easing = rubato.quadratic,
		subscribed = function(pos)
			left_panel.x = s.geometry.x + pos * left_panel.width - left_panel.width + pos * x_offset
		end
	}

	--awful.placement.left(
	--	s.left_panel,
	--	{
	--		margins = {
	--			left = 0,
	--			right = 0,
	--			top = 0,
	--			bottom = 0,
	--		},
	--		honor_workarea = true
	--	}
	--)

	local cpu_timer = gears.timer {timeout = .1, autostart = false, single_shot=true, callback = function() cpu_bar:emit_signal("widget::bar:refresh") end}
	local temp_timer = gears.timer {timeout = 1, autostart = false, single_shot=true, callback = function() temp_bar:emit_signal("widget::bar:refresh") end}
	local mem_timer = gears.timer {timeout = 2, autostart = false, single_shot=true, callback = function() mem_bar:emit_signal("widget::bar:refresh") end}
	local bat_timer = gears.timer {timeout = 3, autostart = false, single_shot=true, callback = function() bat_bar:emit_signal("widget::bar:refresh") if config.battery then battery_icon_update() end end}
	local disk_timer = gears.timer {timeout = 4, autostart = false, single_shot=true, callback = function() disk_bar:emit_signal("widget::bar:refresh") end}

	left_panel.restart_leftpanel_timers = function()
		cpu_timer:again()
		temp_timer:again()
		mem_timer:again()
		bat_timer:again()
		disk_timer:again()
	end

	left_panel.left_panel_bartimer = gears.timer {
		autostart = false,
		call_now = true,
		timeout = 5,
		callback = left_panel.restart_leftpanel_timers
	}

	left_panel:buttons(
		gears.table.join(
			awful.button(
				{}, 3, function()
					awesome.emit_signal("module::left_panel:hide")
			end),
			awful.button(
				{}, 4, function()
					new_scroll_pos = left_panel.scrolled + 200
					if new_scroll_pos > 0 then
						new_scroll_pos = 0
					end
					left_panel.scroll.target = new_scroll_pos
			end),
			awful.button(
				{}, 5, function()
					new_scroll_pos = left_panel.scrolled - 200
					if new_scroll_pos < -max_scroll_length then
						new_scroll_pos = -max_scroll_length
					end
					left_panel.scroll.target = new_scroll_pos
			end)
		)
	)

	left_panel.left_panel_grabber = awful.keygrabber {
		auto_start = false,
		stop_event = 'release',
		mask_event_callback = true,
		keybindings = {
			awful.key {
				modifiers = {},
				key = 'Escape',
				on_press = function(self)
					self:stop()
					awesome.emit_signal("module::left_panel:hide")
				end
			},
		},
	}

	left_panel:connect_signal("mouse::leave", function()
		awesome.emit_signal("module::left_panel:hide") end
	)

	return left_panel

end

screen.connect_signal("request::desktop_decoration", function(s)
	s.left_panel = create_left_panel(s)
end)

awesome.connect_signal("module::left_panel:show", function()
	for s in screen do
		s.left_panel.visible = false
		s.left_panel.left_panel_bartimer:stop()
		s.left_panel.left_panel_grabber:stop()
	end
	local focused = awful.screen.focused()
	focused.left_panel.scrolled = 0
	focused.left_panel.scroll.target = 0
	focused.left_panel.visible = true
	focused.left_panel.left_panel_bartimer:again()
	focused.left_panel.left_panel_grabber:start()
	focused.left_panel.restart_leftpanel_timers()
	music_player:emit_signal("widget::music_player:start_clock")
	weather_app:emit_signal("widget::weather_app:start_clock")
	focused.left_panel.y = focused.geometry.y + dpi(65)
	focused.left_panel.animation.target = 1
end)

awesome.connect_signal("module::left_panel:hide", function()
	for s in screen do
		s.left_panel.animation.target = 0
		s.left_panel.left_panel_bartimer:stop()
		s.left_panel.left_panel_grabber:stop()
	end
	music_player:emit_signal("widget::music_player:stop_clock")
	weather_app:emit_signal("widget::weather_app:stop_clock")
	gears.timer.start_new(1.5, function() for s in screen do if s.left_panel.animation.target <= 0.1 then s.left_panel.visible = false end end end)
end)
