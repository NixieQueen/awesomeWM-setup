-- Use this as mostly a template, this is going to be a script for a widget that can be used in a sidebar
--
-- The actual cpu bar
local bar_creator = function(icon, barcallback, barsizeX, barsizeY, color, bg_color)

	local icon = wibox.widget {
		id = 'icon',
		image = icon,
		resize = true,
		--forced_height = dpi(10),
		--forced_width = barsizeY,
		align = 'center',
		valign = 'center',
		widget = wibox.widget.imagebox
	}

	local progressbar = wibox.widget {
		{
			id = 'progressbar',
			max_value = 100,
			min_value = 0,
			value = 50,
			background_color = bg_color,
			colors = {color},
			bg = bg_color,
			rounded_edge = true,
			thickness = dpi(5),
			start_angle = 1.5 * math.pi,
			widget = wibox.container.arcchart,
		},
		border_width = dpi(0),
		border_color = beautiful.border_color_active,
		layout = wibox.container.background,
		shape = gears.shape.rounded_bar,
	}
	
	local bar = wibox.widget {
		layout = wibox.layout.align.horizontal
	}
	
	bar : setup {
		layout = wibox.container.background,
		shape = gears.shape.circle,
		bg = '#2F2F2F',
		forced_height = barsizeY/2,
		forced_width = barsizeX*2,
		fg = beautiful.primary,
		{
			layout = wibox.layout.stack,
			progressbar,
			{
				icon,
				widget = wibox.container.margin,
				margins = dpi(8),
			},
		},
	}
	
	bar:connect_signal("widget::bar:refresh", function()
		-- async stuff!
		-- first up progressbar
		awful.spawn.easy_async_with_shell(barcallback, function(stdout)
			progressbar.progressbar.value = tonumber(stdout)
		end)
	end)
	
	bar:connect_signal("widget::bar:charge_icon", function()
		local new_icon = gears.color.recolor_image(icons.battery_charge, color)
		icon:set_image(new_icon)
		--icon.emit_signal("widget::redraw_needed")
	end)
	
	bar:connect_signal("widget::bar:discharge_icon", function()
		local new_icon = gears.color.recolor_image(icons.battery, color)
		icon:set_image(new_icon)
		--icon.emit_signal("widget::redraw_needed")
		
	end)
	
	return bar
end

return bar_creator

