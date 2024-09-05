-- Use this as mostly a template, this is going to be a script for a widget that can be used in a sidebar
--
-- The actual cpu bar
local bar_creator = function(icon, name, barcallback, textcallback, barsizeX, barsizeY, color, bg_color)

	local icon = wibox.widget {
		id = 'icon',
		image = icon,
		resize = true,
		forced_height = barsizeX/2,
		forced_width = barsizeX/2,
		align = 'center',
		valign = 'center',
		widget = wibox.widget.imagebox
	}

	local name = wibox.widget {
		id = 'name',
		markup = name,
		font = beautiful.sysboldfont .. dpi(13),
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local bartext = wibox.widget {
		id = 'bartext',
		markup = '6.9 Ghz',
		font = beautiful.sysboldfont .. dpi(13),
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
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
			thickness = dpi(6),
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
		forced_height = barsizeY,
		forced_width = barsizeX,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(5),
			{
				layout = wibox.container.background,
				shape = gears.shape.circle,
				bg = beautiful.arc_bar_bg,
				fg = beautiful.primary,
				{
					layout = wibox.layout.stack,
					progressbar,
					{
						icon,
						widget = wibox.container.margin,
						margins = dpi(15),
					},
				},
			},
			{
				layout = wibox.layout.fixed.vertical,
				spacing = dpi(5),
				name,
				{
					widget = wibox.container.background,
					fg = color,
					bartext,
				},
			},
		},
	}

	bar.animation = rubato.timed {
		intro = 0.5,
		duration = 1.0,
		easing = rubato.quadratic,
		subscribed = function(pos)
			progressbar.progressbar.value = pos
		end
	}
	
	bar:connect_signal("widget::bar:refresh", function()
		-- async stuff!
		-- first up progressbar
		awful.spawn.easy_async_with_shell(barcallback, function(stdout)
			bar.animation.target = tonumber(stdout)
		end)
		
		-- second bartext!
		awful.spawn.easy_async_with_shell(textcallback, function(stdout)
			bartext:set_markup(stdout:match('[^\n]*'))
		end)
	end)
	
	bar:connect_signal("widget::bar:change_icon", function(new_icon, colour)
		local new_bar_icon = gears.color.recolor_image(new_icon, colour)
		icon:set_image(new_bar_icon)
		--icon.emit_signal("widget::redraw_needed")
	end)

	return bar
end

return bar_creator

