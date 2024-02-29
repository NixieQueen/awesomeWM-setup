-- Module for switching themes :3c

-- create entries
local theme_entry_creator = function(name, color,callback)
	local theme_name = wibox.widget {
		widget = wibox.widget.textbox,
		markup = name,
		font = beautiful.sysboldfont .. dpi(45),
		align = 'center',
		valign = 'center'
	}

	local theme_entry = wibox.widget {
		shape = gears.shape.rounded_rect,
		--forced_width = dpi(160),
		--forced_height = dpi(160),
		widget = clickable_container,
		{
			widget = wibox.container.background,
			shape = gears.shape.rounded_rect,
			shape_border_width = beautiful.border_width * 2,
			shape_border_color = beautiful.border_color_active,
			fg = color,
			{
				widget = wibox.container.margin,
				top = dpi(10),
				left = dpi(10),
				right = dpi(10),
				theme_name,
			}
		},
	}
	
	theme_entry:connect_signal(
		'button::release',
		function()
			local theme_command = "cat ~/.config/awesome/themes/themeconfigs.txt | grep '[0-9]' | awk '{print $2$3$4}'"
			local theme_string = io.popen(theme_command):read("*all")
			local themeconfig = io.open(config_dir .. "/themes/themeconfigs.txt", "w+")
			themeconfig:close()
			local themeconfig = io.open(config_dir .. "/themes/themeconfigs.txt", "a")
			for vtheme in theme_string:gmatch("[^\n]+") do
				local results = {}
				for split in vtheme:gmatch("[^.]+") do
					table.insert(results, split)
				end
				themeconfig:write("1: " .. results[1] .. " . " .. results[2] .. "\n")
			end
			themeconfig:write("default: " .. name)
			themeconfig:close()
			awesome.restart()
		end
	)
	return theme_entry
end
	
local themes = {}

-- get valid themes!
local theme_command = "cat ~/.config/awesome/themes/themeconfigs.txt | grep '[0-9]' | awk '{print $2$3$4}'"
local theme_string = io.popen(theme_command):read("*all")
for vtheme in theme_string:gmatch("[^\n]+") do
	local results = {}
	for split in vtheme:gmatch("[^.]+") do
		table.insert(results, split)
	end
	table.insert(themes, theme_entry_creator(results[1], results[2]))
end

-- theme switcher
local theme_switcher = function(s)
	local theme_width = dpi(500)
	local theme_height = dpi(400)

	s.theme_switcher = awful.popup {
		widget = {
			-- Sure whatever
		},
		ontop = true,
		visible = false,
		type = 'notification',
		screen = s,
		height = theme_height,
		width = theme_width,
		maximum_height = theme_height,
		maximum_width = theme_width,
		offset = dpi(5),
		shape = gears.shape.rectangle,
		bg = beautiful.transparent,
		preferred_anchors = 'middle',
		preferred_positions = {'left', 'right', 'top', 'bottom'}
	}
	
	local rounded_shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, dpi(20))
	end
	
	s.theme_switcher : setup {
		{
			{
				themes[1],
				themes[2],
				themes[3],
				themes[4],
				spacing = dpi(10),
				layout = wibox.layout.flex.vertical,
			},
			left = dpi(10),
			right = dpi(10),
			top = dpi(10),
			bottom = dpi(10),
			widget = wibox.container.margin
		},
		bg = beautiful.background,
		shape = rounded_shape,
		shape_border_width = beautiful.border_width * 2,
		shape_border_color = beautiful.border_color_inactive,
		widget = wibox.container.background
	}
	
	-- Reset timer on mouse hover
	s.theme_switcher:connect_signal(
		'mouse::enter', 
		function()
			awful.screen.focused().theme_switcher.visible = true
			awesome.emit_signal('module::theme_switcher:rerun')
		end
	)
end

-- timer for disabling theme switcher
local hide_theme = gears.timer {
	timeout = 5,
	autostart = true,
	callback  = function()
		local focused = awful.screen.focused()
		focused.theme_switcher.visible = false
	end
}

awesome.connect_signal(
	'module::theme_switcher:rerun',
	function()
		if hide_theme.started then
			hide_theme:again()
		else
			hide_theme:start()
		end
	end
)

-- placement
local placement_placer = function()
	local focused = awful.screen.focused()
	
	awful.placement.top_right(
		focused.theme_switcher,
		{
			margins = { 
				left = 0,
				right = dpi(10),
				top = dpi(10),
				bottom = 0,
			},
			honor_workarea = true
		}
	)
end

screen.connect_signal("request::desktop_decoration", function(s)
	theme_switcher(s)
end)

awesome.connect_signal(
	'module::theme_switcher:show', 
	function(bool)
		placement_placer()
		awful.screen.focused().theme_switcher.visible = bool
		if bool then
			awesome.emit_signal('module::theme_switcher:rerun')
			awesome.emit_signal(
				'module::volume_osd:show',
				false
			)
			awesome.emit_signal(
				'module::brightness_osd:show',
				false
			)
		else
			if hide_theme.started then
				hide_theme:stop()
			end
		end
	end
)
