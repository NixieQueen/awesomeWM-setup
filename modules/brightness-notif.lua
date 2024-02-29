local brightness_image = wibox.widget {
  widget = wibox.widget.imagebox,
  image = gears.color.recolor_image(icons.sun, beautiful.primary),
  resize = true,
  forced_height = dpi(40),
  forced_width = dpi(40),
  align = 'left',
  valign = 'center',
}

local brightness_value = wibox.widget {
  widget = wibox.widget.textbox,
  text = 'Brightness: 0%',
  font = beautiful.sysboldfont .. dpi(15),
  align = 'center',
  valign = 'center',
}

local brightness_slider = wibox.widget {
  nil,
  {
    {
      widget = wibox.widget.progressbar,
      max_value = 100,
      value = 30,
      margins = dpi(5),
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(10))
      end,
      color = beautiful.primary,
      background_color = beautiful.primary_off,
      id = 'progress',
    },
    {
      widget = wibox.widget.slider,
      handle_shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(5))
      end,
      handle_border_color = beautiful.quaternary_off,
      handle_border_width = dpi(2),
      handle_color = beautiful.quaternary,
      bar_shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(5))
      end,
      bar_height = dpi(5),
      bar_color = beautiful.transparent,
      id = 'brightness',
      maximum = 100,
      value = 30,
    },
    layout = wibox.layout.stack,
    forced_height = dpi(25),
    id = 'stack'
  },
  nil,
  expand = 'none',
  layout = wibox.layout.align.vertical,
}

brightness_slider.stack.brightness:connect_signal(
  "property::value",
  function()
    local brightness_level = brightness_slider.stack.brightness:get_value()

    awful.spawn('light -S ' .. math.max(brightness_level, 5), false)
    brightness_value.text = "Brightness: " .. brightness_level .. "%"
    brightness_slider.stack.progress.value = brightness_level
    awesome.emit_signal("module::brightness_osd:show",true)
  end
)

local brightness_creator = function(s)
  s.brightness_popup = awful.popup {
    widget = {
      -- Widget required for functionality :3
    },
    ontop = true,
    visible = false,
    type = 'notification',
    screen = s,
    height = dpi(100),
    maximum_height = dpi(150),
    width = dpi(300),
    maximum_width = dpi(300),
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(5))
    end,
    bg = beautiful.transparent,
    preferred_anchors = 'middle',
    preferred_positions = {'left', 'right', 'top', 'bottom'}
  }

  s.brightness_popup : setup {
    {
      {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(7),
        {
          layout = wibox.layout.align.horizontal,
          expand = 'none',
          nil,
          {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(15),
            brightness_image,
            brightness_value,
          },
          nil,
        },
        brightness_slider,
      },
      left = dpi(15),
      right = dpi(10),
      top = dpi(15),
      bottom = dpi(10),
      widget = wibox.container.margin,
    },
    bg = beautiful.background,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(5))
    end,
    widget = wibox.container.background()
  }

  awful.placement.top(
    s.brightness_popup,
    {
      margins = {
        top = dpi(60)

      },
      honor_workarea = true,
    }
  )
end

screen.connect_signal(
  "request::desktop_decoration", function(s)
    brightness_creator(s)
  end
)

local hide_brightness_popup = gears.timer {
  timeout = 2,
  --autostart = true,
  callback = function()
    local focused = awful.screen.focused()
    focused.brightness_popup.visible = false
  end
}

awesome.connect_signal(
  "module::brightness_osd:value",
  function()
    awful.spawn.easy_async_with_shell(
      [[light -G | awk '{printf "%.0f",$0}']],
      function(stdout)
        brightness_slider.stack.brightness.value = tonumber(stdout)
      end
    )
  end
)

awesome.connect_signal(
  "module::brightness_osd:rerun", function()
    if hide_brightness_popup.started then
      hide_brightness_popup:again()
    else
      hide_brightness_popup:start()
    end
  end
)

awesome.connect_signal(
  "module::brightness_osd:show", function(bool)
    awful.screen.focused().brightness_popup.visible = bool
    if bool then
      awesome.emit_signal("module::brightness_osd:rerun")
      awesome.emit_signal(
        "module::volume_osd:show",
        false
        )
    else
      if hide_brightness_popup.started then
        hide_brightness_popup:stop()
      end
    end
  end
)
