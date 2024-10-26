local volume_image = wibox.widget {
  widget = wibox.widget.imagebox,
  image = gears.color.recolor_image(icons.shutdown, beautiful.primary),
  resize = true,
  forced_height = dpi(40),
  forced_width = dpi(40),
  align = 'left',
  valign = 'center',
}

local volume_value = wibox.widget {
  widget = wibox.widget.textbox,
  text = 'Volume: 0%',
  font = beautiful.sysboldfont .. dpi(15),
  align = 'center',
  valign = 'center',
}

local volume_slider = wibox.widget {
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
      id = 'volume',
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

volume_slider.stack.volume:connect_signal(
  "property::value",
  function()
    local volume_level = volume_slider.stack.volume:get_value()

    awful.spawn('amixer sset Master ' .. volume_level .. "%", false)
    volume_value.text = "Volume: " .. volume_level .. "%"
    volume_slider.stack.progress.value = volume_level
    awesome.emit_signal("module::volume_osd:show",true)
  end
)

local volume_creator = function(s)
  s.volume_popup = awful.popup {
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

  s.volume_popup = interactive_popup(s.volume_popup, 2)

  s.volume_popup : setup {
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
            volume_image,
            volume_value,
          },
          nil,
        },
        volume_slider,
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
    s.volume_popup,
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
    volume_creator(s)
  end
)

awesome.connect_signal(
  "module::volume_osd:value",
  function()
    awful.spawn.easy_async_with_shell(
      [[amixer sget Master | grep 'Left: ' | awk '{print $5}']],
      function(stdout)
        volume_slider.stack.volume.value = tonumber(string.match(stdout, "(%d?%d?%d)%%"))
      end
    )
    awful.spawn.easy_async_with_shell(
      [[amixer sget Master | grep 'Left: ' | awk '{print $6}']],
      function(stdout)
        if stdout == "[off]\n" then
          volume_image.image = gears.color.recolor_image(icons.temperature, beautiful.primary_off)
        else
          volume_image.image = gears.color.recolor_image(icons.temperature, beautiful.primary)
        end
      end
    )
  end
)

awesome.connect_signal(
  "module::volume_osd:show", function(bool)
    awful.screen.focused().volume_popup:emit_signal("widget::interactive-popup:show")
    if bool then
      awesome.emit_signal(
        "module::brightness_osd:show",
        false
        )
    else
      for s in screen do
        s.volume_popup:emit_signal("widget::interactive-popup:hide")
      end
    end
  end
)
