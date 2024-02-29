-- Script for a topbar for windows
-- Should only apply when in floating mode!!!
awful.titlebar.enable_tooltip = false
awful.titlebar.fallback_name = 'App'

-- Double click event, for maximizing on double click
local double_click_max_handler = function(double_click_event)
	if double_click_timer then
		double_click_timer:stop()
		double_click_timer = nil
		double_click_event()
		return
	end
	double_click_timer = gears.timer.start_new(
		0.20,
		function()
			double_click_timer = nil
			return false
		end
	)
end

-- Titlebars
client.connect_signal("request::titlebars", function(c)
	-- buttons
	local buttons = {
		awful.button({}, 1, function()
			double_click_max_handler(function()
				c.maximized = not c.maximized
				c:raise()
				return
			end)
			c:activate {context='titlebar', action='mouse_move'} end),
		awful.button({}, 3, function()
			c:activate {context='titlebar', action='mouse_resize'} end)
	}
	local clickable_buttons = {
		awful.button({}, 3, function()
			c:activate {context='titlebar', action='mouse_resize'} end)
	}
	
	awful.titlebar(c, {position = 'left', bg = beautiful.titlebar_bg_normal, size = beautiful.titlebar_size}).widget = {
		{ -- Leftbound
			buttons = clickable_buttons,
			--awful.titlebar.widget.iconwidget(c),
			appicon(c.class,true,c),
			awful.titlebar.widget.closebutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.minimizebutton(c),
			spacing = dpi(7),
			layout = wibox.layout.fixed.vertical
		},
		{ -- Middlebound
			buttons = buttons,
			layout = wibox.layout.flex.vertical
		},
		{ -- Rightbound
			buttons = buttons,
			layout = wibox.layout.fixed.vertical
		},
		layout = wibox.layout.align.vertical
	}
end)
