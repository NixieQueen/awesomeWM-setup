-- This widget handles the systray for all your background apps :3
local systray_creator = function()

  local systray = wibox.widget {
    widget = wibox.widget.systray,
    set_horizontal = false,
    set_screen = s,
  }
  -- Do cool shit here!
  local systray_widget = awful.popup {
    visible = false,
    opacity = 0.5, -- temporary stupid fix because the systray background is black???
    maximum_width = dpi(100),
    ontop = true,
    --maximum_height = dpi(500),
    hide_on_right_click = true,
    bg = beautiful.bg_calendar,
    preferred_positions = 'bottom',
    preferred_anchors = 'middle',
    --placement = function(cr)
    --awful.placement.top(cr,{honor_workarea=true})
    --end,
    widget = systray,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
  }

  local systray_widget = interactive_popup(systray_widget, 2)

  systray_widget:connect_signal("widget::systray:show", function()
    local newpos = mouse.current_widget_geometry
    newpos.x = newpos.x - systray_widget.width / 2
    systray_widget:move_next_to(newpos)
    systray:set_screen(awful.screen.focused())
    systray_widget:emit_signal("widget::interactive-popup:show")
  end)

  return systray_widget
end
return systray_creator
