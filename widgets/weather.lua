-- This is a cool file for a weather app!
-- It is used in the left-panel module, although feel free to use it elsewhere
-- This module relies on the weather-Cli app!

-- First make a module for creating the whole widget
local weather_widget_creator = function(sizeX, sizeY, city)
  local temperature = wibox.widget {
    widget = wibox.widget.textbox,
    markup = 'has',
    font = beautiful.sysboldfont .. dpi(30),
    align = 'center',
    valign = 'center'
  }
  local real_temperature = wibox.widget {
    widget = wibox.widget.textbox,
    markup = 'no',
    font = beautiful.sysboldfont .. dpi(25),
    align = 'center',
    valign = 'center'
  }
  local wind_speed = wibox.widget {
    widget = wibox.widget.textbox,
    markup = 'internet :3',
    font = beautiful.sysboldfont .. dpi(18),
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
    image = gears.color.recolor_image(icons.sun, beautiful.weather_app_fg_quinary),
    resize = true
  }

  local text_ratio = wibox.widget {
    layout = wibox.layout.ratio.vertical,
    temperature,
    {
      layout = wibox.container.background,
      fg = beautiful.weather_app_fg_secondary,
      real_temperature,
    },
    {
      layout = wibox.container.background,
      fg = beautiful.weather_app_fg_tertiary,
      condition,
    },
    {
      layout = wibox.container.background,
      fg = beautiful.weather_app_fg_quaternary,
      wind_speed,
    }
  }
  text_ratio:adjust_ratio(2, 0.2, 0.3, 0.3, 0.2)

  local icon_ratio = wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    {
      layout = wibox.layout.align.vertical,
      expand = 'none',
      nil,
      weather_status,
      nil,
    },
    text_ratio
  }
  icon_ratio:adjust_ratio(2, 0.3, 0.7, 0.0)

  local weather_app = wibox.widget {
    widget = wibox.container.background,
    fg = beautiful.weather_app_fg_primary,
    bg = beautiful.weather_app_bg,
    forced_height = sizeY,
    forced_width = sizeX,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
    {
      layout = wibox.container.margin,
      margins = dpi(15),
      icon_ratio
    }
  }

  local function parse_output(stdout)
    outputstring = {}
    for line in string.gmatch(stdout, "([^\n]*)") do
      for t, o in string.gmatch(line, "(%w+): (.*)") do
        outputstring[t] = o
      end
    end

    return {
      temperature = outputstring['Temperature'],
      windspeed = outputstring['Speed'],
      realtemperature = outputstring['Feel'],
      condition = outputstring['Condition']
    }
  end

  local function get_weather_icon(condition, time)
    local icon
    local weather = string.lower(condition)
    if string.find(weather, 'clear') then
      if time == 'day' then
        icon = icons.sun
      else
        icon = icons.moon
      end
    elseif (string.find(weather, 'cloudy') or string.find(weather, 'overcast')) then
      icon = icons.cloudy
    elseif string.find(weather, 'fog') then
      icon = icons.fog
    elseif (string.find(weather, 'drizzle') or string.find(weather, 'rain')) then
      icon = icons.rain
    elseif string.find(weather, 'thunderstorm') then
      icon = icons.thunderstorm
    elseif string.find(weather, 'snow') then
      icon = icons.snow
    else
      icon = icons.sun
    end

    if time == 'day' then
      icon = gears.color.recolor_image(icon, beautiful.weather_app_fg_primary)
    else
      icon = gears.color.recolor_image(icon, beautiful.weather_app_fg_secondary)
    end
    return icon

  end

  local function update_all()
    awful.spawn.easy_async_with_shell(
      [[weather-Cli get ]] .. city .. [[ | grep -E 'Temperature|Real Feel|Weather Condition|Wind Speed']],
      function(stdout)
        local output = parse_output(stdout)

        if output.temperature then
          temperature.markup = output.temperature
          wind_speed.markup = "Wind speed: " .. output.windspeed
          real_temperature.markup = "Feels: " .. output.realtemperature
          condition.markup = output.condition

          local current_time = tonumber(os.date("%H"))
          if (7 < current_time and current_time < 22) then
            current_time = 'day'
          else
            current_time = 'night'
          end

          weather_status:set_image(get_weather_icon(output.condition, current_time))
        end
      end
    )
  end

  update_timer = gears.timer {
    call_now = false,
    timeout = 120,
    callback = update_all
  }

  weather_app:connect_signal("widget::weather_app:start_clock", function()
    update_all()
    update_timer:start()
  end)

  weather_app:connect_signal("widget::weather_app:stop_clock", function()
    update_timer:stop()
  end)

  return weather_app
end
-- The end!! :3c
return weather_widget_creator
