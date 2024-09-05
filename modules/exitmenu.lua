-- Exit menu, this should pop up when you try to exit

local msg_table = {
	'Goodbye!!',
	'Goodbye!! OwO',
	'Bye!~ uwu',
	'Bye!'
}

local greeter_message = wibox.widget {
	markup = 'Bye!',
	font = beautiful.sysboldfont .. dpi(48),
	align = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local profile_name = wibox.widget {
	markup = '$USER',
	font = beautiful.sysboldfont .. dpi(45),
	align = 'center',
	widget = wibox.widget.textbox
}

local profile_picture = wibox.widget {
	{
		id = 'profile_image',
		image = beautiful.profile_pic,
		resize = true,
		forced_height = dpi(250),
		widget = wibox.widget.imagebox,
	},
	shape = gears.shape.circle,
	shape_border_width = beautiful.border_width * 3,
	shape_border_color = beautiful.border_color_active,
	forced_height = dpi(250),
	forced_width = dpi(250),
	widget = wibox.container.background
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

local update_greeter_message = function()
	greeter_message:set_markup(msg_table[math.random(#msg_table)])
	greeter_message:emit_signal('widget::redraw_needed')
end

update_profile_pic()
update_profile_name()
update_greeter_message()

local build_power_button = function(name, icon, callback)
	local power_button_label= wibox.widget {
		text = name,
		font = beautiful.sysboldfont .. dpi(25),
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local power_button = wibox.widget {
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
			forced_width = dpi(160),
			forced_height = dpi(160),
			widget = clickable_container
		},
		left = dpi(24),
		right = dpi(24),
		widget = wibox.container.margin
	}

	local exit_screen_item = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(5),
		power_button,
		power_button_label
	}

	exit_screen_item:connect_signal(
		'button::release',
		function()
			callback()
		end
	)
	return exit_screen_item
end

local suspend_command = function()
	awesome.emit_signal("module::exit_screen:hide")
	awesome.emit_signal("module::lockscreen:show")
	awful.spawn.with_shell('systemctl suspend')
end

local logout_command = function()
	awesome.quit()
end

local lock_command = function()
	awesome.emit_signal("module::exit_screen:hide")
	awesome.emit_signal("module::lockscreen:show")
end

local poweroff_command = function()
	awful.spawn.with_shell("poweroff")
	awesome.emit_signal("module::exit_screen:hide")
end

local reboot_command = function()
	awful.spawn.with_shell("reboot")
	awesome.emit_signal("module::exit_screen:hide")
end

local poweroff = build_power_button("Shutdown", icons.shutdown, poweroff_command)
local reboot = build_power_button("Restart", icons.reboot, reboot_command)
local suspend = build_power_button("Sleep", icons.suspend, suspend_command)
local lock = build_power_button("Lock", icons.lock, lock_command)
local logout = build_power_button("Logout", icons.logout, logout_command)

local create_exit_screen = function(s)
	s.exit_screen = wibox {
		screen = s,
		type = 'splash',
		visible = false,
		ontop = true,
		bg = beautiful.quitmenu_bg,
		fg = beautiful.quitmenu_fg,
		height = s.geometry.height,
		width = s.geometry.width,
		x = s.geometry.x,
		y = s.geometry.y
	}
	s.exit_screen:buttons(
		gears.table.join(
			awful.button(
				{}, 2, function()
					awesome.emit_signal("module::exit_screen:hide")
				end),
			awful.button(
				{}, 3, function()
					awesome.emit_signal("module::exit_screen:hide")
				end)
		)
	)
	s.exit_screen : setup {
		layout = wibox.layout.align.vertical,
		expand = 'none',
		nil,
		{
			layout = wibox.layout.fixed.vertical,
			{
				nil,
				{
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(20),
					{
						layout = wibox.layout.align.vertical,
						expand = 'none',
						nil,
						{
							layout = wibox.layout.align.horizontal,
							expand = 'none',
							nil,
							profile_picture,
							nil
						},
						nil
					},
					profile_name
				},
				nil,
				expand = 'none',
				layout = wibox.layout.align.horizontal
			},
			{
				layout = wibox.layout.align.horizontal,
				expand = 'none',
				nil,
				{
					widget = wibox.container.margin,
					margins = dpi(20),
					greeter_message
				},
				nil
			},
			{
				layout = wibox.layout.align.horizontal,
				expand = 'none',
				nil,
				{
					{
						{
							poweroff,
							reboot,
							suspend,
							logout,
							lock,
							layout = wibox.layout.fixed.horizontal
						},
						spacing = dpi(30),
						layout = wibox.layout.fixed.vertical
					},
					widget = wibox.container.margin,
					margins = dpi(15)
				},
				nil
			}
		},
		nil
	}
end

screen.connect_signal("request::desktop_decoration", function(s)
	create_exit_screen(s)
end)

local exit_screen_grabber = awful.keygrabber {
	auto_start = true,
	stop_event = 'release',
	keypressed_callback = function(self, mod, key, command)
		if key == 'Escape' or key == 'q' or key == 'x' then
			awesome.emit_signal("module::exit_screen:hide")
		end
	end
}

awesome.connect_signal("module::exit_screen:show", function()
	for s in screen do
		s.exit_screen.visible = false
	end
	awful.screen.focused().exit_screen.visible = true
	exit_screen_grabber:start()
end)

awesome.connect_signal("module::exit_screen:hide", function()
	update_greeter_message()
	exit_screen_grabber:stop()
	for s in screen do
		s.exit_screen.visible = false
	end
end)

