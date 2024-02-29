-- This widget is for the creation of the calendar widget!
local calendar_creator = function(s)
	local styles = {}
	local function rounded_shape(size, partial)
		if partial then
			return function(cr, width, height)
				gears.shape.partially_rounded_rect(cr, width, height,
												   false, true, false, true, 5)
			end
		else
			return function(cr, width, height)
				gears.shape.rounded_rect(cr, width, height, size)
			end
		end
	end
	styles.month   = { padding      = 5,
					   bg_color     = beautiful.transparent,
					   border_width = 0,
					   shape        = rounded_shape(2)
	}
	styles.normal  = { shape    = rounded_shape(5) }
	styles.focus   = { fg_color = beautiful.secondary,
					   bg_color = beautiful.alttab_bg_minimize,
					   markup   = function(t) return '<b>' .. t .. '</b>' end,
					   shape    = rounded_shape(5, true)
	}
	styles.header  = { fg_color = beautiful.quinary,
					   markup   = function(t) return '<b>' .. t .. '</b>' end,
					   shape    = rounded_shape(10)
	}
	styles.weekday = { fg_color = beautiful.quinary,
					   markup   = function(t) return '<b>' .. t .. '</b>' end,
					   shape    = rounded_shape(5)
	}
	local function decorate_cell(widget, flag, date)
		if flag=='monthheader' and not styles.monthheader then
			flag = 'header'
		end
		local props = styles[flag] or {}
		if props.markup and widget.get_text and widget.set_markup then
			widget:set_markup(props.markup(widget:get_text()))
		end
		-- Change bg color for weekends
		local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
		local weekday = tonumber(os.date('%w', os.time(d)))
		local default_bg = (weekday==0 or weekday==6) and beautiful.alttab_bg_focus or beautiful.alttab_bg_normal
		local ret = wibox.widget {
			{
				widget,
				margins = (props.padding or 2) + (props.border_width or 0),
				widget  = wibox.container.margin
			},
			shape              = props.shape,
			fg                 = props.fg_color or beautiful.secondary_off,
			bg                 = props.bg_color or default_bg,
			widget             = wibox.container.background
		}
		return ret
	end

	local calendar = wibox.widget {
		widget = wibox.widget.calendar.month,
		date = os.date("*t"),
		fn_embed = decorate_cell,
	}
	-- Do cool shit here!
	local calendar_widget = awful.popup {
		screen = s,
		visible = false,
		--width = dpi(300),
		ontop = true,
		--height = dpi(500),
		hide_on_right_click = true,
		bg = beautiful.bg_calendar,
		preferred_positions = 'bottom',
		preferred_anchors = 'middle',
		--placement = function(cr)
		--	awful.placement.top(cr,{honor_workarea=true})
		--end,
		widget = calendar,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, dpi(20))
		end,
	}
	local calendar_widget = interactive_popup(calendar_widget, 2)

	return calendar_widget
end
return calendar_creator
