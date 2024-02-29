-- This is a cool file for a weather app!
-- It is used in the left-panel module, although feel free to use it elsewhere

-- First make a module for creating the whole widget
local weather_widget_creator = function(sizeY, city)
  local temperature = wibox.widget {
    widget = wibox.widget.textbox,
    markup = 'has',
    font = beautiful.sysboldfont .. dpi(22),
    align = 'center',
    valign = 'center'
  }
  local real_temperature = wibox.widget {
    widget = wibox.widget.textbox,
    markup = 'no',
    font = beautiful.sysboldfont .. dpi(22),
    align = 'center',
    valign = 'center'
  }
  local wind_speed = wibox.widget {
    widget = wibox.widget.textbox,
    markup = 'internet :3',
    font = beautiful.sysboldfont .. dpi(22),
    align = 'center',
    valign = 'center'
  }
  local condition = wibox.widget {
    widget = wibox.widget.textbox,
    markup = 'I',
    font = beautiful.sysboldfont .. dpi(22),
    align = 'center',
    valign = 'center'
  }
  local weather_status = wibox.widget {
    widget = wibox.widget.imagebox,
    image = gears.color.recolor_image(icons.sun, beautiful.primary),
    resize = true,
    forced_height = dpi(sizeY),
    forced_width = dpi(sizeY)
  }

  local weather_app = wibox.widget {
    widget = wibox.container.background,
    fg = beautiful.primary,
    bg = beautiful.transparent,
    forced_height = dpi(sizeY),
    {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(25),
      weather_status,
      {
        condition,
        {
          widget = wibox.container.background,
          fg = beautiful.secondary,
          temperature,
        },
        real_temperature,
        {
          widget = wibox.container.background,
          fg = beautiful.secondary,
          wind_speed,
        },
        layout = wibox.layout.fixed.vertical,
      },
    },
  }

  local weather_loop = gears.timer {
    timeout = 120,
    call_now = true,
    autostart = true,
    callback = function()
      -- This is where the widget checks for the weather conditions
      awful.spawn.easy_async_with_shell(
        [[weather-Cli get ]] .. city .. [[ | grep -E 'Temperature|Real Feel|Weather Condition|Wind Speed']],
        function(stdout)
          outputstring = {}
          for line in string.gmatch(stdout, "([^\n]*)") do
            for t, o in string.gmatch(line, "(%w+): (.*)") do
              outputstring[t] = o
            end
          end

          if outputstring['Temperature'] then
            temperature.markup = "Temperature: " .. outputstring['Temperature']
            wind_speed.markup = "Wind speed: " .. outputstring['Speed']
            real_temperature.markup = "Feels like: " .. outputstring['Feel']
            condition.markup = outputstring['Condition']

            current_time = tonumber(os.date("%H"))
            if 22 <= current_time or current_time <= 7 then
              weather_status:set_image(gears.color.recolor_image(icons.moon, beautiful.primary))
            else
              weather_status:set_image(gears.color.recolor_image(icons.sun, beautiful.primary))
            end
          end
        end
      )
    end
  }

  return {weather_app = weather_app, weather_loop = weather_loop}
end
-- The end!! :3c
return weather_widget_creator
