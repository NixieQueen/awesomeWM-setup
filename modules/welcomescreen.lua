-- Epic screen for welcoming user!

-- Preperation for set up
-- Table of messages to choose from to display at welcome!
local msg_table = {
	"Welcome!",
	"Hewwo",
	"Hewwoo :3c",
	"Greetings!"
}

local greeter_message = wibox.widget {
	markup = msg_table[math.random(#msg_table)],
	font = beautiful.sysboldfont .. dpi(80),
	align = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local profile_name = wibox.widget {
	markup = '$USER',
	font = beautiful.sysboldfont .. dpi(80),
	align = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local update_profile_name = function()
	awful.spawn.easy_async_with_shell(
		[[sh -c 'printf "$(whoami)"']],
		function(stdout)
			profile_name:set_markup(stdout:sub(1,1):upper()..stdout:sub(2))
			profile_name:emit_signal('widget::redraw_needed')
		end)
end

update_profile_name()

local gif = gifcontainer(icons.welcomegif, beautiful.welcomegif_width, beautiful.welcomegif_height)

local create_welcome_screen = function(s)
	s.welcome_screen = wibox {
		screen = s,
		type = 'dock',
		visible = false,
		ontop = true,
		bg = beautiful.background,
		fg = beautiful.primary,
		height = s.geometry.height,
		width = s.geometry.width,
		x = s.geometry.x,
		y = s.geometry.y
	}
	
	s.welcome_screen : setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		nil,
		{
			layout = wibox.layout.align.vertical,
			expand = 'none',
			nil,
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(40),
				{
					widget = wibox.container.background,
					greeter_message,
					fg = beautiful.secondary,
				},
				{
					widget = wibox.container.background,
					profile_name,
					fg = beautiful.primary
				},
				gif,
			},
			nil
		},
		nil
	}
end

screen.connect_signal("request::desktop_decoration", function(s)
	create_welcome_screen(s)
end)


gif:emit_signal("widget::gif:start_loop")

gears.timer.start_new(0.1, function()
	for s in screen do
		s.welcome_screen.visible = true
	end
end)

gears.timer.start_new(4, function() for s in screen do s.welcome_screen.visible = false end gif:emit_signal("widget::gif:stop_loop") end)
