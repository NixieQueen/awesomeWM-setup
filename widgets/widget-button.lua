-- This widget is mainly used in the left panel module
-- It is responsible for the base functionality of all buttons such as wifi, bluetooth, etc
local function create_widget_button(icon, name, colour, sizeX, sizeY, font)
  toggle_button_ratio = wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    spacing = dpi(5),
    {
      widget = wibox.widget.imagebox,
      image = icon,
      resize_allowed = true,
    },
    {
      layout = wibox.layout.align.horizontal,
      expand = 'none',
      nil,
      {
        widget = wibox.widget.textbox,
        text = name,
        font = font,
        halign = "center",
        valign = "center",
      },
      nil
    }
  }
  toggle_button_ratio:adjust_ratio(2, 0.3, 0.7, 0.0)

  toggle_button = wibox.widget {
    layout = wibox.container.background,
    bg = beautiful.left_panel_widget_bg,
    {
      widget = clickable_container,
      {
        layout = wibox.container.margin,
        margins = dpi(5),
        toggle_button_ratio
      }
    }
  }
  toggle_button.toggle_state = false


  settings_button = wibox.widget {
    layout = wibox.container.background,
    bg = beautiful.left_panel_widget_bg,
    {
      widget = clickable_container,
      {
        layout = wibox.container.margin,
        margins = dpi(5),
        {
          layout = wibox.layout.align.horizontal,
          expand = 'none',
          nil,
          {
            widget = wibox.widget.imagebox,
            image = icons.option_arrow,
            resize_allowed = true,
          },
          nil
        }
      }
    }
  }
  settings_button.toggle_state = false

  button_ratio = wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    toggle_button,
    settings_button
  }
  button_ratio:adjust_ratio(2, 0.8, 0.2, 0.0)

  widget_button = wibox.widget {
    layout = wibox.container.background,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
    bg = beautiful.transparent,
    fg = beautiful.left_panel_widget_fg,
    forced_width = sizeX,
    forced_height = sizeY,
    button_ratio
  }

  toggle_button:connect_signal("button::release", function(content, lx, ly, button)
    if button == 1 then
      if toggle_button.toggle_state then
        toggle_button.bg = beautiful.left_panel_widget_bg
        widget_button:emit_signal("widget::widget_button:toggle_off")
      else
        toggle_button.bg = colour
        widget_button:emit_signal("widget::widget_button:toggle_on")
      end
      toggle_button.toggle_state = not toggle_button.toggle_state
    end
  end)

  settings_button:connect_signal("button::release", function(content, lx, ly, button)
    if button == 1 then
      if settings_button.toggle_state then
        settings_button.bg = beautiful.left_panel_widget_bg
        widget_button:emit_signal("widget::widget_button:settings_close")
      else
        settings_button.bg = colour
        widget_button:emit_signal("widget::widget_button:settings_open")
      end
      settings_button.toggle_state = not settings_button.toggle_state
    end
  end)

  return widget_button
end

return create_widget_button
