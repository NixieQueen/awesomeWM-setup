-- cool left panel module!

-- defining bars first
local cpu_bar = arcbars(
	gears.color.recolor_image(icons.cpu, beautiful.primary),
	'Cpu',
	[[sh -c "echo $(top -b -n 1 | grep Cpu | awk '{print 100-$8-$16}')"]],
	[[sh -c "echo $(grep 'cpu MHz' /proc/cpuinfo | awk '{ghzsum+=$NF+0} END {printf "%.1f Ghz", ghzsum/NR/1000}')"]],
	dpi(50),
	dpi(200),
	beautiful.primary,
	beautiful.primary_off
)

local temp_bar = arcbars(
	gears.color.recolor_image(icons.temperature, beautiful.secondary),
	'Temps',
	--[[sh -c "echo $(sensors | grep -m 1 Package\ id\ 0 | awk '{printf "%.0f", $4}')"]]
	--[[sh -c "echo $(sensors | grep -m 1 Package\ id\ 0 | awk '{printf "%.0fC", $4}')"]]
	[[sh -c "echo $(paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$//' | grep "x86_pkg_temp" | awk '{print $2}')"]],
	[[sh -c "echo $(paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/' | grep "x86_pkg_temp" | awk '{print $2}')"]],
	dpi(50),
	dpi(200),
	beautiful.secondary,
	beautiful.secondary_off
)

local bat_bar_func = function()
	if config.battery then
		return arcbars(
			gears.color.recolor_image(icons.battery, beautiful.tertiary),
			'Battery',
			[[sh -c "echo $(upower -d | grep -m 1 percentage: | awk '{print substr($2, 1, length($2)-1)}')"]],
			[[sh -c "echo $(upower -d | grep -m 1 time\ to | awk '{print $4" "$5}')"]],
			dpi(50),
			dpi(200),
			beautiful.tertiary,
			beautiful.tertiary_off
		)
	else
		return arcbars(
			gears.color.recolor_image(icons.memory, beautiful.tertiary),
			'GPU',
			[[sh -c "echo $(nvidia-smi | grep % | awk '{print $13-1}')"]],
			[[sh -c "echo $(nvidia-smi | grep % | awk '{printf "%.1fW / %.1fW", $5, $7}')"]],
			dpi(50),
			dpi(200),
			beautiful.tertiary,
			beautiful.tertiary_off
		)
	end
end
local bat_bar = bat_bar_func()

local mem_bar = arcbars(
	gears.color.recolor_image(icons.memory, beautiful.quaternary),
	'Memory',
	[[sh -c "echo $(free | grep Mem | awk '{print $3 / $2 * 100}')"]],
	[[sh -c "echo $(free | grep Mem | awk '{printf "%.1f GB / %.1f GB", ($2-$7)/1000000-0.4, $2/1000000-0.4}')"]],
	dpi(50),
	dpi(200),
	beautiful.quaternary,
	beautiful.quaternary_off
)

local disk_bar = arcbars(
	gears.color.recolor_image(icons.disk, beautiful.quinary),
	'Disk',
	[[sh -c "echo $(df -h / | grep / | awk '{printf "%.1f", $3/$2*100}')"]],
	[[sh -c "echo $(df -h / | grep / | awk '{printf "%.1fG free", $4}')"]],
	dpi(50),
	dpi(200),
	beautiful.quinary,
	beautiful.quinary_off
)

local battery_icon_update = function()
	awful.spawn.easy_async_with_shell(
		[[sh -c "echo $(upower -d | grep -m 1 state | awk '{print $2}')"]], function(stdout)
		local state = stdout:match('[^\n]*')
		if state == 'discharging' then
			bat_bar:emit_signal("widget::bar:discharge_icon")
		end
		if state == 'charging' then
			bat_bar:emit_signal("widget::bar:charge_icon")
		end
	end)
end

local function create_profile_box()
	-- profile name & profile picture!
	local profile_name = wibox.widget {
		markup = '$USER',
		font = beautiful.sysboldfont .. dpi(45),
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local profile_picture = wibox.widget {
		{
			id = 'profile_image',
			image = beautiful.profile_pic,
			resize = true,
			widget = wibox.widget.imagebox,
		},
		shape = gears.shape.circle,
		shape_border_width = beautiful.border_width * 3,
		shape_border_color = beautiful.border_color_active,
		width = dpi(60),
		height = dpi(60),
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
		font = beautiful.sysboldfont .. dpi(35),
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local update_idle_message = function()
		idle_message:set_markup(idle_messages[math.random(#idle_messages)])
		idle_message:emit_signal("widget::redraw_needed")
	end
	update_idle_message()

	local profile_box = wibox.widget {
		layout = wibox.layout.ratio.horizontal,
		spacing = dpi(5),
		{
			layout = wibox.container.margin,
			margins = dpi(5),
			profile_picture,
		},
		{
			layout = wibox.layout.align.vertical,
			expand = 'none',
			nil,
			{
				layout = wibox.layout.ratio.vertical,
				spacing = dpi(10),
				profile_name,
				{
					layout = wibox.layout.align.horizontal,
					expand = 'none',
					nil,
					{
						widget = wibox.container.background,
						fg = beautiful.secondary,
						idle_message,
					},
					nil,
				},
			},
			nil,
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
		bg = beautiful.background,
		fg = beautiful.primary
	}

	local profile_box = create_profile_box()

	local left_panel_widgets = wibox.widget {
		layout = wibox.layout.align.vertical,
		profile_box,
	}
	left_panel.scrolled = 0
	left_panel_widgets.point = {x=0,y=left_panel.scrolled}

	local manual_layout = wibox.widget {
		layout = wibox.layout.manual,
		left_panel_widgets
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
					left_panel.scrolled = left_panel.scrolled - 30
					if left_panel.scrolled < -200 then
						left_panel.scrolled = -200
					end
					manual_layout:move(1, {x=0, y=left_panel.scrolled})
			end),
			awful.button(
				{}, 5, function()
					left_panel.scrolled = left_panel.scrolled + 30
					if left_panel.scrolled > 0 then
						left_panel.scrolled = 0
					end
					manual_layout:move(1, {x=0, y=left_panel.scrolled})
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

	left_panel:connect_signal("move::index", function()
		manual_layout:move(1, {x=0, y=left_panel.scrolled})
	end)

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
	focused.left_panel:emit_signal("move::index")
	focused.left_panel.visible = true
	focused.left_panel.left_panel_bartimer:again()
	focused.left_panel.restart_leftpanel_timers()
	focused.left_panel.y = focused.geometry.y + dpi(65)
	focused.left_panel.animation.target = 1
end)

awesome.connect_signal("module::left_panel:hide", function()
	for s in screen do
		s.left_panel.animation.target = 0
		s.left_panel.left_panel_bartimer:stop()
		s.left_panel.left_panel_grabber:stop()
	end
	gears.timer.start_new(1.5, function() for s in screen do if s.left_panel.animation.target <= 0.1 then s.left_panel.visible = false end end end)
end)

